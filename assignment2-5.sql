USE mavenfuzzyfactory;
-- step1: find the landing page 
WITH land_table AS(
SELECT 
		wp.website_session_id,
        wp.created_at AS session_created_at,
        wp.pageview_url AS landing_page,
        MIN(wp.website_pageview_id) AS first_pageview_id,
        COUNT(wp.website_pageview_id) AS count_pageviews
FROM website_sessions ws 
	LEFT JOIN website_pageviews wp
		ON ws.website_session_id = wp.website_session_id 
WHERE ws.created_at > '2012-06-01'
	AND  ws.created_at < '2012-08-31'
	AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
GROUP BY 
		ws.website_session_id) 
SELECT 
	-- YEARWEEK(session_created_at) AS year_week,
	MIN(DATE(session_created_at)) AS week_start_time, 
    -- COUNT(DISTINCT website_session_id) AS total_sessions,
    /* COUNT(DISTINCT 
		CASE 
			WHEN count_pageviews = 1 THEN website_session_id
			ELSE NULL 
		END) AS bonced_sessions,*/
         COUNT(DISTINCT 
		CASE 
			WHEN count_pageviews = 1 THEN website_session_id
			ELSE NULL 
		END)*1.0/ COUNT(DISTINCT website_session_id) AS bounce_rate,
	COUNT(DISTINCT 
		CASE 
			WHEN landing_page = '/home' THEN website_session_id
			ELSE NULL 
		END) AS home_sessions,
    COUNT(DISTINCT 
		CASE 
			WHEN landing_page = '/lander-1' THEN website_session_id
			ELSE NULL 
		END) AS lander_sessions

FROM land_table 
GROUP BY YEARWEEK(session_created_at); 
