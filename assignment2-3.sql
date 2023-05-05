USE mavenfuzzyfactory;
-- step1:find the first landing page
WITH land_table AS(
SELECT 
		website_session_id,
        MIN(website_pageview_id) AS landing_wpi,
        pageview_url AS landing_page
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id) ,
-- step2: calculate the amount of pages viewed per session_id 
leave_table AS(
SELECT 
		website_session_id,
        COUNT(DISTINCT website_pageview_id) AS leave_wpi
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id)

SELECT 
	COUNT(DISTINCT land_table.website_session_id) AS sessions,
    COUNT(CASE 
		WHEN leave_table.leave_wpi = 1 THEN 1 ELSE NULL 
	END) AS bounced_sessions,
	COUNT(CASE 
		WHEN leave_table.leave_wpi = 1 THEN 1 ELSE NULL 
	END) /COUNT(DISTINCT land_table.website_session_id) AS bounce_rate	
FROM land_table 
LEFT JOIN leave_table
ON land_table.website_session_id = leave_table.website_session_id
GROUP BY land_table.landing_page ;
