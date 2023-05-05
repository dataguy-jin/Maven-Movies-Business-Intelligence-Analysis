USE mavenfuzzyfactory;
SELECT 
	YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT os.order_id) AS orders,
    COUNT(DISTINCT os.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate,
    SUM(os.price_usd)/COUNT(DISTINCT ws.website_session_id) AS revenue_per_session,
    COUNT(DISTINCT CASE WHEN os.primary_product_id = 1 THEN os.order_id ELSE NULL END) AS product_one_orders,
    COUNT(DISTINCT CASE WHEN os.primary_product_id = 2 THEN os.order_id ELSE NULL END) AS product_two_orders
    -- COUNT(DISTINCT order_id) AS num_of_sales,
    -- SUM(price_usd) AS total_revenue,
    -- SUM(price_usd-cogs_usd) AS total_margin
FROM website_sessions ws
LEFT JOIN orders os
	ON ws.website_session_id = os.website_session_id
WHERE ws.created_at between '2012-4-1' AND '2013-4-1'
GROUP BY 1,2
