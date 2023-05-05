USE mavenfuzzyfactory;

SELECT
		MIN(DATE(created_at)) AS week_start_time, 
        -- ws.device_type,
		-- ws.utm_source,
		-- COUNT(website_session_id) AS sessions,
        COUNT(CASE WHEN device_type = 'desktop' AND utm_source='gsearch' THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
        COUNT(CASE WHEN device_type = 'desktop' AND utm_source='bsearch' THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
        COUNT(CASE WHEN device_type = 'desktop' AND utm_source='bsearch' THEN website_session_id ELSE NULL END)/
        COUNT(CASE WHEN device_type = 'desktop' AND utm_source='gsearch' THEN website_session_id ELSE NULL END) AS b_pct_of_g_dtop,
		COUNT(CASE WHEN device_type = 'mobile' AND utm_source='gsearch' THEN website_session_id ELSE NULL END) AS g_mob_sessions,
        COUNT(CASE WHEN device_type = 'mobile' AND utm_source='bsearch' THEN website_session_id ELSE NULL END) AS b_mob_sessions,
		COUNT(CASE WHEN device_type = 'mobile' AND utm_source='bsearch' THEN website_session_id ELSE NULL END)/
        COUNT(CASE WHEN device_type = 'mobile' AND utm_source='gsearch' THEN website_session_id ELSE NULL END) AS b_pct_of_g_mob
FROM website_sessions 
WHERE created_at < '2012-12-22'
	  AND created_at > '2012-11-4'
      AND utm_campaign = 'nonbrand'
      AND utm_source IN('gsearch','bsearch')
GROUP BY YEARWEEK(created_at);
