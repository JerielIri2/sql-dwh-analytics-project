/* 
============================================================= 
Create Silver Tables
============================================================= 
Purpose: This script recreates tables in the Silver schema, used to
redefine the DDL structure on the Silver tables
*/

DROP TABLE IF EXISTS silver.crm_customer_info;
CREATE TABLE silver.crm_customer_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE,
    dwh_create_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.crm_product_info;
CREATE TABLE silver.crm_product_info (
    prd_id INT,
    cat_id VARCHAR(50),
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prod_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_customer;
CREATE TABLE silver.erp_customer (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50),
    dwh_create_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_location;
CREATE TABLE silver.erp_location (
    cid VARCHAR(50),
    cntry VARCHAR(50),
    dwh_create_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_category;
CREATE TABLE silver.erp_category (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50),
    dwh_create_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP
);
