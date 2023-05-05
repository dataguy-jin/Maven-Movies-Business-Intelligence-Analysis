USE mavenfuzzyfactory;
-- SELECT DISTINCT device_type FROM website_sessions

SELECT 
		YEAR(ws.created_at) AS yr,
        MONTH(ws.created_at) AS mo,
        COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS mobile_sessions,
        COUNT(DISTINCT CASE WHEN ws.device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) AS desktop_sessions,
        COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders,
        COUNT(DISTINCT CASE WHEN ws.device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders
FROM website_sessions ws
LEFT JOIN orders
	ON orders.website_session_id = ws.website_session_id
WHERE ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand'
		AND ws.created_at < '2012-11-27'
GROUP BY 1,2