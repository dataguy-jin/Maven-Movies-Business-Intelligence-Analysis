USE mavenfuzzyfactory;

SELECT 
        YEAR(ws.created_at) AS yr,
        MONTH(ws.created_at) AS mo,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders
	ON orders.website_session_id = ws.website_session_id
WHERE ws.utm_source = 'gsearch'
		AND ws.created_at < '2012-11-27'
GROUP BY 1,2