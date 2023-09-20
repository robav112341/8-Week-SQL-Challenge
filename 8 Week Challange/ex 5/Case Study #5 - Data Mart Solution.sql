########## Case Study #5 - Data Mart - Part VI of SQL 8 Week Challange ##########
-- Solutions By Robert Avdalimov:
USE data_mart;
-- Case Study Questions
-- 1.Data Cleansing Steps
DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TABLE IF NOT EXISTS `clean_weekly_sales` (
    `week_date` DATE DEFAULT NULL,
    `week_number` INT DEFAULT NULL,
    `month_number` INT DEFAULT NULL,
    `calendar_year` INT DEFAULT NULL,
    `region` VARCHAR(15) DEFAULT NULL,
    `platform` VARCHAR(9) DEFAULT NULL,
    `segment` VARCHAR(4) DEFAULT NULL,
    `customer_type` VARCHAR(11) DEFAULT NULL,
    `demographic` VARCHAR(20) DEFAULT NULL,
    `transactions` INT DEFAULT NULL,
    `sales` INT DEFAULT NULL,
    `avg_transaction` DOUBLE DEFAULT NULL
);

INSERT INTO clean_weekly_sales (
week_date,
week_number,
month_number,
calendar_year,
region,
platform,
segment,
customer_type,
demographic,
transactions,
sales,
avg_transaction)
SELECT 
    STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,
    EXTRACT(WEEK FROM STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number,
    EXTRACT(MONTH FROM STR_TO_DATE(week_date, '%d/%m/%y')) AS month_number,
    EXTRACT(YEAR FROM STR_TO_DATE(week_date, '%d/%m/%y')) AS calendar_year,
    region,
    platform,
    segment,
    customer_type,
    (CASE
        WHEN SUBSTRING(segment, 1, 1) = 'C' THEN 'Couples'
        WHEN SUBSTRING(segment, 1, 1) = 'F' THEN 'Families'
        ELSE 'Unknown'
    END) AS demographic,
    transactions,
    sales,
    ROUND((sales / transactions), 1) AS avg_transaction 
FROM
    Weekly_sales
ORDER BY 4;

-- some kind of error in age_band, saved query for later use:
 SELECT 
    (CASE
        WHEN SUBSTRING(segment, 2, 2) = 1 THEN 'Young Adults'
        WHEN SUBSTRING(segment, 2, 2) = 2 THEN 'Middle Aged'
        WHEN SUBSTRING(segment, 2, 2) IN (3 , 4) THEN 'Retirees'
        ELSE 'Unknown'
    END) AS age_band
FROM
    clean_weekly_sales;
    
-- Data Exploration:
-- Question 1:
-- What day of the week is used for each week_date value?
SELECT 
    IF(DAYOFWEEK(week_date) = 2,
        'Monday',
        'ELSE') AS day_of_week
FROM
    clean_weekly_sales
GROUP BY DAYOFWEEK(week_date);

-- Question 2:
-- What range of week numbers are missing from the dataset?
WITH RECURSIVE weeks_list (week_number) AS (
	SELECT 1 
	UNION ALL
	SELECT week_number+1 FROM weeks_list WHERE week_number < 52
) 
SELECT 
	*
FROM
	weeks_list
WHERE week_number NOT IN ( SELECT week_number FROM clean_weekly_sales);

-- Question 3:
-- How many total transactions were there for each year in the dataset?
SELECT 
    calendar_year, SUM(transactions) AS total_transactions
FROM
    clean_weekly_sales
GROUP BY 1;

-- Question 4:
-- What is the total sales for each region for each month?
SELECT 
    region, month_number, SUM(sales)
FROM
    clean_weekly_sales
GROUP BY 1 , 2
ORDER BY 1 , 2;

-- Question 5:
-- What is the total count of transactions for each platform?
SELECT 
    platform, COUNT(transactions) AS count_transcations
FROM
    clean_weekly_sales
GROUP BY 1
ORDER BY 1;

-- Question 6:
-- What is the percentage of sales for Retail vs Shopify for each month?
SELECT 
    s1.calendar_year,
    s1.month_number,
    s1.platform,
    SUM(s1.sales) AS total_sales,
    ROUND((SUM(sales) / (SELECT 
                    SUM(s2.sales)
                FROM
                    clean_weekly_sales s2
                WHERE
                    s2.calendar_year = s1.calendar_year
                        AND s2.month_number = s1.month_number
                GROUP BY s2.calendar_year , s2.month_number)) * 100,
            1) AS precentage
FROM
    clean_weekly_sales s1
GROUP BY 1 , 2 , 3
ORDER BY 1 , 2 , 3;

-- Question 7
-- What is the percentage of sales by demographic for each year in the dataset?
SELECT 
    s1.calendar_year,
    s1.demographic,
    SUM(s1.sales) AS total_sales,
    ROUND((SUM(s1.sales) / (SELECT 
                    SUM(s2.sales)
                FROM
                    clean_weekly_sales s2
                WHERE
                    s1.calendar_year = s2.calendar_year
                GROUP BY s2.calendar_year)) * 100,
            1) AS total_sales_P
FROM
    clean_weekly_sales s1
GROUP BY 1 , 2
ORDER BY 1 , 2;

-- Question 8
-- What is the percentage of sales by demographic for each year in the dataset?
WITH full_data AS (
	SELECT 
    *,
    (CASE
        WHEN SUBSTRING(segment, 2, 2) = 1 THEN 'Young Adults'
        WHEN SUBSTRING(segment, 2, 2) = 2 THEN 'Middle Aged'
        WHEN SUBSTRING(segment, 2, 2) IN (3 , 4) THEN 'Retirees'
        ELSE 'Unknown'
    END) AS age_band
FROM
    clean_weekly_sales)
SELECT
	age_band,
	sum(sales)
FROM
	full_data
WHERE platform = 'Retail' AND age_band <> 'Unknown'
GROUP BY age_band
ORDER BY sum(sales) DESC
LIMIT 1;

-- Question 9
-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT 
    calendar_year,
    platform,
    ROUND(AVG(avg_transaction), 1) AS avg_transaction
FROM
    clean_weekly_sales
GROUP BY 1 , 2;

-- 3. Before & After Analysis
-- Question 1
-- What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
WITH w_number AS (
	SELECT 
		week_number
	FROM
		clean_weekly_sales
	WHERE
		week_date = '2020-06-15'
    GROUP BY week_number),
total_sales_before AS (
	SELECT sum(sales) as sum_before
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number) -4  AND (SELECT week_number FROM w_number) -1 AND calendar_year = 2020),
total_sales_after AS (
	SELECT sum(sales) as sum_after
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number)   AND (SELECT week_number FROM w_number) +3 AND calendar_year = 2020),
sum_table AS (
	SELECT (SELECT sum_before FROM total_sales_before) AS sales_before,
		(SELECT sum_after FROM total_sales_after) AS sales_after)
SELECT 
	sales_before,
    sales_after,
    -(sales_before-sales_after) AS change_in_sales,
    (sales_before/sales_after-1)*100 AS change_in_p
    FROM
    sum_table;

-- Question 2:
-- What about the entire 12 weeks before and after?
WITH w_number AS (
	SELECT 
		week_number
	FROM
		clean_weekly_sales
	WHERE
		week_date = '2020-06-15'
    GROUP BY week_number),
total_sales_before AS (
	SELECT sum(sales) as sum_before
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number) -12  AND (SELECT week_number FROM w_number) -1 AND calendar_year = 2020),
total_sales_after AS (
	SELECT sum(sales) as sum_after
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number)   AND (SELECT week_number FROM w_number) +11 AND calendar_year = 2020),
sum_table AS (
SELECT (SELECT sum_before FROM total_sales_before) AS sales_before,
		(SELECT sum_after FROM total_sales_after) AS sales_after)
SELECT 
	sales_before,
	sales_after,
    -(sales_before-sales_after) AS change_in_sales,
    (sales_before/sales_after-1)*100 AS change_in_p 
    FROM 
    sum_table;


-- Question 3:
-- What about the entire 12 weeks before and after?
WITH w_number AS (
	SELECT 
		week_number
	FROM
		clean_weekly_sales
	WHERE
		week_date = '2020-06-15'
    GROUP BY week_number),
total_sales_before AS (
	SELECT 
		calendar_year,
		sum(sales) as sum_before
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number) -4  AND (SELECT week_number FROM w_number) -1
    GROUP BY 1),
total_sales_after AS (
	SELECT
		calendar_year,
		sum(sales) as sum_after
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number)   AND (SELECT week_number FROM w_number) +3
    GROUP BY 1)
SELECT 
	s1.calendar_year,
	s1.sum_before,
	s2.sum_after,
	(s2.sum_after-s1.sum_before) as total_change,
	ROUND((s2.sum_after/s1.sum_before -1)*100,1) AS p_change
FROM
	total_sales_before s1 
JOIN
	total_sales_after s2
ON s1.calendar_year = s2.calendar_year;

-- Question 4:
-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
WITH w_number AS (
	SELECT 
		week_number
	FROM
	clean_weekly_sales
	WHERE
		week_date = '2020-06-15'
    GROUP BY week_number),
total_sales_before AS (
	SELECT
		customer_type,
		sum(sales) as sum_before
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number) -12  AND (SELECT week_number FROM w_number) -1 AND calendar_year = 2020
    GROUP BY 1),
total_sales_after AS (
	SELECT
		customer_type,
		sum(sales) as sum_after
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number)   AND (SELECT week_number FROM w_number) +11 AND calendar_year = 2020
    GROUP BY 1)
SELECT
	s1.customer_type,
	s1.sum_before,
	s2.sum_after,
	(s2.sum_after - s1.sum_before) as total_change,
	ROUND((s2.sum_after/s1.sum_before - 1)*100,2) as p_change
FROM
	total_sales_before s1
JOIN 
	total_sales_after s2 ON s1.customer_type = s2.customer_type
ORDER BY 5;