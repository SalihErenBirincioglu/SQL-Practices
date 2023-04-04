USE mavenfuzzyfactory;

SELECT
	MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS dtop_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mob_sessions
    FROM website_sessions 
WHERE website_sessions.created_at > '2012-04-15' 
	AND website_sessions.created_at < '2012-06-9' 
	AND utm_source='gsearch' 
    AND utm_campaign='nonbrand'
GROUP BY WEEK(website_sessions.created_at);


SELECT pageview_url,
	COUNT(DISTINCT website_pageview_id ) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY sessions DESC;





CREATE TEMPORARY TABLE first_pv_per_session
SELECT
	website_session_id,
	MIN(website_pageview_id) AS min_page_view_id
FROM website_pageviews
 WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

-- SELECT * FROM first_pv_per_session

SELECT
	pageview_url AS landing_page,
	COUNT(DISTINCT first_pv_per_session.website_session_id) AS sessions
FROM first_pv_per_session LEFT JOIN website_pageviews ON first_pv_per_session.min_page_view_id = website_pageviews.website_pageview_id
GROUP BY landing_page;