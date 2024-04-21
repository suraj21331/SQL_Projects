-- ----------------------------------------------- CAPSTONE PROJECT ---------------------------------------------------------------------------------------------------------

CREATE DATABASE cryptopunks;

SELECT count(*) FROM cryptopunkdata;

SELECT * FROM cryptopunkdata;




-- 1) How many sales occurred during this time period? 

SELECT count(*) As count_sales
FROM cryptopunkdata
WHERE STR_TO_DATE(day, '%m/%d/%y') BETWEEN '2018-01-01' AND '2021-12-31';

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2) Return the top 5 most expensive transactions (by USD price) for this data set. Return the name, ETH price, and USD price, as well as the date.

SELECT name, ETH_price, usd_price , day
FROM cryptopunkdata
order by usd_price desc
LIMIT 5 ;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3) Return a table with a row for each transaction with an event column, a USD price column, and a moving average of USD price that averages the last 50 transactions.

SELECT * , AVG(usd_price) OVER(ORDER BY day ROWS BETWEEN 49 PRECEDING AND CURRENT ROW ) AS moving_average
FROM cryptopunkdata;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4) Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.

SELECT name, avg(usd_price)AS average_price 
FROM cryptopunkdata
GROUP BY name 
Order BY average_price desc;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5)Return each day of the week and the number of sales that occurred on that day of the week, as well as the average price in ETH. Order by the count of transactions in ascending order.

SELECT DAYNAME(STR_TO_DATE(day, '%m/%d/%y')) AS day_of_week,
COUNT(*) As transaction_count,
AVG(eth_price) AS average_price_eth
FROM cryptopunkdata
GROUP BY day_of_week 
ORDER BY transaction_count ASC;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6) Construct a column that describes each sale and is called summary. The sentence should include who sold the NFT name, who bought the NFT, who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.
 -- Here’s an example summary:
  -- “CryptoPunk #1139 was sold for $194000 to 0x91338ccfb8c0adb7756034a82008531d7713009d from 0x1593110441ab4c5f2c133f21b0743b2b43e297cb on 2022-01-14”

SELECT concat(name, ' was sold for $', ROUND(usd_price,3), ' to ' , buyer_address , ' from ', seller_address, ' on ', day)
AS summary FROM cryptopunkdata;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 7) Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.

CREATE VIEW 1919_purchases AS 
SELECT * FROM cryptopunkdata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

SELECT * FROM 1919_purchases;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 8) Create a histogram of ETH price ranges. Round to the nearest hundred value. 

SELECT ROUND(eth_price,-2) AS Eth_price_range , 
COUNT(*) AS count,
RPAD('',COUNT(*),'.') AS histogram
FROM cryptopunkdata
GROUP BY Eth_price_range 
ORDER BY Eth_price_range ;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 9) Return a unioned query that contains the highest price each NFT was bought for and a new column called status saying “highest” with a query that has the lowest price each NFT was bought for and the status column saying “lowest”. The table should have a name column, a price column called price, and a status column. Order the result set by the name of the NFT, and the status, in ascending order. 

SELECT name, MAX(usd_price) As price ,
'highest' AS status 
FROM cryptopunkdata
GROUP BY name 

UNION ALL 

SELECT name, MIN(usd_price) as price,
'lowest' AS status
FROM cryptopunkdata
GROUP BY name 
ORDER BY name,status ASC;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
-- 10) What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format. 

SELECT 
    MONTH(STR_TO_DATE(day, '%m/%d/%Y')) AS month,
    YEAR(STR_TO_DATE(day, '%m/%d/%Y')) AS year,
    name AS nft_name,
    MAX(usd_price) AS price_usd
FROM 
    cryptopunkdata
GROUP BY 
	MONTH(STR_TO_DATE(day, '%m/%d/%Y')),
	YEAR(STR_TO_DATE(day, '%m/%d/%Y')),
    name
ORDER BY 
    year, month;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 11) Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).

SELECT DATE_FORMAT(STR_TO_DATE(day, '%m/%d/%y'), '%m-%Y')AS month_year,
ROUND(SUM(usd_price),-2) AS total_volume
FROM cryptopunkdata
GROUP BY date_format(STR_TO_DATE(day, '%m/%d/%y'), '%m-%Y')
ORDER BY date_format(STR_TO_DATE(day, '%m/%d/%y'), '%m-%Y');

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 -- 12) Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.
 
 SELECT 
    COUNT(*) AS transaction_count
FROM 
    cryptopunkdata
WHERE 
    buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685'
    OR seller_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 13) Create an “estimated average value calculator” that has a representative price of the collection every day based off of these criteria:
 -- EXclude all daily outlier sales where the purchase price is below 10% of the daily average price
 -- Take the daily average of remaining transactions
 -- a) First create a query that will be used as a subquery. Select the event date, the USD price, and the average USD price for each day using a window function. Save it as a temporary table.
 -- b) se the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average and return a new estimated value which is just the daily average of the filtered data.

CREATE temporary TABLE temp_daily_average AS 
SELECT day AS event_date, usd_price,AVG(usd_price) OVER (partition by day ) AS daily_average
FROM cryptopunkdata;

SELECT event_date,
AVG(usd_price) AS estimated_average_value
FROM temp_daily_average
WHERE usd_price >=0.1 * daily_average
GROUP BY event_date;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------