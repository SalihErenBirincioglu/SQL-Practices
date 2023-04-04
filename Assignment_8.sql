USE mavenfuzzyfactory;

-- DROP TABLE first_pageviews;

CREATE TEMPORARY TABLE first_pageviews
SELECT website_session_id,
MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;

-- SELECT * FROM first_pageviews;

-- DROP TABLE sessions_with_home_landing_page;

CREATE TEMPORARY TABLE sessions_with_home_landing_page
SELECT first_pageviews.website_session_id,
website_pageviews.pageview_url AS landing_page
FROM first_pageviews  LEFT JOIN website_pageviews  ON website_pageviews.website_pageview_id = first_pageviews.min_pageview_id
WHERE pageview_url='/home';

-- SELECT * FROM sessions_with_home_landing_page;

-- DROP TABLE bounced_sessions;

CREATE TEMPORARY TABLE bounced_sessions
SELECT sessions_with_home_landing_page.website_session_id,
sessions_with_home_landing_page.landing_page,
COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_with_home_landing_page  LEFT JOIN website_pageviews ON website_pageviews.website_session_id = sessions_with_home_landing_page.website_session_id
GROUP BY sessions_with_home_landing_page.website_session_id,
sessions_with_home_landing_page.landing_page
HAVING COUNT(website_pageviews.website_pageview_id) ='1';

SELECT bounced_sessions.website_session_id FROM bounced_sessions;
SELECT sessions_with_home_landing_page.website_session_id from sessions_with_home_landing_page;


SELECT
COUNT(DISTINCT sessions_with_home_landing_page.website_session_id)  AS sessions,
COUNT(DISTINCT bounced_sessions.website_session_id ) AS bounced_website_session_id,
COUNT(DISTINCT bounced_sessions.website_session_id )/ COUNT(DISTINCT sessions_with_home_landing_page.website_session_id) AS bounce_rate
FROM sessions_with_home_landing_page 
	LEFT JOIN bounced_sessions 
		ON sessions_with_home_landing_page.website_session_id = bounced_sessions.website_session_id;