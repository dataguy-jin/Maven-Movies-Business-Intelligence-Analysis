USE mavenfuzzyfactory;
-- SELECT created_at FROM website_sessions ORDER BY created_at DESC;
-- final project1: quarter trend of sessions and orders volume
SELECT 
	YEAR(ws.created_at) AS yr,
	QUARTER(ws.created_at) AS qua,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT os.order_id) AS orders
    -- COUNT(DISTINCT os.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate,
    -- SUM(os.price_usd)/COUNT(DISTINCT ws.website_session_id) AS rev_per_session
FROM website_sessions ws
	LEFT JOIN orders os
		ON os.website_session_id = ws.website_session_id
-- WHERE ws.created_at BETWEEN '2014-1-1' AND '2014-11-8'
GROUP BY 1,2 ;

-- final project2: quarterly session to order conv_rate,rev_per_order,rev_per_session
SELECT 
	YEAR(ws.created_at) AS yr,
	QUARTER(ws.created_at) AS qua,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT os.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate,
    SUM(os.price_usd)/COUNT(DISTINCT ws.website_session_id) AS rev_per_session,
    SUM(os.price_usd)/COUNT(DISTINCT os.order_id) AS rev_per_order
FROM website_sessions ws
	LEFT JOIN orders os
		ON os.website_session_id = ws.website_session_id
GROUP BY 1,2;

-- final project3:quarterly view of orders of different channels 

SELECT 
		YEAR(ws.created_at) AS yr,
		QUARTER(ws.created_at) AS qua,
		COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN os.order_id ELSE NULL END) AS brand_orders ,
		COUNT(DISTINCT CASE	WHEN utm_campaign = 'nonbrand' AND http_referer ='https://www.gsearch.com' THEN os.order_id ELSE NULL END) AS gsearch_nonbrand_orders,
		COUNT(DISTINCT CASE	WHEN utm_campaign = 'nonbrand' AND http_referer ='https://www.bsearch.com' THEN os.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
		COUNT(DISTINCT CASE WHEN utm_source IS NULL AND utm_campaign IS NULL AND http_referer IS NULL THEN os.order_id ELSE NULL END) AS direct_type_in_orders,
		COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IN('https://www.gsearch.com','https://www.bsearch.com') THEN os.order_id ELSE NULL END) AS organic_search_orders
 
FROM website_sessions ws
	LEFT JOIN orders os
		ON ws.website_session_id = os.website_session_id
GROUP BY 1,2;

-- final project4: 
SELECT 
		YEAR(ws.created_at) AS yr,
		QUARTER(ws.created_at) AS qua,
		COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN os.order_id ELSE NULL END) 
        /COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END)AS brand_conv_rate ,
		COUNT(DISTINCT CASE	WHEN utm_campaign = 'nonbrand' AND http_referer ='https://www.gsearch.com' THEN os.order_id ELSE NULL END) 
        /COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND http_referer ='https://www.gsearch.com' THEN ws.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rate,
		COUNT(DISTINCT CASE	WHEN utm_campaign = 'nonbrand' AND http_referer ='https://www.bsearch.com' THEN os.order_id ELSE NULL END) 
        /COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND http_referer ='https://www.bsearch.com' THEN ws.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rate,
		COUNT(DISTINCT CASE WHEN utm_source IS NULL AND utm_campaign IS NULL AND http_referer IS NULL THEN os.order_id ELSE NULL END) 
        /COUNT(DISTINCT CASE WHEN utm_source IS NULL AND utm_campaign IS NULL AND http_referer IS NULL THEN ws.website_session_id ELSE NULL END) AS direct_type_in_conv_rate,
		COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IN('https://www.gsearch.com','https://www.bsearch.com') THEN os.order_id ELSE NULL END) 
        /COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IN('https://www.gsearch.com','https://www.bsearch.com') THEN ws.website_session_id ELSE NULL END)AS organic_search_conv_rate
 
FROM website_sessions ws
	LEFT JOIN orders os
		ON ws.website_session_id = os.website_session_id
GROUP BY 1,2;

-- final project5: monthly trending for revenue and margin by product,along with total sales and revenue
-- SELECT * FROM products;
SELECT 	
	YEAR(created_at) AS yr,
	MONTH(created_at) AS mon,
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS p1_revnue,
    SUM(CASE WHEN product_id = 1 THEN (price_usd-cogs_usd) ELSE NULL END) AS p1_margin
FROM order_items
GROUP BY 1,2;

-- final project6: monthly sessions to /product, and % click to another page,conversion from /product to place order 
-- next pg_view	
WITH product_to_order_table AS(
SELECT 
		pg.website_session_id,
        pg.created_at,
        pg.website_pageview_id AS product_pgview_id,
        MIN(wp.website_pageview_id) AS nt_pgview_id,
        os.order_id
	FROM 
    (
		SELECT 
			website_session_id,
            website_pageview_id,
            created_at
		FROM website_pageviews
			WHERE pageview_url = '/products'
	) pg
		LEFT JOIN website_pageviews wp
			ON wp.website_session_id = pg.website_session_id
            AND wp.website_pageview_id > pg.website_pageview_id
		LEFT JOIN orders os
			ON os.website_session_id = pg.website_session_id
		GROUP BY 1
)

SELECT 
		YEAR(created_at) AS yr,
		MONTH(created_at) AS mon,
        COUNT(DISTINCT website_session_id) AS product_sessions,
        COUNT(DISTINCT nt_pgview_id) AS clicks_to_other_page,
        COUNT(DISTINCT order_id)/ COUNT(DISTINCT website_session_id) AS p_to_order_conv_rate
FROM product_to_order_table ptot
	GROUP BY 1,2;
	
 
-- final project7:since 2014.12.5 how well each product cross sell from another
CREATE TEMPORARY TABLE primary_products
SELECT 
	order_id,
    created_at AS order_time,
    primary_product_id
FROM orders
	WHERE created_at > '2014-12-5'
 ;
 
 SELECT
	primary_product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN cross_product_id = 1 THEN order_id ELSE NULL END) AS x_p1,
    COUNT(DISTINCT CASE WHEN cross_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p1_x_rate,
    COUNT(DISTINCT CASE WHEN cross_product_id = 2 THEN order_id ELSE NULL END) AS x_p2,
    COUNT(DISTINCT CASE WHEN cross_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p2_x_rate,
	COUNT(DISTINCT CASE WHEN cross_product_id = 3 THEN order_id ELSE NULL END) AS x_p3,
    COUNT(DISTINCT CASE WHEN cross_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p3_x_rate,
    COUNT(DISTINCT CASE WHEN cross_product_id = 4 THEN order_id ELSE NULL END) AS x_p4,
    COUNT(DISTINCT CASE WHEN cross_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p4_x_rate
 FROM
 (
 SELECT 
	pp.*,
    os.product_id AS cross_product_id
	FROM primary_products pp
		LEFT JOIN order_items os
			ON pp.order_id = os.order_id
            AND os.is_primary_item = 0  -- only cross-sell products
 )   AS cross_sell_table
 GROUP BY 1
-- final project8: share some recommendations and opportunities going forward 
-- 1. Product 1 led to the highest order volumes and product 4 behaved best as a cross selling product with product 1. 
-- So Bring in more products like product 4 cross selling with product 1 is a good stratery to promote the volume.
-- Target the customers who abandon /cart pages,hand out coupons or discount code to attract them to place orders.
