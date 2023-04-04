USE mavenfuzzyfactory;
-- QUERY 3

SELECT
	MIN(DATE(website_sessions.created_at)) AS session_month,
	COUNT(DISTINCT website_sessions.website_session_id) AS monthly_sessions,
	COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions 
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source ='gsearch'
GROUP BY MONTH(website_sessions.created_at);

-- QUERY2

SELECT
	MIN(DATE(website_sessions.created_at)) AS session_month,
    COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_website_sessions,
    COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN orders.order_id ELSE NULL END) AS brand_orders
FROM website_sessions 
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source ='gsearch'
GROUP BY MONTH(website_sessions.created_at);


-- QUERY3

SELECT
	YEAR(website_sessions.created_at) as session_year,
	MIN(DATE(website_sessions.created_at)) AS session_month,
    COUNT(DISTINCT CASE WHEN device_type='desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type='desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
	COUNT(DISTINCT CASE WHEN device_type='mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type='mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders
FROM website_sessions 
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source ='gsearch'
    AND utm_campaign='nonbrand'
GROUP BY 1, MONTH(website_sessions.created_at);


-- QUERY4

CREATE TEMPORARY TABLE all_sessions
SELECT
	-- YEAR(website_sessions.created_at) as session_year,
	-- MIN(DATE(website_sessions.created_at)) AS session_month,
    website_sessions.website_session_id,
	CASE WHEN website_sessions.utm_source ='gsearch' THEN '1' ELSE '0' END AS gsearch_sessions
FROM website_sessions 
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1, MONTH(website_sessions.created_at);

SELECT
	YEAR(website_sessions.created_at) as session_year,
	MIN(DATE(website_sessions.created_at)) AS session_month,
	COUNT(DISTINCT CASE WHEN  gsearch_sessions= '1' THEN all_sessions.website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN  gsearch_sessions= '0' THEN all_sessions.website_session_id ELSE NULL END) AS other_sessions
FROM all_sessions LEFT JOIN website_sessions 
		ON website_sessions.website_session_id = all_sessions.website_session_id
GROUP BY 1, MONTH(website_sessions.created_at);

-- QUERY5

CREATE TEMPORARY TABLE sessions_and_orders
SELECT
	-- YEAR(website_sessions.created_at) as session_year,
	-- MIN(DATE(website_sessions.created_at)) AS session_month,
	website_sessions.website_session_id AS sessions,
    CASE WHEN orders.order_id IS NOT NULL THEN '1' ELSE '0' END AS gsearch_sessions
FROM website_sessions 
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2;

SELECT
	YEAR(website_sessions.created_at) as session_year,
	MIN(DATE(website_sessions.created_at)) AS session_month,
	COUNT(DISTINCT sessions) AS session_count,
    COUNT(DISTINCT CASE WHEN gsearch_sessions ='1' THEN website_session_id ELSE NULL END) AS order_count,
    COUNT(DISTINCT CASE WHEN gsearch_sessions ='1' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT sessions) AS session_to_order
FROM sessions_and_orders LEFT JOIN website_sessions 
		ON website_sessions.website_session_id = sessions_and_orders.sessions
        WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1, MONTH(website_sessions.created_at);

-- QUERY6
SELECT
	MIN(created_at) as first_created_at,
	MIN(website_pageview_id) as first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at is not null;

CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) as min_pageview_id
FROM website_pageviews 
	INNER JOIN website_sessions 
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-07-28'
	AND website_pageviews.website_pageview_id >= '23504'
    AND website_sessions.utm_source ='gsearch'
    AND website_sessions.utm_campaign='nonbrand'
GROUP BY website_pageviews.website_session_id;

CREATE TEMPORARY TABLE non_brand_test_sessions_with_landing_page
SELECT 
	first_test_pageviews.website_session_id,
    pageview_url AS landing_page
FROM first_test_pageviews 
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE pageview_url IN ('/lander-1','/home');

CREATE TEMPORARY TABLE non_brand_test_sessions_with_orders
SELECT 
	non_brand_test_sessions_with_landing_page.website_session_id,
    order_id,
    price_usd,
    landing_page
FROM non_brand_test_sessions_with_landing_page 
	LEFT JOIN orders 
		ON orders.website_session_id = non_brand_test_sessions_with_landing_page.website_session_id;
        
SELECT landing_page,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS conversion_rate,
    SUM(price_usd) as total_income
FROM non_brand_test_sessions_with_orders
GROUP BY 1;

-- .0088 additional order per session

SELECT
	MAX(website_sessions.website_session_id) as max_home_session
FROM website_sessions LEFT JOIN website_pageviews
	ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE pageview_url = '/home'
	AND utm_source='gsearch'
    AND utm_campaign='nonbrand'
    AND website_sessions.created_at < '2012-11-27';
    
    -- max_home_session=17145
DROP TABLE lander_page_sessions_after_home_terminated;
CREATE TEMPORARY TABLE lander_page_sessions_after_home_terminated
SELECT 
	website_sessions.website_session_id
FROM website_sessions LEFT JOIN website_pageviews
	ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE pageview_url = '/lander-1'
	AND utm_source='gsearch'
    AND utm_campaign='nonbrand'
    AND website_sessions.website_session_id > '17145'
	AND website_sessions.created_at < '2012-11-27';
    
-- 22972 lander page sessions since homepage usage ended
-- 22972 * .0088 = 202,15 more product sold

SELECT 
	COUNT(DISTINCT lander_page_sessions_after_home_terminated.website_session_id) as lander_page_sessions,
    SUM(orders.price_usd) as total_income
FROM lander_page_sessions_after_home_terminated
	LEFT JOIN orders 
		ON lander_page_sessions_after_home_terminated.website_session_id = orders.website_session_id;
        
-- total income from these lander pages = 46540,69 $


-- QUERY7
DROP TABLE sessions_with_flags;
CREATE TEMPORARY TABLE sessions_with_flags
SELECT 
website_sessions.website_session_id,
website_pageviews.website_pageview_id,
website_pageviews.pageview_url,
CASE WHEN website_pageviews.pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
CASE WHEN website_pageviews.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander1_page,
CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions LEFT JOIN website_pageviews
	ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-06-19'
	AND website_sessions.created_at < '2012-07-28'
	AND website_sessions.utm_source='gsearch'
    AND website_sessions.utm_campaign='nonbrand'
ORDER BY website_sessions.website_session_id;

CREATE TEMPORARY TABLE sessions_with_flags_combined_in_one_row
SELECT
website_session_id,
	MAX(home_page) AS saw_homepage,
	MAX(lander1_page) AS saw_lander1,
	MAX(product_page) AS saw_product,
	MAX(mr_fuzzy_page) AS saw_mrfuzzy,
	MAX(cart_page) AS saw_cart,
	MAX(shipping_page) AS saw_shipping,
	MAX(billing_page) AS saw_billing,
	MAX(thankyou_page) AS saw_thankyou
FROM sessions_with_flags
GROUP BY website_session_id;

SELECT 
COUNT(DISTINCT website_session_id) AS sessions, 
COUNT(DISTINCT CASE WHEN saw_homepage = '0' AND saw_lander1='1' AND saw_product='1'  AND saw_mrfuzzy='1'  AND saw_cart='1'  AND saw_shipping='1'
AND saw_billing='1'  AND saw_thankyou='1' THEN website_session_id ELSE NULL END) AS used_lander1_to_buy,
COUNT(DISTINCT CASE WHEN saw_homepage = '1' AND saw_lander1='0' AND saw_product='1'  AND saw_mrfuzzy='1'  AND saw_cart='1'  AND saw_shipping='1'
AND saw_billing='1'  AND saw_thankyou='1' THEN website_session_id ELSE NULL END) AS used_home_page_to_buy
FROM sessions_with_flags_combined_in_one_row;


SELECT 
CASE 
	WHEN saw_homepage = '1' THEN 'from_homepage'
	WHEN saw_lander1 = '1' 	THEN 'from_lander1'
    ELSE NULL END AS segment,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN saw_product = '1' THEN website_session_id ELSE NULL END) AS to_product,
	COUNT(DISTINCT CASE WHEN saw_mrfuzzy = '1' THEN website_session_id ELSE NULL END) AS to_mr_fuzzy,
	COUNT(DISTINCT CASE WHEN saw_cart = '1' THEN website_session_id ELSE NULL END) AS to_cart,
	COUNT(DISTINCT CASE WHEN saw_shipping  = '1' THEN website_session_id ELSE NULL END) AS to_shipping,
	COUNT(DISTINCT CASE WHEN saw_billing = '1' THEN website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN saw_thankyou = '1' THEN website_session_id ELSE NULL END) AS to_thankyou
FROM sessions_with_flags_combined_in_one_row
GROUP BY segment;