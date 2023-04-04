-- DROP table repeat_sessions_w_users
CREATE TEMPORARY TABLE repeat_sessions_w_users
SELECT
	user_id,
	SUM(is_repeat_session) AS num_of_repeat_sessions
FROM website_sessions
WHERE created_at >'2014-01-01' 
	AND created_at < '2014-11-01'
GROUP BY user_id;

SELECT 
	COUNT(DISTINCT CASE WHEN num_of_repeat_sessions='0' THEN user_id ELSE NULL END) AS '0',
    COUNT(DISTINCT CASE WHEN num_of_repeat_sessions='1' THEN user_id ELSE NULL END) AS '1',
    COUNT(DISTINCT CASE WHEN num_of_repeat_sessions='2' THEN user_id ELSE NULL END) AS '2',
    COUNT(DISTINCT CASE WHEN num_of_repeat_sessions='3' THEN user_id ELSE NULL END) AS '3'
FROM repeat_sessions_w_users;



CREATE TEMPORARY TABLE new_user_list
SELECT
user_id AS new_users
FROM website_sessions
WHERE created_at >= '2014-01-01' and created_at < '2014-11-01'
AND is_repeat_session = '0' ;

SELECT
repeat_sessions,
count(new_users)
FROM
(SELECT
new_user_list.new_users,
CASE WHEN COUNT(website_sessions.website_session_id) = '1' THEN 0
WHEN COUNT(website_sessions.website_session_id) = '2' THEN 1
     WHEN COUNT(website_sessions.website_session_id) = '3' THEN 2
     WHEN COUNT(website_sessions.website_session_id) = '4' THEN 3 ELSE NULL END AS repeat_sessions
FROM new_user_list
LEFT JOIN website_sessions
ON website_sessions.user_id = new_user_list.new_users
where website_sessions.created_at >= '2014-01-01' and website_sessions.created_at < '2014-11-01'
GROUP BY 1) AS counts
GROUP BY 1
ORDER BY 1;


-- ASSIGNMENT 28


CREATE TEMPORARY TABLE sessions_w_repeats_for_time_diff
SELECT
	new_sessions.user_id,
    new_sessions.website_session_id AS new_session_id,
    new_sessions.created_at as new_session_created_at,
    website_sessions.website_session_id AS repeat_session_id,
    website_sessions.created_at AS repeat_session_created_at
FROM
(
SELECT
	user_id,
    website_session_id,
    created_at
FROM website_sessions
WHERE created_at <'2014-11-03'
	AND created_at >='2014-01-01'
    AND is_repeat_session = 0
) AS new_sessions
	LEFT JOIN website_sessions
    ON website_sessions.user_id = new_sessions.user_id
    AND website_sessions.is_repeat_session= 1
    AND website_sessions.website_session_id > new_sessions.website_session_id
    AND  website_sessions.created_at <'2014-11-03'
	AND  website_sessions.created_at >='2014-01-01';
    
    
CREATE TEMPORARY TABLE users_first_to_second
SELECT
user_id,
DATEDIFF(second_session_created_at, new_session_created_at) AS days_first_to_second_session
FROM
(
SELECT
	user_id,
    new_session_id,
    new_session_created_at,
    MIN(repeat_session_id) AS second_session_id,
    MIN(repeat_session_created_at) AS second_session_created_at
FROM sessions_w_repeats_for_time_diff
WHERE repeat_session_id IS NOT NULL
GROUP BY 1,2,3
) AS first_second;

SELECT
AVG(days_first_to_second_session) AS avg_second_session_day,
MAX(days_first_to_second_session) AS max_days,
MIN(days_first_to_second_session) AS min_days
from users_first_to_second;


-- ASSIGNMENT 29

CREATE TEMPORARY TABLE sessions_w_repeats_for_time_diff1
SELECT 
    COUNT(DISTINCT CASE WHEN new_sessions.utm_source= 'socialbook' then new_sessions.website_session_id ELSE NULL END) as paid_social_for_new_session
    -- website_sessions.website_session_id AS repeat_session_id,
    -- website_sessions.created_at AS repeat_session_created_at,
    -- website_sessions.utm_source AS repeat_session_utm_source
FROM
(
SELECT
	user_id,
    website_session_id,
    created_at,
    utm_source
FROM website_sessions
WHERE created_at <'2014-11-05'
	AND created_at >='2014-01-01'
    AND is_repeat_session = 0
) AS new_sessions
	LEFT JOIN website_sessions
    ON website_sessions.user_id = new_sessions.user_id
    AND website_sessions.is_repeat_session= 1
    AND website_sessions.website_session_id > new_sessions.website_session_id
    AND  website_sessions.created_at <'2014-11-05'
	AND  website_sessions.created_at >='2014-01-01';

-- ASSIGNMENT 30

SELECT 
	website_sessions.is_repeat_session AS is_repeat_session,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at <'2014-11-08'
	AND  website_sessions.created_at >='2014-01-01'
GROUP BY 1;