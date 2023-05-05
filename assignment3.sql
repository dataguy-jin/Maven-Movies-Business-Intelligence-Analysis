SELECT 
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS num_sessions
FROM website_sessions 
WHERE created_at < '2012-5-10' 
AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), week(created_at) 