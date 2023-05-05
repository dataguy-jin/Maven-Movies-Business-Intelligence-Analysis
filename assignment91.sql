USE mavenfuzzyfactory;

WITH session_repeat AS(
SELECT 
	ns.user_id,
    ns.new_session_id,
    ws.website_session_id
FROM
( -- new sessions 
SELECT 
	user_id,
    website_session_id AS new_session_id
FROM website_sessions 
	WHERE created_at BETWEEN '2014-1-1' AND '2014-11-1'
		AND is_repeat_session = 0
) AS ns
LEFT JOIN website_sessions ws
	ON ws.user_id = ns.user_id
		AND ws.is_repeat_session = 1
        AND ws.website_session_id > ns.new_session_id 
        AND ws.created_at BETWEEN '2014-1-1' AND '2014-11-1'
)

SELECT 
	repeat_sessions,
    COUNT(DISTINCT user_id) AS users
FROM (
SELECT 
	user_id,
    COUNT(DISTINCT new_session_id) AS new_sessions,
    COUNT(DISTINCT website_session_id) AS repeat_sessions
FROM session_repeat
GROUP BY 1
ORDER BY 3 DESC ) AS temp
GROUP BY 1
ORDER BY 1 