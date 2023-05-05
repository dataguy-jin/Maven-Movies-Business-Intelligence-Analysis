USE mavenfuzzyfactory;

SELECT 
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT os.order_id) AS orders, 
        COUNT(DISTINCT os.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate
FROM website_sessions ws
LEFT JOIN orders os
ON ws.website_session_id = os.website_session_id
WHERE DATE_FORMAT(ws.created_at,'%Y%m%d') < '20120414'
GROUP BY ws.utm_source,
		ws.utm_campaign,
        ws.http_referer
ORDER BY sessions DESC;
