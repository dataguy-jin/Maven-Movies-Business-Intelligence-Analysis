USE mavenfuzzyfactory;
-- step1: 
-- SELECT DISTINCT pageview_url FROM website_pageviews;
WITH filtertable AS(
SELECT 
	website_session_id,
    MAX(products_page) AS products_made_it,
    MAX(fuzzy_page) AS fuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(thanks_page) AS thanks_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it
FROM 
(
SELECT 
		ws.website_session_id,
        wp.created_at AS pageview_created_at,
        wp.pageview_url,
        CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
        CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy_page,
        CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
        CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thanks_page,
        CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
        CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page
FROM website_sessions ws 
	LEFT JOIN website_pageviews wp
		ON ws.website_session_id = wp.website_session_id 
WHERE ws.created_at > '2012-08-05'
	AND  ws.created_at < '2012-09-05'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
ORDER BY 
		ws.website_session_id)  tem
GROUP BY website_session_id
)

SELECT 
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT 
		CASE 
			WHEN products_made_it = 1 THEN website_session_id
			ELSE NULL 
		END) AS to_products,
COUNT(DISTINCT 
		CASE 
			WHEN fuzzy_made_it = 1 THEN website_session_id
			ELSE NULL 
		END) AS to_fuzzy,
COUNT(DISTINCT 
		CASE 
			WHEN cart_made_it = 1 THEN website_session_id
			ELSE NULL 
		END) AS to_cart,
COUNT(DISTINCT 
		CASE 
			WHEN thanks_made_it = 1 THEN website_session_id
			ELSE NULL 
		END) AS to_thanks,
COUNT(DISTINCT 
		CASE 
			WHEN billing_made_it = 1 THEN website_session_id
			ELSE NULL 
		END) AS to_billing,
        COUNT(DISTINCT 
		CASE 
			WHEN shipping_made_it = 1 THEN website_session_id
			ELSE NULL 
		END) AS to_shipping
FROM filtertable 
