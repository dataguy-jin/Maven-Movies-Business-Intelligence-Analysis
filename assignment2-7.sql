USE mavenfuzzyfactory;
-- step1: find the 'billing-2' was first seen
/*SELECT 
	MIN(created_at) AS first_created_at,
    website_pageview_id AS first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2'*/

SELECT 
	wp.pageview_url AS billing_version,
	COUNT(DISTINCT wp.website_session_id) AS sessions,
    COUNT(DISTINCT os.order_id) AS orders,
    COUNT(DISTINCT os.order_id)/COUNT(DISTINCT wp.website_session_id) billing_to_order_rt
FROM website_pageviews wp
LEFT JOIN orders os
	ON wp.website_session_id = os.website_session_id 
WHERE wp.website_pageview_id >= 53550 
AND wp.pageview_url IN ('/billing' ,'/billing-2')
AND wp.created_at > '2012-09-10' 
AND wp.created_at < '2012-11-10' 
GROUP BY wp.pageview_url