----cost segments----
WITH product_segment AS (
SELECT 
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below $100'
     WHEN cost BETWEEN 100 AND 500 THEN '$100 - $500'
     WHEN cost BETWEEN 500 AND 1000 THEN '$500 - $1000'
     ELSE 'Above $1000'
END cost_segment
FROM gold.dim_products
)

SELECT 
cost_segment,
COUNT(product_key) AS total_products
FROM product_segment
GROUP BY cost_segment
ORDER BY total_products DESC
