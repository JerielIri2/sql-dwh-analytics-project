/*
=============================================================
Gold Layer — Star Schema Views
=============================================================
Purpose:
    Creates business-ready dimension and fact views from the
    Silver layer, forming a Star Schema for analytics and
    reporting. The views apply transformations, integrate
    related data, and can be queried directly by consumers.
=============================================================
*/

CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    lo.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE WHEN ci.cst_gndr <> 'Unknown' THEN ci.cst_gndr --CRM is the master source for gender
    ELSE COALESCE(cu.gen, 'Unknown')
    END AS gender,
    cu.bdate AS birth_date,
    ci.cst_create_date AS create_date
FROM silver.crm_customer_info ci
LEFT JOIN silver.erp_customer cu
ON ci.cst_key = cu.cid
LEFT JOIN silver.erp_location lo
ON ci.cst_key = lo.cid;

---------------------------------------

CREATE OR REPLACE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER(ORDER BY prd_start_dt, prd_key) AS product_key,
    pi.prd_id AS product_id,
    pi.prd_key AS product_number,
    pi.prd_nm AS product_name,
    pi.cat_id AS category_id,
    ca.cat AS category,
    ca.subcat AS subcategory,
    ca.maintenance AS maintenance,
    pi.prd_cost AS product_cost,
    pi.prd_line AS product_line,
    pi.prd_start_dt AS product_start_date
FROM silver.crm_product_info pi
LEFT JOIN silver.erp_category ca
ON pi.cat_id = ca.id
WHERE pi.prd_end_dt IS NULL; --filters out historical data, contains current data only

---------------------------------------

CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    dp.product_key AS product_key,
    dc.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS ship_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price 
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products dp
ON sd.sls_prod_key = dp.product_number
LEFT JOIN gold.dim_customers dc
ON sd.sls_cust_id = dc.customer_id;


