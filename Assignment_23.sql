USE mavenfuzzyfactory;

SELECT pageview_url,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_pageviews
WHERE created_at > '2014-01-06'
	AND created_at < '2014-04-10'
GROUP BY 1;

DROP TABLE products_pageviews;
CREATE TEMPORARY TABLE products_pageviews
SELECT 
	website_pageviews.website_session_id,
    pageview_url
FROM website_pageviews LEFT JOIN website_sessions  ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2014-01-06'
	AND website_sessions.created_at < '2014-04-10'
    AND pageview_url IN ('/the-forever-love-bear','/the-original-mr-fuzzy','/cart','/shipping','/billing-2','/thank-you-for-your-order');
-- GROUP BY 1,2;

CREATE TEMPORARY TABLE sessions_w_flags 
SELECT 
	products_pageviews.website_session_id,
    CASE WHEN products_pageviews.pageview_url ='/products' THEN 1 ELSE 0 END as products,
	CASE WHEN products_pageviews.pageview_url ='/the-forever-love-bear' THEN 1 ELSE 0 END AS lovebear,
    CASE WHEN products_pageviews.pageview_url ='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy,
    CASE WHEN products_pageviews.pageview_url ='/cart' THEN 1 ELSE 0 END AS cart,
    CASE WHEN products_pageviews.pageview_url ='/billing-2' THEN 1 ELSE 0 END AS billing,
    CASE WHEN products_pageviews.pageview_url ='/shipping' THEN 1 ELSE 0 END AS shipping,
    CASE WHEN products_pageviews.pageview_url ='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thnk_you
FROM products_pageviews 
	LEFT JOIN website_pageviews 
		ON  website_pageviews.website_session_id = products_pageviews.website_session_id;


CREATE TEMPORARY TABLE sessions_w_next_pgview_url    
SELECT
	sessions_w_next_pgview_id.website_session_id,
    website_pageviews.pageview_url AS next_pageview_url
FROM sessions_w_next_pgview_id
	LEFT JOIN website_pageviews
    ON website_pageviews.website_pageview_id = sessions_w_next_pgview_id.min_next_pgview_id;

SELECT 
	CASE 
		WHEN next_pageview_url='/the-original-mr-fuzzy' THEN 'mrfuzzy'
		WHEN next_pageview_url='/the-forever-love-bear' THEN 'lovebear'
        ELSE NULL
	END AS product_seen,
    COUNT(sessions_w_next_pgview_url.website_session_id) AS sessions
FROM sessions_w_next_pgview_url
GROUP BY 1;



SELECT 
    CASE
	WHEN product_type = 1 THEN 'mrfuzzy'
        WHEN product_type = 2 THEN 'lovebear'
        ELSE 'error, check again'
    END AS product_seen,
    SUM(to_cart)/COUNT(product_type) AS add_to_cart_click_rate,
    SUM(to_shipping)/SUM(to_cart) AS shipping_click_rate,
    SUM(to_billing)/SUM(to_shipping) AS billing_click_rate,
    SUM(to_thank_you)/SUM(to_billing) AS order_click_rate
FROM (SELECT
	website_pageviews.website_session_id AS sessions,
	MAX(CASE
	    WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1
	    WHEN pageview_url = '/the-forever-love-bear' THEN 2
	    ELSE NULL
	END) AS product_type,
	MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS to_cart,
	MAX(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS to_shipping,
	MAX(CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END) AS to_billing,
	MAX(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS to_thank_you
    FROM website_pageviews
    WHERE created_at < '2014-04-10' AND created_at > '2014-01-06'
    GROUP BY sessions) AS conv_funnel
WHERE product_type IN (1,2)
GROUP BY product_type;




