USE mavenfuzzyfactory;


SELECT
	-- DATE(created_at),
	HOUR(created_at) AS hr,
	ROUND(COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) ='0' THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 0 THEN DATE(created_at) else null end),1) AS mo,
    ROUND(COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) ='1' THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 0 THEN DATE(created_at) else null end),1) AS tue,
    ROUND(COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) ='2' THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 0 THEN DATE(created_at) else null end),1) AS wed,
    ROUND(COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) ='3' THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 0 THEN DATE(created_at) else null end),1) AS thur,
    ROUND(COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) ='4' THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 0 THEN DATE(created_at) else null end),1) AS fri,
    ROUND(COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) ='5' THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 0 THEN DATE(created_at) else null end),1) AS sat,
    ROUND(COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) ='6' THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 0 THEN DATE(created_at) else null end),1) AS sun
FROM website_sessions
WHERE created_at > '2012-09-15'
	AND created_at < '2012-11-15'
GROUP BY 1;




SELECT YEAR(created_at) AS yr,
	MONTH(created_at) as mo,
    COUNT(DISTINCT order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd) - SUM(cogs_usd) AS total_margin
	FROM orders
    WHERE created_at < '2013-01-04'
    GROUP BY 1,2;
    
    
    SELECT website_sessions.website_session_id,
    order_id
    FROM website_sessions LEFT JOIN orders ON  website_sessions.website_session_id= orders.website_session_id
    GROUP BY 1,2;    
    
    
SELECT 
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) as mo,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(website_sessions.website_session_id) AS conv_rate,
    SUM(orders.price_usd)/COUNT(website_sessions.website_session_id) AS revenue_per_session,
    COUNT(DISTINCT CASE WHEN orders.primary_product_id ='1' THEN order_id ELSE NULL END) AS product_one_orders,
    COUNT(DISTINCT CASE WHEN orders.primary_product_id ='2' THEN order_id ELSE NULL END) AS product_two_orders
FROM website_sessions 
LEFT JOIN orders 
	ON  website_sessions.website_session_id= orders.website_session_id
WHERE website_sessions.created_at < '2013-04-05'
GROUP BY 1,2;