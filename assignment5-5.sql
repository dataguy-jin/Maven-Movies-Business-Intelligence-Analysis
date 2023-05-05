USE mavenfuzzyfactory;

-- step1: find the sessions which go to cart in certain periods
WITH cart_table AS(
SELECT 
	(CASE WHEN created_at < '2013-09-25'  THEN 'A.Pre_Cross_Sell'
		  WHEN created_at >= '2013-01-06' THEN 'B.Post_Cross_Sell'
          ELSE 'logic error'
          END) AS time_period,
	 created_at,
	 website_session_id,
     website_pageview_id,
     pageview_url
FROM website_pageviews
WHERE pageview_url = '/cart'
    AND created_at BETWEEN '2013-8-25' AND '2013-10-25'
),

nt_pv_table AS(
SELECT 
	time_period,
    ct.website_session_id,
	MIN(wp.website_pageview_id) AS nt_pv_id
FROM cart_table ct
	LEFT JOIN website_pageviews wp
		ON ct.website_session_id = wp.website_session_id 
        AND wp.website_pageview_id > ct.website_pageview_id
	GROUP BY 1,2
		HAVING 
			MIN(wp.website_pageview_id) IS NOT NULL
),

cart_to_order_table AS(
SELECT 
	ct.time_period,
	ct.website_session_id,
    os.order_id,
    items_purchased,
    primary_product_id,
    price_usd
FROM cart_table ct
	INNER JOIN orders os
		ON ct.website_session_id = os.website_session_id        
GROUP BY 1,2
),

filter_table AS
(
	SELECT
		ct.time_period,
		ct.website_session_id,
        CASE WHEN nt.nt_pv_id IS NULL THEN 0 ELSE 1 END AS jump_to_other_page,
        CASE WHEN ctot.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
		ctot.items_purchased,
		ctot.price_usd
	FROM cart_table ct
		LEFT JOIN nt_pv_table nt
			ON nt.website_session_id = ct.website_session_id
		LEFT JOIN cart_to_order_table ctot
			ON ctot.website_session_id = ct.website_session_id
)
SELECT 	
	time_period,
    COUNT(DISTINCT website_session_id) AS cart_sessions,
    SUM(jump_to_other_page) AS clickchroughs,
    SUM(jump_to_other_page)/COUNT(DISTINCT website_session_id) AS cart_ctr,
    SUM(items_purchased)/SUM(placed_order)  AS product_per_order,
    SUM(price_usd)/SUM(placed_order) AS aov,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS rev_per_cart_session
FROM filter_table  	
GROUP BY 1

