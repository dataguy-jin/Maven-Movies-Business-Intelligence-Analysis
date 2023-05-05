USE mavenfuzzyfactory;

SELECT 
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT order_id) AS num_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd-cogs_usd) AS total_margin
FROM orders
WHERE created_at < '2013-1-4'
GROUP BY 1,2
