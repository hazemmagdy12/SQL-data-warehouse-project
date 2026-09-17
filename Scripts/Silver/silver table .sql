

if OBJECT_ID('silver.crm_cust_info', 'U') is not null
begin
drop table silver.crm_cust_info
end;
go
create table silver.crm_cust_info (
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_marital_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE,

dwh_create_date datetime2 default getdate()

);

--##################################################################################

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.crm_prd_info
END;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),       -- العمود الجديد بتاع الفئة (أول 5 حروف)
    prd_key NVARCHAR(50),      -- كود المنتج الصافي (من الحرف السابع للآخر)
    prd_nm NVARCHAR(100),
    prd_cost DECIMAL(10,2),    
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    
    -- عمود البصمة (Metadata)
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
--#####################################################################################

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.crm_sales_details
END;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt date,   -- هنخليه INT مؤقتاً عشان مطبق نفس صيغة الملف الخام، وهنظبطه في السيلفر خليه تاريخ DATE
    sls_ship_dt date,
    sls_due_dt date,
    sls_sales DECIMAL(10,2),
    sls_quantity INT,
    sls_price DECIMAL(10,2),
    
    -- عمود البصمة (Metadata)
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
--==============================================================================
IF OBJECT_ID ('silver.erp_cust_az12', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.erp_cust_az12;
END;
GO

CREATE TABLE silver.erp_cust_az12 (
    CID NVARCHAR(50),
    BDATE DATE,      -- هنعمله DATE عشان نستقبل التواريخ
    GEN NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO
--========================================================================
IF OBJECT_ID ('silver.erp_loc_a101', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.erp_loc_a101;
END;
GO

CREATE TABLE silver.erp_loc_a101 (
    CID NVARCHAR(50),
    CNTRY NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO
--=================================================================
IF OBJECT_ID ('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.erp_px_cat_g1v2;
END;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO
--========================================================================
IF OBJECT_ID ('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.erp_px_cat_g1v2;
END;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO