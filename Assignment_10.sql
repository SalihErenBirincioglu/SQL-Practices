USE mavenfuzzyfactory;

 -- SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
-- SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- SELECT * FROM website_pageviews;


-- DROP TABLE sessions_w_min_pw_id_and_view_count;

CREATE TEMPORARY TABLE sessions_w_min_pw_id_and_view_count
SELECT website_sessions.website_session_id,
MIN(website_pageview_id) AS first_pageview_id,
COUNT(DISTINCT website_pageview_id) AS count_pageviews
FROM website_sessions
	LEFT JOIN  website_pageviews 
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-06-01'
	AND website_sessions.created_at < '2012-08-31'
	AND website_sessions.utm_source='gsearch'
	AND website_sessions.utm_campaign='nonbrand'
GROUP BY website_sessions.website_session_id;

-- DROP TABLE sessions_w_counts_lander_id_and_created_at;

CREATE TEMPORARY TABLE sessions_w_counts_lander_id_and_created_at
SELECT sessions_w_min_pw_id_and_view_count.website_session_id,
	sessions_w_min_pw_id_and_view_count.first_pageview_id,
    sessions_w_min_pw_id_and_view_count.count_pageviews,
    pageview_url AS lander_page,
	website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pw_id_and_view_count LEFT JOIN website_pageviews ON sessions_w_min_pw_id_and_view_count.first_pageview_id = website_pageviews.website_pageview_id;


SELECT
    MIN(DATE(session_created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN sessions_w_counts_lander_id_and_created_at.count_pageviews = '1' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id)  AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN sessions_w_counts_lander_id_and_created_at.lander_page = '/home' THEN website_session_id ELSE NULL END)  AS home_sessions,
    COUNT(DISTINCT CASE WHEN sessions_w_counts_lander_id_and_created_at.lander_page = '/lander-1' THEN website_session_id ELSE NULL END)  AS lander_sessions
FROM sessions_w_counts_lander_id_and_created_at
GROUP BY WEEK(DATE(session_created_at))
	

