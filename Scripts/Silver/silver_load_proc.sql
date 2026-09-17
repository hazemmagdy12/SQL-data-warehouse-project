USE data_warehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS 
BEGIN
    DECLARE @start_time DATETIME;
    DECLARE @end_time DATETIME;

    BEGIN TRY
        PRINT ('==================');
        PRINT ('Loading Silver Layer');
        
        PRINT ('Truncating table silver.crm_cust_info');
        TRUNCATE TABLE silver.crm_cust_info; 

        PRINT ('Inserting data into silver.crm_cust_info');
        SET @start_time = GETDATE();
--#####################################################################################################################
        -- 1. بنكريت الجدول الوهمي (CTE) وبننضف الداتا
        WITH new_table AS (
            SELECT 
                cst_id,  -- جبنا الـ ID الأصلي
                TRIM(cst_key) AS cst_key,
                coalesce(TRIM(cst_firstname) , 'Unknown' ) AS cst_firstname,
                coalesce(TRIM(cst_lastname) , 'Unknown' ) AS cst_lastname,
                TRIM(cst_marital_status) AS cst_marital_status,
                CASE 
                    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' 
                    WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' -- غيرناها لـ F و Female
                    ELSE 'Unknown'
                END AS cst_gndr,
                cst_create_date  ,
                -- 2. سمينا الترقيم باسم جديد عشان ميبوظش الـ ID
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS row_num
            FROM bronze.crm_cust_info
        )
        -- 3. بنصب الداتا في السيلفر
        INSERT INTO silver.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname, 
            cst_marital_status, cst_gndr, cst_create_date
        )
        -- 4. بنختار الـ 7 أعمدة بس بدون النجمة (*)، وبنفلتر برقم 1
        SELECT 
            cst_id, cst_key, cst_firstname, cst_lastname, 
            cst_marital_status, cst_gndr, cst_create_date
        FROM new_table 
        WHERE row_num = 1;
--################################################################################################################################
        PRINT ('Truncating table silver.crm_prd_info');
        TRUNCATE TABLE silver.crm_prd_info;
        INSERT INTO silver.crm_prd_info (
            prd_id, 
            cat_id, 
            prd_key, 
            prd_nm, 
            prd_cost, 
            prd_line, 
            prd_start_dt, 
            prd_end_dt
        )
        SELECT 
            prd_id,
            -- 1. فك المفتاح المركب وتوحيد الرموز (الفئة)
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            -- استخراج كود المنتج الصافي
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            
            prd_nm,
            
            -- 2. معالجة الأرقام المفقودة (التكلفة)
            ISNULL(prd_cost, 0) AS prd_cost,
            
            prd_line,
            prd_start_dt,
            DATEADD(day , -1, lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)) AS prd_end_dt
        FROM bronze.crm_prd_info;
--#########################################################################################################################################
        insert into silver.crm_sales_details (    
        sls_ord_num ,
        sls_prd_key ,
        sls_cust_id ,
        sls_order_dt , 
        sls_ship_dt ,
        sls_due_dt ,
        sls_sales ,
        sls_quantity ,
        sls_price       
        )

        select 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        case 
        when sls_order_dt = 0 or len(sls_order_dt) < 8 then null
        else
        cast(cast(sls_order_dt as varchar)as date )
        end as sls_order_dt,
        case 
        when sls_ship_dt =0 or len (sls_ship_dt) < 8 then null
        else
        cast(cast(sls_ship_dt as varchar) as date)
        end as sls_ship_dt,
        CASE 
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) < 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
        END AS sls_due_dt,
        case
        when sls_sales <= 0 or sls_sales is null or sls_quantity * abs(sls_price) !=  sls_sales then sls_quantity * abs(sls_price) 
        else sls_sales
        end as sls_sales ,
        sls_quantity,
        case
        when sls_price is null or sls_price <= 0 or  sls_sales / nullif(sls_quantity,0) != sls_price then sls_sales / nullif(sls_quantity,0)
        else 
        sls_price
        end as sls_price
        from
        bronze.crm_sales_details;

--##################################################################################################################### 
    insert into silver.erp_cust_az12 (
    CID ,
    BDATE ,      -- هنعمله DATE عشان نستقبل التواريخ
    GEN )
    select
    case 
    when CID like 'NASAW%' then SUBSTRING(CID , 6 , len(CID))
    else CID
    end as CID ,
    case 
    when BDATE > getdate() then null
    else BDATE
    end as BDATE,
    CASE 
    WHEN UPPER(TRIM(GEN)) = 'M' THEN 'Male' 
    WHEN UPPER(TRIM(GEN)) = 'F' THEN 'Female' -- غيرناها لـ F و Female
    ELSE 'Unknown'
    END AS GEN
    from bronze.erp_cust_az12;
--==============================================================================================
        insert into silver.erp_loc_a101 (
        CID ,
        CNTRY   
        )
        select 
        replace (CID , '-', '') as CID,
        case 
        when CNTRY = 'DE' then 'Germany'
        when CNTRY in ('USA', 'US') then 'United States'
        when CNTRY is null or CNTRY = '' then 'Not Available'
        else trim(CNTRY)
        end as CNTRY
        from bronze.erp_loc_a101;

--====================================================================================================
    insert into silver.erp_px_cat_g1v2 (
    ID ,
    CAT,
    SUBCAT,
    MAINTENANCE 
    )
    select 
    ID ,
    trim(CAT) as cat ,
    trim(SUBCAT) as subcat,
    trim(MAINTENANCE) as maintenance
    from
    bronze.erp_px_cat_g1v2

--================================================================================================
        SET @end_time = GETDATE();
        PRINT ('Load Completed in: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds');
        
    END TRY
    BEGIN CATCH
        PRINT ('Error occurred: ' + CAST(ERROR_MESSAGE() AS VARCHAR));
    END CATCH
END;
GO