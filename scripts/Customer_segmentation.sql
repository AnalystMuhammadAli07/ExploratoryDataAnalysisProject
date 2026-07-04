-----Customer Segment----
WITH customer_spending AS ( 
SELECT 
c.customer_key,
SUM(s.sales_amount) AS total_spend,
MIN(s.order_date) AS first_order,
MAX(s.order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT 
customer_segment,
COUNT(customer_key) AS customer_count
FROM 

(
SELECT
customer_key,
CASE WHEN lifespan >= 12 AND total_spend > 5000 THEN 'VIP'
     WHEN lifespan >= 12 AND total_spend <= 5000 THEN 'Regular'
     ELSE 'New'
END customer_segment
FROM customer_spending 
) t
GROUP BY customer_segment
ORDER BY customer_count DESC