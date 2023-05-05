USE mavenfuzzyfactory;
 SELECT DISTINCT utm_campaign FROM website_sessions ;	

SELECT 
        YEAR(ws.created_at) AS yr,
        MONTH(ws.created_at) AS mo,
        COUNT(DISTINCT CASE WHEN ws.utm_source = 'gsearch' THEN ws.website_session_id ELSE NULL END) AS gsearch_sessions,
        COUNT(DISTINCT CASE WHEN ws.utm_source = 'bsearch' THEN ws.website_session_id ELSE NULL END) AS bsearch_sessions,
        COUNT(DISTINCT CASE WHEN ws.utm_source IS NULL AND http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS organic_sessions,
        COUNT(DISTINCT CASE WHEN ws.utm_source IS NULL AND http_referer IS NULL THEN ws.website_session_id ELSE NULL END) AS direct_sessions
FROM website_sessions ws
LEFT JOIN orders
	ON orders.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-11-27'
GROUP BY 1,2