USE mavenfuzzyfactory;

SELECT
website_pageviews.created_at,
website_pageviews.website_pageview_id AS first_pv_id
FROM website_pageviews
WHERE pageview_url IN ('/billing-2')
AND created_at < '2012-10-10';

-- AND created_at > '2012-09-10'


-- DROP TABLE thankyou_table;
CREATE TEMPORARY TABLE thankyou_table
SELECT 
DISTINCT website_session_id,
-- COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/billing' THEN website_session_id ELSE NULL END) AS billing_session,
-- COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/billing2' THEN website_session_id ELSE NULL END) AS billing2_session
CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_pageviews 
WHERE website_pageview_id > 53550
	AND website_pageviews.created_at < '2012-11-10';
    
-- DROP TABLE session_level_flag_table;
CREATE TEMPORARY TABLE session_level_flag_table
SELECT website_pageviews.website_session_id,
created_at,
pageview_url,
CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN website_pageviews.pageview_url = '/billing-2'  THEN 1 ELSE 0 END AS billing2_page,
thankyou_page
FROM website_pageviews LEFT JOIN thankyou_table ON website_pageviews.website_session_id = thankyou_table.website_session_id
WHERE website_pageview_id > 53550
	AND website_pageviews.created_at < '2012-11-10'
	AND website_pageviews.pageview_url IN ('/billing','/billing-2');

SELECT pageview_url AS billing_version,
COUNT(DISTINCT website_session_id) AS sessions, 
SUM(thankyou_page) AS orders,
SUM(thankyou_page)/COUNT(DISTINCT website_session_id)  AS billing_ratio
FROM session_level_flag_table
GROUP BY billing_version;
    
    