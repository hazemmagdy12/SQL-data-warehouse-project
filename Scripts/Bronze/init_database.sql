use master 
if NOT EXISTS (select 1 from  sys.databases where name = 'data_warehouse')
begin
create database data_warehouse 
end;
go
use data_warehouse;
go
if NOT EXISTS (select 1 from  sys.schemas where name = 'bronze')
begin
exec ('create schema bronze') 
end;
go
if NOT EXISTS (select 1 from  sys.schemas where name = 'silver')
begin
exec ('create schema silver') 
end;
go
if NOT EXISTS (select 1 from  sys.schemas where name = 'gold')
begin
exec ('create schema gold') 
end;
go

--###########################################################################################3

if OBJECT_ID ('bronze.crm_cust_info' , 'U') is  not null
begin
drop table bronze.crm_cust_info
end;
go
create table bronze.crm_cust_info (
cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);
go

--############################################################################

IF OBJECT_ID ('bronze.crm_prd_info' , 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.crm_prd_info;
END;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(100),
    prd_cost DECIMAL(10,2), -- استخدمنا دي عشان لو فيه أرقام عشرية في التكلفة مستقبلاً
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);
GO

--#######################################################################

IF OBJECT_ID ('bronze.crm_sales_details' , 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.crm_sales_details;
END;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,   -- هنخليه INT مؤقتاً عشان مطبق نفس صيغة الملف الخام، وهنظبطه في السيلفر خليه تاريخ DATE
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales DECIMAL(10,2),
    sls_quantity INT,
    sls_price DECIMAL(10,2)
);
GO

--==================================================================================================================
IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_cust_az12;
END;
GO

CREATE TABLE bronze.erp_cust_az12 (
    CID NVARCHAR(50),
    BDATE DATE,      -- هنعمله DATE عشان نستقبل التواريخ
    GEN NVARCHAR(50)
);
GO

--=============================================================================
IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_loc_a101;
END;
GO

CREATE TABLE bronze.erp_loc_a101 (
    CID NVARCHAR(50),
    CNTRY NVARCHAR(50)
);
GO
--===================================================
IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_px_cat_g1v2;
END;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50)
);
GO

