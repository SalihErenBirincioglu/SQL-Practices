USE mavenfuzzyfactory;

-- DROP TABLE products_pageviews;
CREATE TEMPORARY TABLE products_pageviews
SELECT 
	website_session_id,
    website_pageview_id,
    created_at,
	CASE
		WHEN created_at < '2013-01-06' THEN 'A. Pre_Product_1'
        WHEN created_at >= '2013-01-06' THEN 'B. Post_Product_2'
        ELSE 'something wrong'
	END AS time_period
FROM website_pageviews
WHERE created_at < '2013-04-06'
	AND created_at > '2012-10-06'
	AND pageview_url='/products';
    
CREATE TEMPORARY TABLE sessions_w_next_pgview_id    
SELECT 
	time_period,
	products_pageviews.website_session_id,
	MIN(website_pageviews.website_pageview_id) AS min_next_pgview_id
FROM products_pageviews 
	LEFT JOIN website_pageviews 
		ON  website_pageviews.website_session_id = products_pageviews.website_session_id
        AND  website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
GROUP BY 1,2;

CREATE TEMPORARY TABLE sessions_w_next_pgview_url    
SELECT sessions_w_next_pgview_id.time_period,
	sessions_w_next_pgview_id.website_session_id,
    website_pageviews.pageview_url AS next_pageview_url
FROM sessions_w_next_pgview_id
	LEFT JOIN website_pageviews
    ON website_pageviews.website_pageview_id = sessions_w_next_pgview_id.min_next_pgview_id;
    
    
    
SELECT 
	time_period,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS sessions_w_next_page,
	COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS sessions_w_next_page_percentage,
    COUNT(DISTINCT CASE WHEN next_pageview_url ='/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mr_fuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url ='/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS percentage_to_mr_fuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url ='/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_love_bear,
    COUNT(DISTINCT CASE WHEN next_pageview_url ='/the-forever-love-bear' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS percentage_to_love_bear
FROM sessions_w_next_pgview_url
GROUP BY 1;