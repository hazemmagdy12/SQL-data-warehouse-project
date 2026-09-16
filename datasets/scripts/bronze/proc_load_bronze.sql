
create or alter procedure bronze.load_bronze
as
begin

declare @start_time datetime
declare @end_time datetime

begin try

print ('==================')
print('Loading Bronze Layer')
print('Truncating table crm_cust_info')

truncate table bronze.crm_cust_info ;

print('Inserting data into crm_cust_info')

set @start_time = GETDATE() ;

bulk insert bronze.crm_cust_info 
from 'C:\datasets\crm_cust_info.csv'
with(
FIRSTROW = 2,
fieldterminator=',',
rowterminator = '\n'
);
set @end_time = GETDATE();

print('Load Completed in: ' + cast(datediff(second, @start_time , @end_time) as varchar));


end try
begin catch

print ('   Error occurred during loading bronze layer   '+cast(ERROR_MESSAGE() as varchar));

end catch

end;
go