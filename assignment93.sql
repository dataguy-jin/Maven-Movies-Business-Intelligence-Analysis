USE mavenfuzzyfactory;
-- look for the first session and second session id 
WITH session_repeat AS(
SELECT 
	ns.user_id,
    ns.first_session_id,
    ns.first_time,
    MIN(ws.website_session_id)  AS second_session_id
FROM
( -- look for the first session 
SELECT 
	user_id,
    website_session_id AS first_session_id,
    created_at AS first_time
FROM website_sessions 
	WHERE created_at BETWEEN '2014-1-1' AND '2014-11-1'
		AND is_repeat_session = 0
) AS ns
LEFT JOIN website_sessions ws
	ON ws.user_id = ns.user_id
		AND ws.is_repeat_session = 1
        AND ws.website_session_id > ns.first_session_id 
        AND ws.created_at BETWEEN '2014-1-1' AND '2014-11-1'
GROUP BY 1
)

SELECT 
	AVG(days_first_to_second) AS avg_days_first_to_second,
    MIN(days_first_to_second) AS min_days_first_to_second,
    MAX(days_first_to_second) AS max_days_first_to_second
FROM
(
SELECT 
	sr.user_id,
    sr.first_time,
    ws.created_at AS second_time,
    DATEDIFF(ws.created_at,sr.first_time) AS days_first_to_second
FROM session_repeat sr
	LEFT JOIN website_sessions ws
		ON ws.website_session_id = sr.second_session_id 
	WHERE sr.second_session_id IS NOT NULL
ORDER BY 4 DESC
) t
