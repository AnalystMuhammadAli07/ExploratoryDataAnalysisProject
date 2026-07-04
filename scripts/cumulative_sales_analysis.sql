SELECT 
DATETRUNC(month,order_date),
SUM(sales_amount)
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month,order_date)
ORDER BY DATETRUNC(month,order_date)


SELECT 
order_date,
total_sales,
avg_price,
SUM(total_sales) OVER (PARTITION BY DATETRUNC(year,order_date) ORDER BY order_date) AS running_total,
AVG(avg_price) OVER (PARTITION BY DATETRUNC(year,order_date) ORDER BY order_date) AS running_average
FROM
(
SELECT 
DATETRUNC(month,order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month,order_date)
) t

SELECT * FROM gold.fact_sales

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
current_sales - AVG (current_sales) OVER (PARTITION BY product_name) AS diff_avg
FROM yearly_product_sales
ORDER BY product_name , order_year