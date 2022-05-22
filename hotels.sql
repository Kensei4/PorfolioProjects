use hotel;
## united all the tables
with hotels as (
SELECT 
    *
FROM
    `2018`
union
SELECT 
    *
FROM
    `2019`
union
SELECT 
    *
FROM
    `2020`)
  SELECT 
    *
FROM
    hotels;
--------------------------------------------------------------------------------------------------------------------------

##  getting revenue per day
with hotels as (
SELECT 
    *
FROM
    `2018`
union
SELECT 
    *
FROM
    `2019`
union
SELECT 
    *
FROM
    `2020`)
  SELECT 
    (stays_in_week_nights+stays_in_weekend_nights)*adras revenue
FROM
    hotels;
-----------------------------------------------------------------------------------------------------------------------    
    
##  getting revenue per year, let's check if our revenue is growing
with hotels as (
SELECT 
    *
FROM
    `2018`
union
SELECT 
    *
FROM
    `2019`
union
SELECT 
    *
FROM
    `2020`)
 SELECT 
    arrival_date_year,
    ROUND(SUM((stays_in_week_nights + stays_in_weekend_nights) * adr),
            2) AS revenue
FROM
    hotels
GROUP BY arrival_date_year;
    --------------------------------------------------------------------------------------------------
    ##  getting revenue per hotel type, let's check if our revenue is growing
    with hotels as (
SELECT 
    *
FROM
    `2018`
union
SELECT 
    *
FROM
    `2019`
union
SELECT 
    *
FROM
    `2020`)
SELECT 
    arrival_date_year,
    hotel,
    ROUND(SUM((stays_in_week_nights + stays_in_weekend_nights) * adr),
            2) AS revenue
FROM
    hotels
GROUP BY arrival_date_year , hotel;
-----------------------------------------------------------------------------------------
##join with the market segment
    with hotels as (
SELECT 
    *
FROM
    `2018`
union
SELECT 
    *
FROM
    `2019`
union
SELECT 
    *
FROM
    `2020`)
SELECT 
    *
FROM
    hotels
        JOIN
    market_segment ON hotels.market_segment = market_segment.market_segment
		JOIN
    meal_cost ON meal_cost.meal=hotels.meal;