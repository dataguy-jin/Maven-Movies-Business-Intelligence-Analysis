USE mavenfuzzyfactory;

SELECT 
    MIN(DATE(created_at)) AS week_start,
    -- COUNT(DISTINCT website_session_id) AS num_sessions
    COUNT(DISTINCT CASE device_type
     WHEN 'desktop' THEN website_session_id ELSE NULL
     END) AS dtop_sessions,
    COUNT(DISTINCT CASE device_type
     WHEN 'mobile' THEN website_session_id ELSE NULL
     END)AS mob_sessions
FROM website_sessions 
WHERE created_at < '2012-06-09' AND created_at > '2012-04-15' 
AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), week(created_at) 