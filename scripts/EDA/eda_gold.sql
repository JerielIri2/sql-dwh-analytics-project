/*
===============================================================================
Exploratory Data Analysis (EDA)
===============================================================================
Purpose:
    The queries below were used to explore and understand the business data
    within the Gold Layer of the data warehouse.

    The analysis includes:
        - Database Exploration
        - Dimension Exploration
        - Date Exploration
        - Measure Exploration
        - Magnitude Analysis
        - Ranking Analysis
===============================================================================
*/

---------------------------------------------------------
--Database Exploration
---------------------------------------------------------

--Explore all database objects (e.g. number of tables)
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Explore all database columns (e.g. naming conventions)
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'dim_customers';

---------------------------------------------------------
--Dimension Exploration
---------------------------------------------------------

-- Explore customer locations
SELECT DISTINCT 
    country
FROM gold.dim_customers;

-- Explore product categories and hierarchy (e.g. divisions, row counts)
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY 1, 2, 3;

---------------------------------------------------------
--Date Exploration
---------------------------------------------------------

-- Determine the first and last order dates
-- Determine the number of years of available sales data
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    EXTRACT(
        YEAR FROM AGE(MAX(order_date)::date, MIN(order_date)::date)
    ) AS years_of_sales
FROM gold.fact_sales

-- Calculate customer age (e.g. youngest and older customer)
SELECT
    MIN(birth_date) AS oldest_birth_date,
    MAX(birth_date) AS youngest_birth_date,
    NOW()::date - INTERVAL '12 years' AS approximate_load_date, -- to calculate customer age based on the approximate last data load date
    EXTRACT(YEAR FROM AGE(NOW()::date - INTERVAL '12 years', MIN(birth_date)::date)) AS oldest_customer_age,
    EXTRACT(YEAR FROM AGE(NOW()::date - INTERVAL '12 years', MAX(birth_date)::date)) AS youngest_customer_age
FROM gold.dim_customers

---------------------------------------------------------
--Measure Exploration
---------------------------------------------------------

-- Calculate total sales
-- Calculate total quantity of items sold
-- Calculate average selling price
-- Calculate total number of orders
-- Calculate total number of products
-- Calculate total number of customers with orders

SELECT
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(AVG(price), 1) AS avg_price,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(product_key) AS total_products,
    COUNT(DISTINCT customer_key) AS total_customers
    --to_char(SUM(sales_amount), 'FM99,999,999') AS total_sales
FROM gold.fact_sales;

-- Generate a report of key business metrics

SELECT
    'Total Sales' AS measure_name,
    SUM(sales_amount) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT
    'Total Quantity' AS measure_name,
    SUM(quantity) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 
    'Average Price' AS measure_name,
    ROUND(AVG(price)) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT
    'Total Orders' AS measure_name,
    COUNT(DISTINCT order_number) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT
    'Total Products' AS measure_name,
    COUNT(product_key) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT
    'Total Customers' AS measure_name,
    COUNT(DISTINCT customer_key) AS measure_value
FROM gold.fact_sales;

---------------------------------------------------------
--Magnitude Analysis
---------------------------------------------------------

-- Calculate total customers by country
SELECT
    country,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY COUNT(DISTINCT customer_key) DESC;

-- Calculate total customers and percentage of total by gender
SELECT
    gender,
    COUNT(DISTINCT customer_key) AS total_customers,
    ROUND(COUNT(DISTINCT customer_key) * 100 / SUM(COUNT(DISTINCT customer_key)) OVER(), 2) AS pct_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Calculate total products by category
SELECT 
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Calculate average product cost by category
SELECT 
    category,
    ROUND(AVG(product_cost), 1) AS avg_product_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC;

-- Calculate total revenue by category
SELECT 
    dp.category,
    SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp 
ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY total_sales DESC;

-- Calculate total revenue by customer
SELECT
    dc.customer_key,
    dc.first_name,
    dc.last_name,
    SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY 
    dc.customer_key,
    dc.first_name, 
    dc.last_name
ORDER BY total_sales DESC;

-- Analyze the distribution of sold items by country
SELECT
    dc.country,
    SUM(fs.quantity) AS total_items_sold
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.country
ORDER BY total_items_sold DESC;

---------------------------------------------------------
--Ranking Analysis
---------------------------------------------------------

-- Identify the top 5 products by revenue
SELECT
    dp.product_key,
    dp.product_name,
    SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp 
ON fs.product_key = dp.product_key
GROUP BY 
    dp.product_key,
    dp.product_name
ORDER BY total_sales DESC
LIMIT 5;

-- Identify the top 5 products by revenue using window functions
SELECT *
FROM (
    SELECT
        dp.product_key,
        dp.product_name,
        SUM(fs.sales_amount) AS total_sales,
        ROW_NUMBER() OVER(ORDER BY SUM(fs.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_products dp 
    ON fs.product_key = dp.product_key
    GROUP BY 
        dp.product_key,
        dp.product_name
) t
WHERE rank_products <= 5;

-- Identify the 5 lowest-performing products by sales
SELECT
    dp.product_key,
    dp.product_name,
    SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp 
ON fs.product_key = dp.product_key
GROUP BY 
    dp.product_key,
    dp.product_name
ORDER BY total_sales ASC
LIMIT 5;

-- Identify the top 10 customers by revenue
SELECT
    dc.customer_key,
    dc.first_name,
    dc.last_name,
    SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY 
    dc.customer_key,
    dc.first_name, 
    dc.last_name
ORDER BY total_sales DESC
LIMIT 10;

-- Identify the 3 customers with the fewest orders
SELECT
    dc.customer_key,
    dc.first_name,
    dc.last_name,
    COUNT(DISTINCT(fs.order_number)) AS total_orders
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY 
    dc.customer_key,
    dc.first_name, 
    dc.last_name
ORDER BY total_orders
LIMIT 3;
