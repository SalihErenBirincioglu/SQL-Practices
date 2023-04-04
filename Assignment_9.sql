USE mavenfuzzyfactory;

select
  min(created_at) as first_created_at,

  min(website_pageview_id) as first_pageview_id

from website_pageviews

where pageview_url = '/lander-1'

and created_at is not null;



-- first_created_at = '2012-06-19 00:35:54',

-- first_pageview_id = '23504'



create temporary table first_test_pageviews

select

website_pageviews.website_session_id,

min(website_pageviews.website_pageview_id) as min_pageview_id

from website_pageviews

   inner join website_sessions

     on website_sessions.website_session_id =  website_pageviews.website_session_id

     and website_sessions.created_at <'2012-07-28' -- see assignment

     and website_pageviews.website_pageview_id >= 23504

     and utm_source = 'gsearch'

     and utm_campaign = 'nonbrand'

     group by

     website_pageviews.website_session_id;

     

-- Next we'll bring in the landing page to each session, like last time but restricting to home or lander-1 this time



Create temporary table nonbrand_test_sessions_w_landing_page

select
first_test_pageviews.website_session_id,
website_pageviews.pageview_url as landing_page
from first_test_pageviews
  left join website_pageviews
   on website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
where website_pageviews.pageview_url in ('/home','/lander-1');



-- Then a table to have count of pageviews per session

-- then limit it to just 'bounced_sessions'



Create temporary table nonbrand_test_bounced_sessions

select

nonbrand_test_sessions_w_landing_page.website_session_id,

nonbrand_test_sessions_w_landing_page.landing_page,

count(website_pageviews.website_pageview_id) as count_of_pages_viewed



from nonbrand_test_sessions_w_landing_page

left join website_pageviews

  on website_pageviews.website_session_id = nonbrand_test_sessions_w_landing_page.website_session_id



group by

nonbrand_test_sessions_w_landing_page.website_session_id,

nonbrand_test_sessions_w_landing_page.landing_page



having

count(website_pageviews.website_pageview_id)=1;



select

nonbrand_test_sessions_w_landing_page.landing_page,

nonbrand_test_sessions_w_landing_page.website_session_id,

nonbrand_test_bounced_sessions.website_session_id as bounced_website_session_id



from nonbrand_test_sessions_w_landing_page

  left join nonbrand_test_bounced_sessions

    on nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id

order by

nonbrand_test_sessions_w_landing_page.website_session_id;

-- now count

select

nonbrand_test_sessions_w_landing_page.landing_page,

count(distinct nonbrand_test_sessions_w_landing_page.website_session_id) as sessions,

count(distinct nonbrand_test_bounced_sessions.website_session_id) as bounced_sessions,

count(distinct nonbrand_test_bounced_sessions.website_session_id)/count(distinct nonbrand_test_sessions_w_landing_page.website_session_id) as bounce_ratio



from nonbrand_test_sessions_w_landing_page

  left join nonbrand_test_bounced_sessions

    on nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id

group by

nonbrand_test_sessions_w_landing_page.landing_page;