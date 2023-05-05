USE mavenfuzzyfactory;

SELECT 	
	(CASE WHEN ws.created_at < '2013-12-12'  THEN 'A.Pre_Birthday_bear'
		  WHEN ws.created_at >= '2013-12-12' THEN 'B.Post_Birthday_bear'
          ELSE 'logic error'
	END) AS time_period,
    COUNT(DISTINCT os.order_id) /COUNT(DISTINCT ws.website_session_id) AS session_to_order_conv_rate,
    SUM(os.price_usd)/COUNT(DISTINCT os.order_id) AS aov,
    SUM(os.price_usd)/COUNT(DISTINCT ws.website_session_id) AS rev_per_session
FROM website_sessions ws
	LEFT JOIN orders os
		ON ws.website_session_id = os.website_session_id
WHERE ws.created_at BETWEEN '2013-11-12' AND '2014-1-12'
GROUP BY 1

