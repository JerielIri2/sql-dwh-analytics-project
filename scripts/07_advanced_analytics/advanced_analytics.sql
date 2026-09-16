/*
===============================================================================
Advanced Analytics
===============================================================================
Purpose:
    The queries below apply advanced analytical techniques to answer common
    business questions and uncover trends, patterns, and performance insights.

    The analysis is organized into the following areas:
    1. Changes Over Time
    2. Cumulative Analysis
    3. Performance Analysis
    4. Part-to-Whole Analysis
    5. Data Segmentation Analysis
===============================================================================
*/

-------------------------------------------------------
-- 1. Changes-Over-Time
-------------------------------------------------------

-- Analyze sales and customer trends by year and month.

SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    EXTRACT(YEAR FROM order_date), 
    EXTRACT(MONTH FROM order_date)
ORDER BY 
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date);
------------------------------------------------
SELECT
    DATE_TRUNC('YEAR', order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    DATE_TRUNC('YEAR', order_date)
ORDER BY 
    DATE_TRUNC('YEAR', order_date);
------------------------------------------------
SELECT
    to_char(order_date, 'yyyy-mm') AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    to_char(order_date, 'yyyy-mm')
ORDER BY 
    to_char(order_date, 'yyyy-mm');

-------------------------------------------------------
-- 2. Cumulative Analysis
-------------------------------------------------------

-- Calculate monthly sales and running sales totals over time.

SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales,
    ROUND(AVG(avg_price) OVER(ORDER BY order_date)) AS moving_avg_price
FROM
(
    SELECT
        to_char(order_date, 'yyyy-mm') AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY to_char(order_date, 'yyyy-mm')
) AS  t
ORDER BY running_total_sales;

-------------------------------------------------------
-- 3. Performance Analysis
-------------------------------------------------------

/* - Analyze yearly product performance by comparing each product's sales
    against its average sales performance and previous year's sales (YoY) */

WITH yearly_product_sales AS (
    SELECT
        EXTRACT(YEAR FROM s.order_date) AS order_year,
        p.product_name AS product_name,
        SUM(s.sales_amount) AS current_sales 
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY 
        order_year,
        p.product_name
)

SELECT 
    order_year,
    product_name,
    current_sales,
    ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) AS avg_product_sales,
    current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) AS avg_diff,
    CASE WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) < 0 THEN 'Below Avg'
         WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) > 0 THEN 'Above Avg'
         ELSE 'Avg'
    END AS avg_change,
    LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS prev_sales,
    current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS prev_diff,
    CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
         WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
         ELSE 'No Change'
    END AS prev_change
FROM yearly_product_sales
ORDER BY
    product_name,
    order_year

-------------------------------------------------------
-- 4. Part-to-Whole Analysis
-------------------------------------------------------

--Determine which product categories contribute the most to overall sales.

WITH category_sales AS (
    SELECT
        p.category,
        SUM(s.sales_amount) AS total_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
    GROUP BY p.category
)

SELECT
    category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    CONCAT(ROUND((total_sales * 100) / SUM(total_sales) OVER(), 1), '%') AS pct_of_sales
FROM category_sales
ORDER BY total_sales DESC;

-------------------------------------------------------
-- 5. Data Segmentation Analysis
-------------------------------------------------------

--Segment products into cost ranges and analyze the number of products within each range

WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        product_cost,
        CASE WHEN product_cost < 100 THEN 'Below 100'
            WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN product_cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)

SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/*
- Segment customers based on spending behavior:
     * VIP: At least 12 months of history and spending more than $5,000.
     * Regular: At least 12 months of history and spending $5,000 or less.
     * New: Less than 12 months of history.
    - Calculate the total number of customers within each segment.
*/

WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(s.sales_amount) AS total_spending,
        MIN(s.order_date) AS first_order,
        MAX(s.order_date) AS last_order,
        EXTRACT(YEAR FROM AGE(MAX(s.order_date), MIN(s.order_date))) * 12
        + EXTRACT(MONTH FROM AGE(MAX(s.order_date), MIN(s.order_date))) AS lifespan --customer lifespan in months, calculate years × 12 + months
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
    GROUP BY c.customer_key
)

SELECT
    customer_segments,
    COUNT(customer_key) AS customer_count
FROM (
    SELECT
        customer_key,
        total_spending,
        lifespan,
        CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
             WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
             ELSE 'New'
        END AS customer_segments
    FROM customer_spending
) AS t
GROUP BY customer_segments
ORDER BY customer_count DESC;
