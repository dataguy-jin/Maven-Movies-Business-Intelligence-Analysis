USE mavenfuzzyfactory;
-- step1:find the first landing page
DROP TABLE IF EXISTS first_pageviews;
CREATE TEMPORARY TABLE first_pageviews
SELECT 
		website_session_id,
        MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY 
	website_session_id;

DROP TABLE IF EXISTS sessions_w_home_landing_page;
CREATE TEMPORARY TABLE sessions_w_home_landing_page
SELECT
	fp.website_session_id,
    wp.pageview_url AS landing_page
FROM first_pageviews fp
	LEFT JOIN  website_pageviews wp
		ON wp.website_pageview_id = fp.min_pageview_id
WHERE wp.pageview_url = '/home';

SELECT * FROM sessions_w_home_landing_page;
DROP TABLE IF EXISTS bounced_sessions;
CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_home_landing_page
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id
    
GROUP BY 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page
    
HAVING 
	COUNT(website_pageviews.website_pageview_id) = 1;
    
SELECT
	sp.website_session_id,
    bs.website_session_id AS bounced_website_session_id
FROM sessions_w_home_landing_page sp
	LEFT JOIN bounced_sessions bs
		ON sp.website_session_id = bs.website_session_id
ORDER BY 
	sp.website_session_id;
    
SELECT 
	COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id

	