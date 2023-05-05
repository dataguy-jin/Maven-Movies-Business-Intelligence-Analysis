USE mavenfuzzyfactory;

SELECT 
	wp.pageview_url,
	COUNT(DISTINCT wp.website_session_id) AS sessions,
    SUM(price_usd)/COUNT(DISTINCT wp.website_session_id) AS revenue_per_session 
FROM website_pageviews wp
LEFT JOIN orders
	ON orders.website_session_id = wp.website_session_id
WHERE wp.pageview_url IN('/billing','/billing-2')
		AND wp.created_at > '2012-9-10' 
        AND wp.created_at < '2012-11-10'
GROUP BY 1