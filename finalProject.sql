USE mavenfuzzyfactory;

-- QUERY 1

SELECT 
YEAR(website_sessions.created_at),
quarter(website_sessions.created_at),
COUNT(DISTINCT website_sessions.website_session_id) as sessions,
COUNT(DISTINCT order_id) AS orders
FROM website_sessions LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
-- WHERE website_sessions.created_at <'2014-04-01'
GROUP BY 1,2;

-- QUERY 2

SELECT 
YEAR(website_sessions.created_at) AS yr,
quarter(website_sessions.created_at) qr,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_sessions.website_session_id) as session_to_order,
SUM(orders.price_usd)/COUNT(DISTINCT order_id) AS rev_per_order,
SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_session
FROM website_sessions LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
-- WHERE website_sessions.created_at <'2014-04-01'
GROUP BY 1,2;

-- QUERY 3

SELECT 
YEAR(website_sessions.created_at) AS yr,
quarter(website_sessions.created_at) qr,
COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand_order,
COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand_order,
COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN orders.order_id ELSE NULL END) AS brand_search,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS direct_type_in,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS organic_search
FROM website_sessions LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
-- WHERE website_sessions.created_at <'2014-04-01'
GROUP BY 1,2;

-- QUERY 4
SELECT 
YEAR(website_sessions.created_at) AS yr,
quarter(website_sessions.created_at) qr,
COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN orders.order_id ELSE NULL END)
/COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rate,
COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN orders.order_id ELSE NULL END)
/COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rate,
COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN orders.order_id ELSE NULL END)
/COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN website_sessions.website_session_id  ELSE NULL END) AS brand_search_conv_rate,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END)
/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_conv_rate,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END)
/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_conv_rate
FROM website_sessions LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
-- WHERE website_sessions.created_at <'2014-04-01'
GROUP BY 1,2;

-- QUERY 5

SELECT
	YEAR(created_at) AS yr, 
    MONTH(created_at) AS mo, 
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS sugarpanda_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS sugarpanda_marg,
    SUM(price_usd) AS total_revenue,  
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items 
GROUP BY 1,2
ORDER BY 1,2;


-- QUERY 6

CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id, 
    website_pageview_id, 
    created_at AS saw_product_page_at
FROM website_pageviews 
WHERE pageview_url = '/products';


SELECT 
	YEAR(saw_product_page_at) AS yr, 
    MONTH(saw_product_page_at) AS mo,
    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page, 
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page, 
    COUNT(DISTINCT website_pageviews.website_session_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS clickthrough_rt,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS products_to_order_rt
FROM products_pageviews
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_session_id = products_pageviews.website_session_id -- same session
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id -- it has another page after products 
	LEFT JOIN orders 
		ON orders.website_session_id = products_pageviews.website_session_id
GROUP BY 1,2
;

-- QUERY 7


CREATE TEMPORARY TABLE primary_products
SELECT 
	order_id, 
    primary_product_id, 
    created_at AS ordered_at
FROM orders 
WHERE created_at > '2014-12-05' 
;

SELECT
	primary_products.*, 
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0; 




SELECT 
	primary_product_id, 
    COUNT(DISTINCT order_id) AS total_orders, 
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS _xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS _xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS _xsold_p4,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p1_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM
(
SELECT
	primary_products.*, 
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0
) AS primary_w_cross_sell
GROUP BY 1;
