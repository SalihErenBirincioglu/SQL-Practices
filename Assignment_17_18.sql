
SELECT YEAR(created_at) AS yr,
	MONTH(created_at) as mo,
	COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN website_session_id ELSE NULL END) as brand_pct_to_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_to_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN website_session_id ELSE NULL END) AS organic,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN website_session_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN website_session_id ELSE NULL END) as organic_pct_of_nonbrand
FROM website_sessions 
WHERE created_at < '2012-12-23'
GROUP BY 1,2;



SELECT 
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders
FROM website_sessions LEFT JOIN orders
	ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at < '2013-01-02'
GROUP BY 1,2;

SELECT 
	MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders
FROM website_sessions LEFT JOIN orders
	ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at < '2013-01-02'
GROUP BY WEEK(website_sessions.created_at)