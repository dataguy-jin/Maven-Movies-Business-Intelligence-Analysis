USE mavenfuzzyfactory;
-- SELECT DISTINCT utm_campaign FROM website_sessions ;	

SELECT 
        YEAR(ws.created_at) AS yr,
        MONTH(ws.created_at) AS mo,
        COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS non_brand_sessions,
        COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS orders,
        COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_sessions,
		COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders
FROM website_sessions ws
LEFT JOIN orders
	ON orders.website_session_id = ws.website_session_id
WHERE ws.utm_source = 'gsearch' 
	AND ws.created_at < '2012-11-27'
GROUP BY 1,2