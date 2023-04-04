USE mavenfuzzyfactory;


SELECT
	MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_sessions
    FROM website_sessions 
	WHERE website_sessions.created_at > '2012-08-22' 
	AND website_sessions.created_at < '2012-11-29'
    AND utm_campaign= 'nonbrand'
GROUP BY WEEK(website_sessions.created_at)



SELECT
	utm_source,
    COUNT(DISTINCT website_session_id) as sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END)/ COUNT(DISTINCT website_session_id)  AS pct_mobile
    FROM website_sessions 
	WHERE website_sessions.created_at > '2012-08-22' 
	AND website_sessions.created_at < '2012-11-30'
    AND utm_source IN ('gsearch','bsearch')
    AND utm_campaign= 'nonbrand'
GROUP BY utm_source;