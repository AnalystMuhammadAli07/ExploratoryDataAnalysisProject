---Sales Performance----


WITH yearly_product_sales AS (
    SELECT 
        YEAR(s.order_date) AS order_year,
        p.product_name,
        SUM(s.sales_amount) AS current_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p 
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY YEAR(s.order_date), p.product_name
)
SELECT 
order_year,
product_name,
current_sales,
AVG (current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG (current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG (current_sales) OVER (PARTITION BY product_name) > 0 THEN 'above avg'
WHEN current_sales - AVG (current_sales) OVER (PARTITION BY product_name) < 0 THEN 'below avg'
ELSE 'Avg'
END avg_change,
LAG(current_sales) OVER ( PARTITION BY product_name ORDER BY order_year) AS py_sales,
CASE 
WHEN current_sales > LAG(current_sales) OVER ( PARTITION BY product_name ORDER BY order_year) THEN 'increasing'
WHEN current_sales < LAG(current_sales) OVER ( PARTITION BY product_name ORDER BY order_year) THEN 'decreasing'
ELSE 'constant'
END py_change
FROM yearly_product_sales
ORDER BY product_name , order_year