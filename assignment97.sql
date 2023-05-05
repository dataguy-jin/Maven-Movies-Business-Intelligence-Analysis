USE mavenfuzzyfactory;

SELECT 
	ws.is_repeat_session,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT os.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate,
    SUM(os.price_usd)/COUNT(DISTINCT ws.website_session_id) AS rev_per_session
FROM website_sessions ws
	LEFT JOIN orders os
		ON os.website_session_id = ws.website_session_id
WHERE ws.created_at BETWEEN '2014-1-1' AND '2014-11-8'
GROUP BY 1
	
        