use mavenfuzzyfactory;
/*1.- Gsearch seems to be the biggest driver of our bussiness. Could you pull monthly
trends for gsearch sessions and orders so that we can showcase the growth there?*/

SELECT 
    YEAR(s.created_at) AS yr,
    MONTH(s.created_at) AS mo,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
	Round((COUNT(DISTINCT o.order_id)/COUNT(DISTINCT s.website_session_id))*100,2) as conv_rate
FROM
    website_sessions s
        LEFT JOIN
    orders o ON o.website_session_id = s.website_session_id
WHERE
    s.created_at < '2012-11-27'
        AND s.utm_source = 'gsearch'
GROUP BY 1 , 2;
----------------------------------------------------------------------------------------------------------------------------

/*2.- Next, it would be great to see similar monthly trend Gsearch, but this time splitting out nonbrand
and brand campanings separately. I am wondering if brand is picking up at all. If so , this a good story to tell*/

SELECT 
    YEAR(s.created_at) AS yr,
    MONTH(s.created_at) AS mo,
    COUNT(DISTINCT CASE
            WHEN utm_campaign = 'nonbrand' THEN s.website_session_id
            ELSE NULL
        END) AS nonbrand_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_campaign = 'nonbrand' THEN o.order_id
            ELSE NULL
        END) AS nonbrand_orders,
    COUNT(DISTINCT CASE
            WHEN utm_campaign = 'brand' THEN s.website_session_id
            ELSE NULL
        END) AS brand_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_campaign = 'brand' THEN o.order_id
            ELSE NULL
        END) AS brand_orders
FROM
    website_sessions s
        LEFT JOIN
    orders o ON o.website_session_id = s.website_session_id
WHERE
    s.created_at < '2012-11-27'
        AND s.utm_source = 'gsearch'
GROUP BY 1 , 2;
------------------------------------------------------------------------------------------------------------------------

/*3.- While we go on Gsearch, could you dice into nobrand and pull monthly sessions and orders to split by divice type?
I want to flex our analytical muscles a little and show the board we really know our traffic sources.*/

SELECT 
    YEAR(s.created_at) AS yr,
    MONTH(s.created_at) AS mo,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN s.website_session_id
            ELSE NULL
        END) AS desktop_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN o.order_id
            ELSE NULL
        END) AS desktop_orders,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN s.website_session_id
            ELSE NULL
        END) AS mobile_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN o.order_id
            ELSE NULL
        END) AS mobile_orders
FROM
    website_sessions s
        LEFT JOIN
    orders o ON o.website_session_id = s.website_session_id
WHERE
    s.created_at < '2012-11-27'
        AND s.utm_source = 'gsearch'
GROUP BY 1 , 2;
-----------------------------------------------------------------------------------------------------------------------------------
##First, finding the various Utm sources and referers to see the traffic we're getting

SELECT DISTINCT
    utm_source, utm_campaign, http_referer
FROM
    website_sessions
WHERE
    website_sessions.created_at < '2012-11-27';

SELECT 
    YEAR(s.created_at) AS yr,
    MONTH(s.created_at) AS mo,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN s.website_session_id
            ELSE NULL
        END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'bsearch' THEN s.website_session_id
            ELSE NULL
        END) AS bsearch_paid_sessionss,
    COUNT(DISTINCT CASE
            WHEN
                utm_source IS NULL
                    AND http_referer IS NOT NULL
            THEN
                s.website_session_id
            ELSE NULL
        END) AS organic_search_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source IS NULL
                    AND http_referer IS NULL
            THEN
                s.website_session_id
            ELSE NULL
        END) AS direct_type_in_sessions
FROM
    website_sessions s
        LEFT JOIN
    orders o ON o.website_session_id = s.website_session_id
WHERE
    s.created_at < '2012-11-27'
GROUP BY 1 , 2;
---------------------------------------------------------------------------------------------------------------------------
/*5.- I'd like to tell the story of our webside performance improvements over the cource of the first eight months.
could you pull sessions to order conversion rates, by month?*/

SELECT 
    YEAR(s.created_at) AS yr,
    MONTH(s.created_at) AS mo,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
	Round((COUNT(DISTINCT o.order_id)/COUNT(DISTINCT s.website_session_id))*100,2) as conv_rate
    FROM
    website_sessions s
        LEFT JOIN
    orders o ON o.website_session_id = s.website_session_id
WHERE
    s.created_at < '2012-11-27'
GROUP BY 1 , 2;
------------------------------------------------------------------------------------------------
/*6.- for gsearch lander test, please estimate the revenue that test erarned us.*/

SELECT 
    MIN(website_pageview_id) AS first_test_pv
FROM
    website_pageviews
WHERE
    pageview_url = '/lander-1';
    
/*create temporary table first_test_pageviews*/    
SELECT 
    p.website_session_id,
    MIN(p.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews p
        INNER JOIN
    website_sessions s ON s.website_session_id = p.website_session_id
        AND s.created_at < '2012-07-28'
        AND p.website_pageview_id >= 23504
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY p.website_session_id;
