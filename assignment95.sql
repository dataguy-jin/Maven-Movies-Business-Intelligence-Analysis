USE mavenfuzzyfactory;

-- SELECT DISTINCT utm_campaign,utm_source,http_referer FROM website_sessions;
SELECT
        CASE WHEN utm_campaign = 'brand' THEN 'paid_brand' 
			WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
            WHEN utm_source = 'socialbook' THEN 'paid_socail'
			WHEN utm_source IS NULL AND utm_campaign IS NULL AND http_referer IS NULL THEN 'direct_type_in'
            WHEN utm_source IS NULL AND http_referer IN('https://www.gsearch.com','https://www.bsearch.com') THEN 'organic_search'
            ELSE 'error'
            END AS channel_group,
            COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions,
            COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions
FROM website_sessions
WHERE created_at BETWEEN '2014-1-1' AND '2014-11-5'
GROUP BY 1