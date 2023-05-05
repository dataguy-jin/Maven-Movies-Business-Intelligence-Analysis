USE mavenfuzzyfactory;

SELECT 
		ws.device_type,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT os.order_id) AS orders, 
        COUNT(DISTINCT os.order_id)/COUNT(DISTINCT ws.website_session_id) AS session_to_order_conv_rate
FROM website_sessions ws
LEFT JOIN orders os
ON ws.website_session_id = os.website_session_id
WHERE ws.created_at < '2012-5-11' 
AND ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand'
GROUP BY 1
