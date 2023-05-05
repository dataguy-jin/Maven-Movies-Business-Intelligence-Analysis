USE mavenfuzzyfactory;
-- step1: 
-- SELECT DISTINCT pageview_url FROM website_pageviews;
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
),
filtertable AS(
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
WHERE ws.created_at > '2012-06-19'
	AND  ws.created_at < '2012-07-28'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
ORDER BY 
		wp.website_session_id)  tem
GROUP BY website_session_id
)

SELECT 
l.landing_page,
COUNT(DISTINCT f.website_session_id) AS sessions,
COUNT(DISTINCT 
		CASE 
			WHEN f.products_made_it = 1 THEN f.website_session_id
			ELSE NULL 
		END) AS to_products,
COUNT(DISTINCT 
		CASE 
			WHEN f.fuzzy_made_it = 1 THEN f.website_session_id
			ELSE NULL 
		END) AS to_fuzzy,
COUNT(DISTINCT 
		CASE 
			WHEN f.cart_made_it = 1 THEN f.website_session_id
			ELSE NULL 
		END) AS to_cart,
COUNT(DISTINCT 
		CASE 
			WHEN f.thanks_made_it = 1 THEN f.website_session_id
			ELSE NULL 
		END) AS to_thanks,
COUNT(DISTINCT 
		CASE 
			WHEN f.billing_made_it = 1 THEN f.website_session_id
			ELSE NULL 
		END) AS to_billing,
        COUNT(DISTINCT 
		CASE 
			WHEN f.shipping_made_it = 1 THEN f.website_session_id
			ELSE NULL 
		END) AS to_shipping
FROM filtertable f
INNER JOIN land_table l
ON l.website_session_id = f.website_session_id
GROUP BY l.landing_page
