use mavenfuzzyfactory;

SELECT 
    utm_content,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    (COUNT(DISTINCT o.order_id)/COUNT(DISTINCT s.website_session_id))*100 AS sessions_to_order_convertion
FROM
    website_sessions s
        LEFT JOIN
    orders o ON o.website_session_id = s.website_session_id
WHERE
    s.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 1
ORDER BY sessions DESC;
--------------------------------------------------------------------------------------------------------------------

SELECT 
    YEARWEEK(s.created_at) AS yrwk,
    MIN(DATE(created_at)) AS weel_start_date,
    COUNT(DISTINCT s.website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN s.website_session_id
            ELSE NULL
        END) AS gsearch_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'bsearch' THEN s.website_session_id
            ELSE NULL
        END) AS bsearch_sessions
FROM
    website_sessions s
WHERE
    created_at > '2012-08.22'
        AND created_at < '2012-11-29'
        AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(s.created_at);
----------------------------------------------------------------------------------------------------------------------------
##Channel Characteristics

SELECT 
    s.utm_source,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN s.website_session_id
            ELSE NULL
        END) AS sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN s.website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT s.website_session_id) AS pct_mobile
FROM
    website_sessions s
WHERE
    created_at > '2012-08-22'
        AND created_at < '2012-11-30'
        AND utm_campaign = 'nonbrand'
GROUP BY utm_source;
----------------------------------------------------------------------------------------------------------
##Cross-channel Bid optimization
  SELECT 
    s.device_type,
    s.utm_source,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    (COUNT(DISTINCT o.order_id) / COUNT(DISTINCT s.website_session_id))*100 AS conv_rate
FROM
    website_sessions s
        LEFT JOIN
    orders o ON o.website_session_id = s.website_session_id
WHERE
    s.created_at > '2012-08-22'
        AND s.created_at < '2012-09-19'
        AND s.utm_campaign = 'nonbrand'
GROUP BY s.device_type , s.utm_source;
-------------------------------------------------------------------------------------------------------------------------
##Porfolio trends
SELECT 
    MIN(DATE(created_At)) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_dtop_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) * 100 AS b_pct_of_dtop,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS g_mob_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_mob_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) * 100 AS b_pct_of_mob
FROM
    website_sessions
WHERE
    created_at > '2012-11-04'
        AND created_at < '2012-12-22'
        AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at);

##Analyzing Direct traffic

SELECT DISTINCT
    CASE
        WHEN
            utm_source IS NULL
                AND http_referer IN ('https://www.gsearch.com' , 'https://www.bsearch.com')
        THEN
            'Organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'Paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'Paid_brand'
        WHEN
            utm_source IS NULL
                AND http_referer IS NULL
        THEN
            'direct_type_in'
    END AS channel_group,
    utm_source,
    utm_campaign,
    http_referer
FROM
    website_sessions
WHERE
    created_at < '2012-12-23';

SELECT 
    website_session_id,
    created_at,
    CASE
        WHEN
            utm_source IS NULL
                AND http_referer IN ('https://www.gsearch.com' , 'https://www.bsearch.com')
        THEN
            'Organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'Paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'Paid_brand'
        WHEN
            utm_source IS NULL
                AND http_referer IS NULL
        THEN
            'direct_type_in'
    END AS channel_group
FROM
    website_sessions
WHERE
    created_at < '2012-12-23';
    

SELECT 
    YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END) AS nonbrand,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_brand' THEN website_session_id
            ELSE NULL
        END) AS brand,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_brand' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END) AS brand_pct_of_nonbrand,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'direct_type_in' THEN website_session_id
            ELSE NULL
        END) AS direct,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'direct_type_in' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END) AS direct_pct_nonbrand,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'organic_search' THEN website_session_id
            ELSE NULL
        END) AS organic,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'organic_search' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END) AS organic_pct_nonbrand
FROM
    (SELECT 
        website_session_id,
            created_at,
            CASE
                WHEN
                    utm_source IS NULL
                        AND http_referer IN ('https://www.gsearch.com' , 'https://www.bsearch.com')
                THEN
                    'Organic_search'
                WHEN utm_campaign = 'nonbrand' THEN 'Paid_nonbrand'
                WHEN utm_campaign = 'brand' THEN 'Paid_brand'
                WHEN
                    utm_source IS NULL
                        AND http_referer IS NULL
                THEN
                    'direct_type_in'
            END AS channel_group
    FROM
        website_sessions
    WHERE
        created_at < '2012-12-23') AS session_w_channel_group
GROUP BY YEAR(created_at) , MONTH(created_at);


