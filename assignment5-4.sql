USE mavenfuzzyfactory;

-- SELECT DISTINCT pageview_url FROM website_pageviews;
WITH product_sessions AS(
SELECT 
	(CASE WHEN pageview_url = '/the-original-mr-fuzzy'  THEN 'mrfuzzy'
		  WHEN pageview_url = '/the-forever-love-bear' THEN 'lovebear'
          ELSE 'logic error'
          END) AS product_seen,
	 website_session_id,
     website_pageview_id
FROM website_pageviews
WHERE  pageview_url IN( '/the-original-mr-fuzzy','/the-forever-love-bear')
    AND created_at BETWEEN '2013-01-06' AND '2013-04-10'
),
filter_table AS(
SELECT 
	product_seen,
    website_session_id,
    MAX(cart_page) AS cart_made_it,
    MAX(thanks_page) AS thanks_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it
FROM
(
SELECT
		product_seen,
		ps.website_session_id,
        CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
        CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thanks_page,
        CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
        CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page
FROM product_sessions ps
	LEFT JOIN website_pageviews wp
		ON ps.website_session_id = wp.website_session_id 
        AND wp.website_pageview_id > ps.website_pageview_id
ORDER BY 
		ps.website_session_id
	) temp
GROUP BY 2 
)

SELECT 
		product_seen,
		COUNT(DISTINCT website_session_id) AS sessions,
		COUNT(DISTINCT 
			CASE 
				WHEN cart_made_it = 1 THEN website_session_id
				ELSE NULL 
			END) AS to_cart,
		COUNT(DISTINCT 
			CASE 
				WHEN shipping_made_it = 1 THEN website_session_id
				ELSE NULL 
			END) AS to_shipping,
		COUNT(DISTINCT 
			CASE 
				WHEN billing_made_it = 1 THEN website_session_id
				ELSE NULL 
			END) AS to_billing,
		COUNT(DISTINCT 
			CASE 
				WHEN thanks_made_it = 1 THEN website_session_id
				ELSE NULL 
			END) AS to_thanks
FROM filter_table 
GROUP BY 1
