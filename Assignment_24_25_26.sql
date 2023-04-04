SELECT
	CASE
	WHEN website_pageviews.created_at < '2013-09-25' THEN 'A.Pre_Cross_Sell'
	WHEN website_pageviews.created_at >= '2013-09-25' THEN 'B.Post_Cross_Sell'
	ELSE 'logic_error'
END AS time_period
    ,COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/cart' THEN website_pageviews.website_session_id ELSE NULL END) AS cart_sessions
    ,COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/shipping' THEN website_pageviews.website_session_id ELSE NULL END) AS clicktroughs
    ,COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/shipping' THEN website_pageviews.website_session_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/cart' THEN website_pageviews.website_session_id ELSE NULL END) AS cart_crt
    ,sum(orders.items_purchased)/COUNT(orders.order_id) AS products_per_order
    ,AVG(orders.price_usd) AS AOV
    ,SUM(CASE WHEN website_pageviews.pageview_url ='/cart' THEN orders.price_usd  ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/cart' THEN website_pageviews.website_session_id ELSE NULL END) AS rev_per_cart_sessions
FROM website_pageviews
	LEFT JOIN orders
	ON website_pageviews.website_session_id = orders.website_session_id
WHERE
	website_pageviews.created_at > '2013-08-25'
	AND website_pageviews.created_at < '2013-10-25'
GROUP BY 1;


SELECT
	CASE
	WHEN website_sessions.created_at < '2013-12-12' THEN 'A.Pre_Birthday_Sell'
	WHEN website_sessions.created_at >= '2013-12-12' THEN 'B.Post_Birthday_Bear'
	ELSE 'logic_error'
END AS time_period
    ,COUNT(orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order
    ,AVG(orders.price_usd) AS AOV
    ,sum(orders.items_purchased)/COUNT(orders.order_id) AS products_per_order
    ,SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_session
FROM website_sessions
	LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at > '2013-11-12'
	AND website_sessions.created_at < '2014-01-12'
GROUP BY 1;


SELECT YEAR(order_items.created_at) AS yr,
	MONTH(order_items.created_at) as mo,
    COUNT(DISTINCT CASE WHEN product_id ='1' THEN order_items.order_id ELSE NULL END) AS p1_orders,
    COUNT(DISTINCT CASE WHEN product_id ='1' AND order_item_refunds.order_item_refund_id IS NOT NULL THEN order_items.order_id ELSE NULL END)/ 
    COUNT(DISTINCT CASE WHEN product_id ='1' THEN order_items.order_id ELSE NULL END) AS p1_refund_rate,
    COUNT(DISTINCT CASE WHEN product_id ='2' THEN order_items.order_id ELSE NULL END) AS p2_orders,
    COUNT(DISTINCT CASE WHEN product_id ='2' AND order_item_refunds.order_item_refund_id IS NOT NULL THEN order_items.order_id ELSE NULL END) AS p2_refund_orders,
    COUNT(DISTINCT CASE WHEN product_id ='3' THEN order_items.order_id ELSE NULL END) AS p3_orders,
    COUNT(DISTINCT CASE WHEN product_id ='3' AND order_item_refunds.order_item_refund_id IS NOT NULL THEN order_items.order_id ELSE NULL END) AS p3_refund_orders
FROM order_items
	LEFT JOIN order_item_refunds
		ON order_items.order_id = order_item_refunds.order_id
WHERE order_items.created_at <'2014-10-15'
GROUP BY 1,2;









