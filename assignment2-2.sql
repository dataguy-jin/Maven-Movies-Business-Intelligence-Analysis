WITH t AS(
SELECT 
		website_session_id,
        MIN(website_pageview_id) AS landing_wpi,
        pageview_url
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id 
)
SELECT 
		pageview_url AS landing_page,
        COUNT(DISTINCT website_session_id) AS sessions_hitting_on_this_page
FROM t
GROUP BY pageview_url
