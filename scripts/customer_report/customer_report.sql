/*
====================================================
Customer Report
====================================================
Purpose:
    Consolidates key customer metrics, purchasing behavior,
    and segmentation into a single, analyst-ready report.

    This report also provides a faster alternative for analysts
    to retrieve key customer data in one place rather than
    querying and combining multiple tables separately.

Highlights:
    1. Retrieves essential customer attributes and transaction details.
    2. Segments customers by age group and customer segment
       (VIP, Regular, New).
    3. Aggregates customer-level metrics:
       - Total orders
       - Total sales
       - Total quantity purchased
       - Total products purchased
       - Customer lifespan (months)
    4. Calculates key customer KPIs:
       - Recency (months since last order)
       - Average order value (AOV)
       - Average monthly spend
*/

CREATE VIEW gold.report_customers AS
WITH base_query AS (
/*-----------------------------------------------------------------------
1) Base Query: Combines customer and sales data and retrieves the
   core fields needed for the customer report.
-----------------------------------------------------------------------*/
    SELECT 
        s.order_number,
        s.product_key,
        s.order_date,
        s.sales_amount,
        s.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        EXTRACT(YEAR FROM NOW()) - EXTRACT(YEAR FROM c.birth_date) AS age
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
    WHERE s.order_date IS NOT NULL
)
, customer_aggregation AS (
/*-----------------------------------------------------------------------
2) Customer Aggregations: Aggregates sales and purchasing activity at
   the customer level and calculates key customer metrics.
-----------------------------------------------------------------------*/
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    --customer lifespan in months, calculate years × 12 + months
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
    + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan
FROM base_query
GROUP BY
    customer_key,
    customer_number,
    customer_name,
    age
)
/*-----------------------------------------------------------------------
3) Final Report: Applies customer segmentation and calculates key KPIs
   to produce the final analyst-ready customer report.
-----------------------------------------------------------------------*/
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 Above'
    END AS age_group,
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segments,
    last_order_date,
    --recency in months, calculate years × 12 + months
    EXTRACT(YEAR FROM AGE(NOW(), last_order_date)) * 12
    + EXTRACT(MONTH FROM AGE(NOW(), last_order_date)) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    --compute average order value (AVO)
    CASE WHEN total_orders = 0 THEN 0
         ELSE total_sales / total_orders
    END AS avg_order_value,
    --compute average monthly spend
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE ROUND(total_sales / lifespan, 2)
    END AS avg_monthly_spend
FROM customer_aggregation
