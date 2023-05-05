USE mavenfuzzyfactory;
SELECT 
		utm_source,
		utm_campaign,
        http_referer,
        COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE DATE_FORMAT(created_at,'%Y%m%d') < '20120414'
GROUP BY utm_source,
		utm_campaign,
        http_referer
ORDER BY sessions DESC;

