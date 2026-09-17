create or alter view gold.dim_cust as
select 
ROW_NUMBER() over (order by c.cst_key desc) as customer_key,
c.cst_id as customer_id,
c.cst_key as customer_number ,
c.cst_firstname as first_name ,
c.cst_lastname as last_name ,
c.cst_marital_status as marital_status ,
case
when c.cst_gndr = 'Unknown' or c.cst_gndr = 'Not Available' then coalesce (ec.GEN, 'Unkown')
else c.cst_gndr 
end as gendr,
c.cst_create_date as create_date,
l.CNTRY as country,
ec.BDATE as birthdate

from silver.crm_cust_info as c
left join 
silver.erp_cust_az12 as ec on c.cst_key = ec.CID
left join 
silver.erp_loc_a101 as l on c.cst_key = l.CID;
go
--==========================================================================================================
create or alter view gold.dim_prod as 
select 
ROW_NUMBER() over (order by i.prd_key desc) as product_code,
i.prd_id as product_number   , 
i.cat_id as category_id, 
i.prd_key as product_key, 
i.prd_nm as product_name, 
i.prd_cost as product_cost, 
i.prd_line as product_line, 
i.prd_start_dt as product_start_date, 
c.cat as category,
c.subcat as subcategory,
c.maintenance
from silver.crm_prd_info as i
left join 
silver.erp_px_cat_g1v2 as c on i.cat_id=c.ID
where i.prd_end_dt is null;
go
--============================================================
create or alter view gold.fact_sales as 
select
p.product_code,
c.customer_key,
s.sls_ord_num  as order_number,

s.sls_order_dt as order_date, 
s.sls_ship_dt as shiping_date,
sls_due_dt as due_date,

sls_sales  as sales,
sls_quantity  as quantity,
sls_price as price

from
silver.crm_sales_details as s

left join
gold.dim_cust as c on c.customer_id = s.sls_cust_id

left join 
gold.dim_prod as p on p.product_number = s.sls_prd_key







