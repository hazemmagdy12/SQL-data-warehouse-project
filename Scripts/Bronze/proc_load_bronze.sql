
create or alter procedure bronze.load_bronze
as
begin

declare @start_time datetime
declare @end_time datetime

begin try

print ('==================')
print('Loading Bronze Layer')
print('Truncating table crm_cust_info')


print('Inserting data into crm_cust_info')

set @start_time = GETDATE() ;
--=================================================================
truncate table bronze.crm_cust_info ;

bulk insert bronze.crm_cust_info 
from 'C:\Users\ABC Shop-eg\Downloads\cust_info.csv'
with(
FIRSTROW = 2,
fieldterminator=',',
rowterminator = '\n'
);
--=============================================================================
TRUNCATE TABLE bronze.crm_prd_info;

BULK INSERT bronze.crm_prd_info 
FROM 'C:\Users\ABC Shop-eg\Downloads\prd_info.csv' -- (لو اسم الملف غير كده، عدل اسم الملف هنا)
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

--================================================================================
TRUNCATE TABLE bronze.crm_sales_details;

BULK INSERT bronze.crm_sales_details 
FROM 'C:\Users\ABC Shop-eg\Downloads\sales_details.csv' -- (عدل اسم الملف لو مختلف عندك)
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
--===================================================================================

        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT('Inserting data into bronze.erp_cust_az12');
        BULK INSERT bronze.erp_cust_az12 
        FROM 'C:\Users\ABC Shop-eg\Downloads\CUST_AZ12.csv' -- (اتأكد من المسار واسم الملف)
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n' -- أو '\r\n' لو ضرب معاك إيرور السطر الجديد
        );
--=======================================================================================
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT('Inserting data into bronze.erp_loc_a101');
        BULK INSERT bronze.erp_loc_a101 
        FROM 'C:\Users\ABC Shop-eg\Downloads\LOC_A101.csv' -- (اتأكد من المسار لو مختلف)
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n' -- (أو '\r\n' لو ويندوز عصلج معاك)
        );
--===========================================================================================
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT('Inserting data into bronze.erp_px_cat_g1v2');
        BULK INSERT bronze.erp_px_cat_g1v2 
        FROM 'C:\Users\ABC Shop-eg\Downloads\PX_CAT_G1V2.csv' -- (اتأكد من اسم الملف والمسار)
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n' -- (أو '\r\n')
        );
--==================================================================================================
set @end_time = GETDATE();
print('Load Completed in: ' + cast(datediff(second, @start_time , @end_time) as varchar));


end try
begin catch

print ('   Error occurred during loading bronze layer   '+cast(ERROR_MESSAGE() as varchar));

end catch

end;
go