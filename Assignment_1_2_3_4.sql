USE mavenfuzzyfactory;



SELECT
utm_source,
utm_campaign,
http_referer,
COUNT(DISTINCT website_sessions.website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
group by utm_source,utm_campaign,http_referer
ORDER BY sessions DESC;



SELECT
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
FROM website_sessions 
	LEFT JOIN orders 
		ON  orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-12' 
	AND utm_source='gsearch' 
    AND utm_campaign='nonbrand';



SELECT 
	DATE(created_at) as week_start_date,
	COUNT(DISTINCT website_sessions.website_session_id) as sessions
FROM website_sessions
WHERE created_at < '2012-05-10'
	AND utm_source='gsearch' 
    AND utm_campaign='nonbrand'
GROUP BY week(created_at);



SELECT 
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
    FROM website_sessions 
	LEFT JOIN orders 
		ON  orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-05-10' 
	AND utm_source='gsearch' 
    AND utm_campaign='nonbrand'
GROUP BY device_type;