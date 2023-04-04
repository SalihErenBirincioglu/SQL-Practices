USE mavenfuzzyfactory;



SELECT
	device_type as device,
	utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN order_id IS NOT NULL THEN orders.website_session_id ELSE NULL END) AS orders,
    COUNT(DISTINCT CASE WHEN order_id IS NOT NULL THEN orders.website_session_id ELSE NULL END) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
    FROM website_sessions LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
	WHERE website_sessions.created_at > '2012-08-22' 
	AND website_sessions.created_at < '2012-09-18'
    AND utm_campaign= 'nonbrand'
GROUP BY device_type,utm_source;



SELECT
	MIN(DATE(website_sessions.created_at)) AS session_month,
        COUNT(DISTINCT CASE WHEN device_type='desktop' AND utm_source='gsearch' THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type='desktop' AND utm_source='bsearch' THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
	COUNT(DISTINCT CASE WHEN device_type='desktop' AND utm_source='bsearch' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN device_type='desktop' AND utm_source='gsearch' THEN website_session_id ELSE NULL END) AS b_pct_of_g_dtop, 
    COUNT(DISTINCT CASE WHEN device_type='mobile' AND utm_source='gsearch' THEN website_session_id ELSE NULL END) AS g_mob_sessions,
    COUNT(DISTINCT CASE WHEN device_type='mobile' AND utm_source='bsearch' THEN website_session_id ELSE NULL END) AS b_mob_sessions,
	COUNT(DISTINCT CASE WHEN device_type='mobile' AND utm_source='bsearch' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN device_type='mobile' AND utm_source='gsearch' THEN website_session_id ELSE NULL END) AS b_pct_of_g_mob 
    FROM website_sessions
	WHERE website_sessions.created_at > '2012-11-04' 
	AND website_sessions.created_at < '2012-12-22'
    AND utm_campaign= 'nonbrand'
GROUP BY WEEK(website_sessions.created_at);