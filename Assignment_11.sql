USE mavenfuzzyfactory;
SET SESSION sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));


SELECT 
website_sessions.website_session_id,
website_pageviews.website_pageview_id,
website_pageviews.pageview_url,
CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions LEFT JOIN website_pageviews
	ON website_sessions.website_session_id =website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-08-05'
	AND website_sessions.created_at < '2012-09-05'
	AND website_sessions.utm_source='gsearch'
    AND website_sessions.utm_campaign='nonbrand'
ORDER BY website_sessions.website_session_id;



-- DROP TABLE session_level_flag_table;
CREATE TEMPORARY TABLE session_level_flag_table
SELECT
COUNT(DISTINCT website_session_id) AS sessions, 
COUNT(DISTINCT CASE WHEN product_page = '1' THEN website_session_id ELSE NULL END) AS to_product,
COUNT(DISTINCT CASE WHEN mr_fuzzy_page = '1' THEN website_session_id ELSE NULL END) AS to_mr_fuzzy,
COUNT(DISTINCT CASE WHEN cart_page = '1' THEN website_session_id ELSE NULL END) AS to_cart,
COUNT(DISTINCT CASE WHEN shipping_page  = '1' THEN website_session_id ELSE NULL END) AS to_shipping,
COUNT(DISTINCT CASE WHEN billing_page = '1' THEN website_session_id ELSE NULL END) AS to_billing,
COUNT(DISTINCT CASE WHEN thankyou_page = '1' THEN website_session_id ELSE NULL END) AS to_thankyou
FROM
(
SELECT 
website_sessions.website_session_id,
website_pageviews.website_pageview_id,
website_pageviews.pageview_url,
CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions LEFT JOIN website_pageviews
	ON website_sessions.website_session_id =website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-08-05'
	AND website_sessions.created_at < '2012-09-05'
	AND website_sessions.utm_source='gsearch'
    AND website_sessions.utm_campaign='nonbrand'
ORDER BY website_sessions.website_session_id
) AS pageview_level;


SELECT to_product/sessions AS lander_click_rt,
to_mr_fuzzy/to_product AS mrfuzzy_click_rt,
to_cart/to_mr_fuzzy AS cart_click_rt,
to_shipping/to_cart AS shipping_click_rt,
to_billing/to_shipping AS billing_click_rt,
to_thankyou/to_billing AS thankyou_click_rt
FROM session_level_flag_table;
