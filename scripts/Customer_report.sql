
CREATE VIEW gold.customer_report AS 

WITH base_query AS (


SELECT 
s.order_number,
s.product_key,
s.order_date,
s.sales_amount,
s.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ',c.last_name) AS customer_name,
DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
WHERE order_date IS NOT NULL
)
, customer_seggregation AS (

SELECT
customer_key,
customer_number,
customer_name,
age,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT order_number ) AS total_orders,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order_date,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY
customer_key,
customer_number,
customer_name,
age 
)

SELECT 
customer_key,
customer_number,
customer_name,
age,
total_sales,
total_orders,
total_quantity,
total_products,
lifespan,
CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
     WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
     ELSE 'New'
END customer_segment,
CASE WHEN age < 30 THEN 'Under 30'
     WHEN age BETWEEN 30 AND 39 THEN '30-39'
     WHEN age BETWEEN 40 AND 49 THEN '40-49'
     WHEN age BETWEEN 50 AND 59 THEN '50-59'
ELSE 'Above 60'
END age_bracket,
last_order_date,
DATEDIFF(month, last_order_date,GETDATE()) AS recency,
CASE WHEN total_orders = 0 THEN 0
ELSE
total_sales / total_orders 
END avg_order_value
FROM customer_seggregation

