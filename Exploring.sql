use mavenfuzzyfactory;
-------------------------------------------------------------------------------

## exploring tables
SELECT 
    utm_content,
    count(distinct website_session_id) as sessions
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 1000 AND 2000
Group by utm_content
order by count(distinct website_session_id) desc;
-------------------------------------------------------------------

## another way to order by
SELECT 
    utm_content,
    count(distinct website_session_id) as sessions
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 1000 AND 2000
Group by utm_content
order by sessions desc;
--------------------------------------------------------------------------------------------------

## the last way to use order by
SELECT 
    utm_content,
    count(distinct website_session_id) as sessions
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 1000 AND 2000
Group by 1
order by 2 desc;
-------------------------------------------------------------------------------

## join with order_website
SELECT 
    website_sessions.utm_content,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as session_to_order_conv_rt
FROM
    website_sessions
    left join orders
    on orders.website_session_id= website_sessions.website_session_id
WHERE
    website_sessions.website_session_id BETWEEN 1000 AND 2000
Group by 1
order by 2 desc;
---------------------------------------------------------------------------------------
##Fainding to traffic sources
SELECT 
    utm_source,
    utm_campaign,
	http_referer,
    count(distinct website_session_id) as sessions
FROM
    website_sessions
    where created_at< '2012-04-12'
Group by 1,2,3
order by 4 desc;
-------------------------------------------------------------------------------
##traffic source
SELECT 
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id)*100 as session_to_order_conv_rt
FROM
    website_sessions
    left join orders
    on orders.website_session_id= website_sessions.website_session_id
WHERE
   website_sessions.utm_campaign='nonbrand' 
   and website_sessions.created_at< '2012-04-14' 
   and website_sessions.utm_source='gsearch';
   ---------------------------------------------------------------
   ##bid optimization
SELECT 
year(created_at),
week(created_at),
min(date (created_at)) as week_start,
count( distinct website_session_id) as sessions
FROM
    website_sessions
WHERE
    website_session_id between 100000 and 115000
    group by 1,2;
-------------------------------------------------------------------------------------------
##pivot methond

SELECT 
    primary_product_id,
    count(distinct case when items_purchased=1 then order_id else null end) as count_single_items_order,
	count(distinct case when items_purchased=2 then order_id else null end) as count_two_items_order
FROM
    orders
WHERE
    order_id BETWEEN 31000 AND 32000
group by 1;
----------------------------------------------------------------------------------------------------
##traffic source trending
SELECT 
--year(created_at) as Yr,
--week(created_at) as Wk,
min(date (created_at)) as week_start,
count( distinct website_session_id) as sessions
FROM
    website_sessions
WHERE
    created_at <'2012-05-12'
    and utm_source='gsearch'
    and utm_campaign='nonbrand'
    group by 
    year(created_at),
    week(created_at);
    --------------------------------------------------------------------------------------------
    ##Optimization for Paid Traffic
    SELECT 
    w.device_type,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT w.website_session_id) AS sessions,
	round((COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id))*100,2) as Convertion_rate
FROM
     website_sessions w
        LEFT JOIN
    orders o ON o.website_session_id = w.website_session_id
WHERE
    w.created_at < '2012-05-11'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY 1;
-------------------------------------------------------------------------------------
##Trending w/ Granular Segments
SELECT 
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS count_single_items_order,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END) AS count_two_items_order
FROM
    website_sessions
WHERE
    created_at < '2012-06-09'
    AND created_at> '2012-04-15'
     AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at) , WEEK(created_at);
-------------------------------------------------------------------------------------------------------------
