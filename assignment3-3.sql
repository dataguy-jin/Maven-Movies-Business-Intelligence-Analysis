USE mavenfuzzyfactory;
-- SELECT DISTINCT device_type FROM website_sessions;
SELECT
        ws.device_type,
		ws.utm_source,
		-- COUNT(website_session_id) AS sessions,
		COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT orders.order_id) AS orders,
        COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate
FROM website_sessions ws
LEFT JOIN orders 
ON ws.website_session_id = orders.website_session_id
WHERE ws.created_at < '2012-9-19'
	  AND ws.created_at > '2012-08-22'
      AND ws.utm_campaign = 'nonbrand'
      AND ws.utm_source IN('gsearch','bsearch')
GROUP BY 1,2
