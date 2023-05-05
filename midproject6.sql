USE mavenfuzzyfactory;

-- step1: find the time when lander-1 launched (2012-06-19,first_pv_id is 23504)
/*SELECT
		MIN(website_pageview_id) AS first_pv_id,
        created_at 
FROM website_pageviews 
WHERE pageview_url = '/lander-1'
*/

-- find the sessions lead by 'lander-1'
WITH land_table AS(
SELECT
		wp.website_session_id,
        MIN(wp.website_pageview_id) AS min_pv_id,
        wp.pageview_url AS landing_page
FROM website_pageviews wp
LEFT JOIN website_sessions ws
	ON wp.website_session_id = ws.website_session_id 
WHERE 	ws.created_at < '2012-07-28'
		AND ws.utm_source = 'gsearch'
		AND ws.utm_campaign = 'nonbrand'
        AND wp.website_pageview_id >= 23504
		AND wp.pageview_url IN ('/lander-1','/home')
GROUP BY wp.website_session_id
)
SELECT
		land_table.landing_page,
		COUNT(DISTINCT land_table.website_session_id) AS sessions,
        COUNT(DISTINCT orders.order_id) AS orders,
        COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT land_table.website_session_id) AS conv_rate
FROM land_table 
	LEFT JOIN orders
		ON land_table.website_session_id = orders.website_session_id 
GROUP BY land_table.landing_page;

-- find the most recent pageview for nobrand gsearch where the traffic was sent to home
-- max session_id is 17145
/*SELECT 
	MAX(wp.website_session_id) AS most_recent_session_id
FROM website_pageviews wp
LEFT JOIN website_sessions ws
	ON wp.website_session_id = ws.website_session_id 
WHERE 	ws.created_at < '2012-11-27'
		AND ws.utm_source = 'gsearch'
		AND ws.utm_campaign = 'nonbrand'
		AND wp.pageview_url ='/home'
*/
SELECT 
	COUNT(DISTINCT ws.website_session_id) AS count_of_sessions
FROM website_sessions ws
WHERE ws.created_at < '2012-11-27'
		AND ws.website_session_id > 17145 -- after test sessions
		AND ws.utm_source = 'gsearch'
		AND ws.utm_campaign = 'nonbrand'
