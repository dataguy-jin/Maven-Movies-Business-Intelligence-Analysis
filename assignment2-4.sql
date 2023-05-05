USE mavenfuzzyfactory;
-- step0: find out when the new page launched
SELECT 
		MIN(created_at) AS first_created_at,
        MIN(website_pageview_id) AS landing_wpi	
FROM  website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL;
-- step1: find the landing page 
WITH land_table AS(
SELECT 
		wp.website_session_id,
        MIN(wp.website_pageview_id) AS landing_wpi,
        wp.pageview_url AS landing_page
FROM website_pageviews wp
	INNER JOIN website_sessions ws
		ON ws.website_session_id = wp.website_session_id 
WHERE wp.created_at < '2012-07-28'
	AND wp.website_pageview_id > 23504 -- the min_pageview we found for the test
	AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
GROUP BY 
		wp.website_session_id, wp.pageview_url) ,
-- step2: caculate the nums of pages viewed per session
leave_table AS(
SELECT 
		website_session_id,
        COUNT(DISTINCT website_pageview_id) AS nums_pages
FROM website_pageviews
WHERE created_at < '2012-07-28'
GROUP BY website_session_id) 
-- final: caculate bounced sessions 
SELECT 
	land_table.landing_page,
	COUNT(DISTINCT land_table.website_session_id) AS total_sessions,
    COUNT(CASE 
		WHEN leave_table.nums_pages = 1 THEN 1 ELSE NULL 
	END) AS bounced_sessions,
	COUNT(CASE 
		WHEN leave_table.nums_pages = 1 THEN 1 ELSE NULL 
	END) /COUNT(DISTINCT land_table.website_session_id) AS bounce_rate	
FROM land_table 
LEFT JOIN leave_table
ON land_table.website_session_id = leave_table.website_session_id
WHERE land_table.landing_page = '/home' OR land_table.landing_page = '/lander-1'
GROUP BY land_table.landing_page ; 
