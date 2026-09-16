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
if OBJECT_ID ('bronze.crm_cust_info' , 'U') is  not null
begin
drop table bronze.crm_cust_info
end;
go
create table bronze.crm_cust_info (
id int,
key_table NVARCHAR(50),
create_date date
);
go


