/*
====================================================
Product Report
====================================================
Purpose:
    Consolidates key product metrics and 
    behavior into a single, analyst-ready report.

    This report also provides a faster alternative for analysts
    to retrieve key product data in one place rather than
    querying and combining multiple tables separately.

Highlights:
    1. Retrieves essential product attributes and transaction details.
    2. Segments products by revenue
       (High-Performers, Mid-Range, Low-Performers).
    3. Aggregates product-level metrics:
       - Total orders
       - Total sales
       - Total quantity purchased
       - Total unique customers
       - Lifespan (months)
    4. Calculates key product KPIs:
       - Recency (months since last sales)
       - Average order revenue (AOR)
       - Average monthly revenue
*/

CREATE VIEW gold.report_products AS
WITH base_query AS (
/*-----------------------------------------------------------------------
1) Base Query: Combines product and sales data and retrieves the
   core fields needed for the product report.
-----------------------------------------------------------------------*/
SELECT
    s.order_number,
    s.order_date,
    s.customer_key,
    s.sales_amount,
    s.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.product_cost
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL --considers valid sales dates only
),

product_aggregation AS (
/*-----------------------------------------------------------------------
2) Product Aggregations: Aggregates sales and purchasing activity at
   the product level and calculates key product metrics.
-----------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    product_cost,
     --customer lifespan in months, calculate years × 12 + months
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
    + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan,
    MAX(order_date) AS last_sales_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(AVG(sales_amount::numeric) / NULLIF(quantity, 0), 1) AS avg_selling_price
FROM base_query
GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    quantity,
    product_cost
)
/*-----------------------------------------------------------------------
3) Final Report: Applies product segmentation and calculates key KPIs
   to produce the final analyst-ready product report.
-----------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    product_cost,
    lifespan,
    last_sales_date,
    EXTRACT(YEAR FROM AGE(NOW(), last_sales_date)) * 12
    + EXTRACT(MONTH FROM AGE(NOW(), last_sales_date)) AS recency_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low_Performer'
    END AS product_segment,
    total_orders,
    total_customers,
    total_sales,
    total_quantity,
    avg_selling_price,
    --compute average order revenue (AOR)
    CASE WHEN total_orders = 0 THEN 0
         ELSE total_sales / total_orders
    END AS avg_order_revenue,
    --compute average monthly revenue
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE ROUND(total_sales / lifespan, 2)
    END AS avg_monthly_revenue
FROM product_aggregation;
