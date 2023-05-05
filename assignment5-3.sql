USE mavenfuzzyfactory;

-- find all the sessions with product pageview and rank the pageviews per session
/*WITH rank_pv AS(
SELECT 
	website_session_id,
    website_pageview_id,
    RANK() OVER(PARTITION BY website_session_id
				ORDER BY website_pageview_id ASC) AS pv_rank,
	pageview_url
FROM website_pageviews
WHERE website_session_id IN(
    SELECT 
		website_session_id
    FROM website_pageviews
    WHERE pageview_url = '/products'
    AND created_at BETWEEN '2013-1-6' AND '2013-4-5' )
)*/
WITH period_table AS(
SELECT 
	(CASE WHEN created_at < '2013-01-06'  THEN 'A.Pre_product_2'
		  WHEN created_at >= '2013-01-06' THEN 'B.Post_product_2'
          ELSE 'logic error'
          END) AS time_period,
	 created_at,
	 website_session_id,
     website_pageview_id
FROM website_pageviews
WHERE pageview_url = '/products'
    AND created_at BETWEEN '2012-10-06' AND '2013-04-06'
),

next_page_table AS(
SELECT 
	pt.time_period,
	pt.website_session_id,
    MIN(wp.website_pageview_id) AS nt_pv_id
FROM period_table pt
	LEFT JOIN website_pageviews wp
		ON pt.website_session_id = wp.website_session_id
        AND wp.website_pageview_id > pt.website_pageview_id
-- WHERE wp.website_pageview_id > pt.website_pageview_id (WHY it is wrong)
GROUP BY 1,2
) ,
t AS(
SELECT 
		nt.time_period,
        nt.website_session_id,
        wp.pageview_url
FROM next_page_table nt
	LEFT JOIN website_pageviews wp
		ON nt.nt_pv_id = wp.website_pageview_id
)
SELECT 
		time_period,
		COUNT(DISTINCT website_session_id) AS sessions,
		COUNT(CASE WHEN pageview_url IS NOT NULL THEN website_session_id 
			ELSE NULL END) AS w_next_pg,
		COUNT(CASE WHEN pageview_url IS NOT NULL THEN website_session_id 
			ELSE NULL END) /COUNT(DISTINCT website_session_id) AS pct_w_next_page,
		COUNT(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id 
			ELSE NULL END) AS to_mrfuzzy,
		COUNT(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id 
			ELSE NULL END)/COUNT(DISTINCT website_session_id)  AS pct_to_mrfuzzy,
		COUNT(CASE WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id 
			ELSE NULL END) AS to_lovebear,
		COUNT(CASE WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id 
			ELSE NULL END)/COUNT(DISTINCT website_session_id)  AS pct_to_lovebear
FROM t
GROUP BY 1

