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
