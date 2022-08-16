use mavenfuzzyfactory;

## Analysing Seasonality
SELECT 
    YEAR(s.created_at) AS yr,
    WEEK(s.created_at) AS wk,
    MIN(DATE(s.created_at)) AS week_start,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM
    website_sessions s
        LEFT JOIN
    orders o ON s.website_session_id = o.website_session_id
WHERE
    s.created_at < '2013-01-01'
GROUP BY 1 , 2;

##Analysis Business Paterns

SELECT 
    hr,
    ROUND(AVG(website_sessions), 2) AS avg_sessions,
    ROUND(AVG(CASE
                WHEN wkday = 0 THEN website_sessions
                ELSE NULL
            END),
            2) AS mon,
    ROUND(AVG(CASE
                WHEN wkday = 1 THEN website_sessions
                ELSE NULL
            END),
            2) AS tues,
    ROUND(AVG(CASE
                WHEN wkday = 2 THEN website_sessions
                ELSE NULL
            END),
            2) AS weds,
    ROUND(AVG(CASE
                WHEN wkday = 3 THEN website_sessions
                ELSE NULL
            END),
            2) AS thurs,
    ROUND(AVG(CASE
                WHEN wkday = 4 THEN website_sessions
                ELSE NULL
            END),
            2) AS fri,
    ROUND(AVG(CASE
                WHEN wkday = 5 THEN website_sessions
                ELSE NULL
            END),
            2) AS sat,
    ROUND(AVG(CASE
                WHEN wkday = 6 THEN website_sessions
                ELSE NULL
            END),
            2) AS sun
FROM
    (SELECT 
        DATE(created_at) AS created_date,
            WEEKDAY(created_at) AS wkday,
            HOUR(created_at) AS hr,
            COUNT(DISTINCT website_session_id) AS website_sessions
    FROM
        website_sessions
    WHERE
        created_at BETWEEN '2012-09-15' AND '2012-11-15'
    GROUP BY 1 , 2 , 3) AS daily_hourly_sessions
GROUP BY 1;