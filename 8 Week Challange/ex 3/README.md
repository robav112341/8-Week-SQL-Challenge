# 🥑 Case Study #3: Foodie-Fi 
<img src="https://user-images.githubusercontent.com/81607668/129742132-8e13c136-adf2-49c4-9866-dec6be0d30f0.png" width="500" height="520" alt="image">

## 📚 Table of Contents
- [Business Task](#problem-statement)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#case-Study-questions)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-3/). 

***
## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/129744449-37b3229b-80b2-4cce-b8e0-707d7f48dcec.png)

***
## Problem Statement

Danny realised that he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows! Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

This case study focuses on using subscription style digital data to answer important business questions.

## Case Study Questions

**Data Analysis Questions**
**1. How many customers has Foodie-Fi ever had?**

````sql
SELECT 
    COUNT(DISTINCT customer_id) AS number_of_customers
FROM
    subscriptions;
````

| number_of_customers       |
| ------------------------- |
| 1000                      |

**2. What is the monthly distribution of trial plan start_date values for our dataset?**

````sql
SELECT 
    MONTHNAME(start_date) AS month_, COUNT(customer_id) AS count_customers
FROM
    subscriptions
WHERE
    plan_id = 0
GROUP BY MONTH(start_date)
ORDER BY MONTH(start_date);
````

| MONTH   | number_of_customers    |
| ------- |  --------------------- |
| January   |  88                  |
| February  |  68                  |
| March     |  94                  |
| April     |  81                  |
| May       |  88                  |
| June      |  79                  |
| July      |  89                  |
| August    |  88                  |
| September |  87                  |
| October   |  79                  |
| November  |  75                  |
| December  |  84                  |

**3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name**

````sql
SELECT 
    s.plan_id,
    p.plan_name,
    COUNT(s.customer_id) AS customer_count
FROM
    subscriptions s
        JOIN
    plans p ON s.plan_id = p.plan_id
WHERE
    s.start_date > '2020-12-31'
GROUP BY s.plan_id
ORDER BY s.plan_id ASC;
````

| plan_id | plan_name     | customer_count   |
| ------- | ------------- | ---------------- |
| 1       | basic monthly | 8                |
| 2       | pro monthly   | 60               |
| 3       | pro annual    | 63               |
| 4       | churn         | 71               |

**4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**

````sql
SELECT 
    COUNT(*) AS churn,
    ROUND(COUNT(*) / (SELECT 
                    COUNT(DISTINCT customer_id)
                FROM
                    subscriptions)*100,
            1)  AS churn_precent
FROM
    subscriptions
WHERE
    plan_id = 4;
````

| churn             | churn_percent    |
| ----------------- | ---------------- |
| 307               | 30.7             |

**5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**

````sql
WITH cte AS (
	SELECT
		customer_id,
		plan_id AS current_plan,
		LAG(plan_id,1) OVER(PARTITION BY customer_id) AS pre_plan
    FROM
		subscriptions)
SELECT 
	COUNT(*) AS churn_count,
	ROUND(COUNT(*)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions)*100,1) AS churn_precentege
FROM
	cte
WHERE current_plan = 4 AND pre_plan = 0;
````

| churn_count | churn_precentege |
| ----------- | ---------------- |
| 92          |     9.2          |

**6. What is the number and percentage of customer plans after their initial free trial?**

````sql
WITH cte AS (
	SELECT
		customer_id,
		plan_id AS current_plan,
		LAG(plan_id,1) OVER(PARTITION BY customer_id) AS pre_plan
    FROM
		subscriptions)
SELECT 
	p.plan_name,
	COUNT(*) AS count,
	ROUND(COUNT(*)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions)*100,1) AS percentage_of_total  
FROM
	cte c
JOIN
	plans p ON c.current_plan = p.plan_id
WHERE pre_plan = 0
GROUP BY 1
ORDER BY 1;
````

| plan_name     | count                       | percentage_of_total           |
| ------------- | --------------------------- | ----------------------------- |
| basic monthly | 546                         | 54.6                          |
| churn         | 92                          | 9.2                           |
| pro annual    | 37                          | 3.7                           |
| pro monthly   | 325                         | 32.5                          |

**7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**

````sql
WITH cte AS (
	SELECT 
		customer_id,
		MAX(plan_id) AS max_plan,
		MAX(start_date) AS max_date
	FROM
		subscriptions
	WHERE
		start_date < '2020-12-31'
	GROUP BY customer_id)
SELECT
	p.plan_name,
	COUNT(c.customer_id) as count,
	ROUND(COUNT(c.customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions)*100,1) AS pracentage
FROM
	cte c
JOIN 
	plans p ON c.max_plan = p.plan_id
GROUP BY max_plan
ORDER BY 1;
````

| plan_name     | count           | pracentage |
| ------------- | --------------- | ---------- |
| basic monthly | 224             | 22.4       |
| churn         | 235             | 23.5       |
| pro annual    | 195             | 19.5       |
| pro monthly   | 327             | 32.7       |
| trial         | 19              | 1.9        |

**8. How many customers have upgraded to an annual plan in 2020?**

````sql
WITH cte AS(
	SELECT 
		customer_id,
		plan_id,
		LAG(plan_id,1) OVER (PARTITION BY customer_id) as p_plan
	FROM
		subscriptions
	WHERE  start_date < '2020-12-31')
SELECT
	(SELECT plan_name FROM plans WHERE plan_id = 3) as plan_name,
	COUNT(*) count_annual_upgrades
FROM
	cte 
WHERE plan_id = 3 AND p_plan IS NOT NULL;
````

| plan_name  | count_annual_upgrades |
| ---------  | --------------------- |
| pro annual |       195             |

**9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**

````sql
 WITH min_date AS (
	SELECT 
		customer_id,
		MIN(start_date) AS min_date
	FROM
		subscriptions
	GROUP BY customer_id),
now_date AS (
	SELECT 
		customer_id, 
		start_date AS now_date 
    FROM subscriptions 
    WHERE plan_id = 3)
SELECT
	(SELECT plan_name FROM plans WHERE plan_id = 3) as plan_name,	
	ROUND(AVG(nd.now_date - md.min_date),0) AS time_AVG
FROM now_date nd
JOIN min_date md ON nd.customer_id = md.customer_id;
````
| plan_name  | time_AVG                |
| ---------- | ----------------------- |
| pro annual | 105                     |

**10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**

````sql
 WITH min_date AS (
	SELECT 
		customer_id,
		start_date AS min_date
	FROM
		subscriptions
	 WHERE plan_id = 0
	GROUP BY customer_id),
now_date AS (
	SELECT 
		customer_id, 
		start_date AS now_date 
    FROM subscriptions 
    WHERE plan_id = 3)
SELECT
(SELECT plan_name FROM plans WHERE plan_id = 3) AS plan_name,
CASE
	WHEN nd.now_date - md.min_date < 31 THEN '0-30'
	WHEN nd.now_date - md.min_date BETWEEN 31 AND 60 THEN '31-60'
    WHEN nd.now_date - md.min_date BETWEEN 61 AND 90 THEN '61-90'
    WHEN nd.now_date - md.min_date BETWEEN 91 AND 120 THEN '91-120'
    WHEN nd.now_date - md.min_date BETWEEN 121 AND 150 THEN '121-150'
    WHEN nd.now_date - md.min_date BETWEEN 151 AND 180 THEN '151-180'
    WHEN nd.now_date - md.min_date BETWEEN 181 AND 210 THEN '181-210'
    WHEN nd.now_date - md.min_date BETWEEN 211 AND 240 THEN '211-240'
    WHEN nd.now_date - md.min_date BETWEEN 241 AND 271 THEN '241-270'
    WHEN nd.now_date - md.min_date BETWEEN 271 AND 300 THEN '271-300'
    WHEN nd.now_date - md.min_date BETWEEN 301 AND 330 THEN '301-330'
    WHEN nd.now_date - md.min_date BETWEEN 331 AND 360 THEN '331-360'
    ELSE '360+' END AS the_time_pass,
	COUNT(*) AS costumer_count,
    ROUND(AVG(nd.now_date - md.min_date),0) AS time_p_AVG
FROM now_date nd
JOIN min_date md ON nd.customer_id = md.customer_id
GROUP BY the_time_pass
ORDER BY CASE	
	WHEN the_time_pass = '0-30' THEN 1
    WHEN the_time_pass = '31-60' THEN 2
	WHEN the_time_pass = '61-90' THEN 3
    WHEN the_time_pass = '91-120' THEN 4
    WHEN the_time_pass = '121-150' THEN 5
    WHEN the_time_pass = '151-180' THEN 6
    WHEN the_time_pass = '181-210' THEN 7
    WHEN the_time_pass = '211-240' THEN 8
    WHEN the_time_pass = '241-270' THEN 9
    WHEN the_time_pass = '271-300' THEN 10
    WHEN the_time_pass = '301-330' THEN 11
	WHEN the_time_pass = '331-360' THEN 12
	WHEN the_time_pass = '360+' THEN 13 END;
````

| plan_name  | the_time_pass            | costumer_count      | time_p_AVG              |
| ---------- | ------------------------ | ------------------- | ----------------------- |
| pro annual | 0-30 days                | 49                  | 10                      |
| pro annual | 31-60 days               | 24                  | 42                      |
| pro annual | 61-90 days               | 34                  | 71                      |
| pro annual | 91-120 days              | 35                  | 101                     |
| pro annual | 121-150 days             | 42                  | 133                     |
| pro annual | 151-180 days             | 36                  | 162                     |
| pro annual | 181-210 days             | 26                  | 191                     |
| pro annual | 211-240 days             | 4                   | 224                     |
| pro annual | 241-270 days             | 5                   | 257                     |
| pro annual | 271-300 days             | 1                   | 285                     |
| pro annual | 301-330 days             | 1                   | 327                     |
| pro annual | 331-360 days             | 1                   | 346                     |

**11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**

````sql
WITH cte AS (
	SELECT
		customer_id,
		plan_id AS current_id,
		LAG(customer_id,1) OVER(PARTITION BY customer_id) AS pre_id,
		start_date
	FROM
		subscriptions)
SELECT
	COUNT(*) AS count_donwgrade
FROM
	cte
WHERE current_id = 1 AND pre_id = 2 AND YEAR(start_date) = 2020;
````

| count_donwgrade |
| --------------- |
|        0        |
