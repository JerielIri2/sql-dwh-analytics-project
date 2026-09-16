/* 
============================================================= 
Create Bronze Tables (PostgreSQL)
============================================================= 
Purpose: This script recreates tables in the Bronze schema, used to
redefine the DDL structure on the Bronze tables
*/


DROP TABLE IF EXISTS bronze.crm_customer_info;
CREATE TABLE bronze.crm_customer_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);

DROP TABLE IF EXISTS bronze.crm_product_info;
CREATE TABLE bronze.crm_product_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt TIMESTAMP,
    prd_end_dt TIMESTAMP
);

DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prod_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

DROP TABLE IF EXISTS bronze.erp_customer;
CREATE TABLE bronze.erp_customer (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_location;
CREATE TABLE bronze.erp_location (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_category;
CREATE TABLE bronze.erp_category (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);

/*
=============================================================
Load Bronze Layer
=============================================================
Purpose:
    Truncates and reloads all Bronze tables from the source CSV
    files, providing a fresh copy of the raw source data.
*/
CREATE OR REPLACE PROCEDURE bronze.load_bronze AS
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE '===============================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '===============================================';

    RAISE NOTICE '-----------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '-----------------------------------------------';
    TRUNCATE TABLE bronze.crm_customer_info;
    COPY bronze.crm_customer_info 
    FROM '[file_path]...cust_info.csv' 
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    
    TRUNCATE TABLE bronze.crm_product_info;
    COPY bronze.crm_product_info 
    FROM '[file_path]...prd_info.csv' 
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    
    TRUNCATE TABLE bronze.crm_sales_details;
    COPY bronze.crm_sales_details 
    FROM '[file_path]...sales_details.csv' 
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    
    TRUNCATE TABLE bronze.erp_customer;
    COPY bronze.erp_customer 
    FROM '[file_path]...CUST_AZ12.csv' 
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    
    TRUNCATE TABLE bronze.erp_location;
    COPY bronze.erp_location 
    FROM '[file_path]...LOC_A101.csv' 
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
    
    TRUNCATE TABLE bronze.erp_category;
    COPY bronze.erp_category 
    FROM '[file_path]...PX_CAT_G1V2.csv' 
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
END
$$;
    
-- Alternative: "PSQL Tool" instead of the "Query Tool" to solve "permission" issues:

TRUNCATE TABLE bronze.crm_customer_info;
\copy bronze.crm_customer_info FROM '[file_path]...cust_info.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',');

TRUNCATE TABLE bronze.crm_product_info;
\copy bronze.crm_product_info FROM '[file_path]...prd_info.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',');

TRUNCATE TABLE bronze.crm_sales_details;
\copy bronze.crm_sales_details FROM '[file_path]...sales_details.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',');

TRUNCATE TABLE bronze.erp_customer;
\copy bronze.erp_customer FROM '[file_path]...CUST_AZ12.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',');

TRUNCATE TABLE bronze.erp_location;
\copy bronze.erp_location FROM '[file_path]...LOC_A101.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',');

TRUNCATE TABLE bronze.erp_category;
\copy bronze.erp_category FROM '[file_path]...PX_CAT_G1V2.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',');












