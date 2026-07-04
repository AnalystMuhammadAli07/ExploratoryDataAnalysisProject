----Product Report-----

CREATE VIEW gold.products_report AS 

WITH base_query AS (

SELECT 
s.order_number,
s.sales_amount,
s.quantity,
s.customer_key,
s.order_date,
p.product_name,
p.product_key,
p.category,
p.subcategory,
p.cost
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
)
, product_aggregation AS

(
SELECT 
product_key,
product_name,
category,
subcategory,
cost,
SUM(sales_amount) AS total_sales,
DATEDIFF(month,MIN(order_date),MAX(order_date)) AS life_span,
MAX(order_date) AS last_order_date,
COUNT(DISTINCT order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity,
ROUND(AVG(CAST(sales_amount AS FLOAT)/ NULLIF(quantity,0)),1) AS avg_selling_price
FROM base_query
GROUP BY product_key,
product_name,
category,
subcategory,cost
)

SELECT 
product_key,
product_name,
category,
subcategory,
cost,
last_order_date,
DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_in_months,
CASE WHEN total_sales > 50000 THEN 'High-Performer'
     WHEN total_sales <= 10000 THEN 'Mid-Range'
     ELSE 'Low-Performer'
END AS product_segment,
life_span,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
CASE WHEN total_orders = 0 THEN 0
     ELSE total_sales / total_orders
END AS avg_order_revenue

FROM product_aggregation
