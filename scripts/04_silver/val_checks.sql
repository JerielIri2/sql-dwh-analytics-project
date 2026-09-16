/*
=============================================================
Data Validation & Quality Checks
=============================================================
Purpose:
    Contains selected queries used to validate data quality, identify
    inconsistencies, and verify transformations before and
    after loading data into the Silver layer.
=============================================================
*/

--Checks NULLS or Duplicates for Primary Key
SELECT 
    cst_id,
    COUNT(*) AS total_rows
FROM bronze.crm_customer_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

--Checks unwanted spaces
SELECT cst_firstname
FROM bronze.crm_customer_info
WHERE cst_firstname <> TRIM(cst_firstname);

--Checks data consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_customer_info;

--Checks NULLS or Duplicates for Primary Key
SELECT 
    cst_id,
    COUNT(*) AS total_rows
FROM silver.crm_customer_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

--Checks unwanted spaces
SELECT cst_firstname
FROM silver.crm_customer_info
WHERE cst_firstname <> TRIM(cst_firstname);

--Checks data consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_customer_info;

--Checks NULLS or Duplicates for Primary Key
SELECT
    prd_id,
    COUNT(*) AS total_rows
FROM bronze.crm_product_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

--Checks NULLS or negative values
SELECT prd_cost
FROM bronze.crm_product_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

--Checks data consistency
SELECT DISTINCT prd_line
FROM bronze.crm_product_info;

--Checks invalid dates I
SELECT *
FROM bronze.crm_product_info
WHERE prd_end_dt < prd_start_dt;

--Checks invalid dates II
SELECT
    sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LENGTH(sls_order_dt::TEXT) <> 8;

--Checks NULLS, 0, or negative values
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
