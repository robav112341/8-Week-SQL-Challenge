-- Question 1:
-- How many customers has Foodie-Fi ever had?
SELECT 
    COUNT(DISTINCT customer_id) AS number_of_customers
FROM
    subscriptions;

-- Question 2:
-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT 
    MONTHNAME(start_date) AS month_, COUNT(customer_id)
FROM
    subscriptions
WHERE
    plan_id = 0
GROUP BY MONTH(start_date)
ORDER BY MONTH(start_date);

-- Question 3:
-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT 
    s.plan_id,
    p.plan_name,
    COUNT(s.customer_id) AS costomer_count
FROM
    subscriptions s
        JOIN
    plans p ON s.plan_id = p.plan_id
WHERE
    s.start_date > '2020-12-31'
GROUP BY s.plan_id
ORDER BY s.plan_id ASC;

-- Question 4
-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
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

-- Question 5
-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
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

-- Question 6:
-- What is the number and percentage of customer plans after their initial free trial?
WITH cte AS (
	SELECT
		customer_id,
		plan_id AS current_plan,
		LAG(plan_id,1) OVER(PARTITION BY customer_id) AS pre_plan
    FROM
		subscriptions)
SELECT 
current_plan,
	COUNT(*) AS churn_count,
	ROUND(COUNT(*)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions)*100,1) AS churn_precentege
FROM
	cte
WHERE pre_plan = 0
GROUP BY current_plan;

-- Question 7
-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
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
	max_plan as plan,
	COUNT(customer_id) as count_p,
	ROUND(COUNT(customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions)*100,1) AS pracentage
FROM
	cte
GROUP BY max_plan;

-- Question 8
-- How many customers have upgraded to an annual plan in 2020?
WITH cte AS(
	SELECT 
		customer_id,
		plan_id,
		LAG(plan_id,1) OVER (PARTITION BY customer_id) as p_plan
	FROM
		subscriptions
	WHERE  start_date < '2020-12-31')
SELECT
	COUNT(*) 
FROM
	cte 
WHERE plan_id = 3 AND p_plan IS NOT NULL;

-- Question 9 (there is some kind of error in the date sub)
-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
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
	ROUND(AVG(nd.now_date - md.min_date),0) AS time_p
FROM now_date nd
JOIN min_date md ON nd.customer_id = md.customer_id;

-- Question 10 :
-- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
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
CASE
	WHEN nd.now_date - md.min_date < 31 THEN '0-30'
	WHEN nd.now_date - md.min_date BETWEEN 31 AND 60 THEN '31-60'
    WHEN nd.now_date - md.min_date BETWEEN 61 AND 90 THEN '61-90'
    ELSE '90+' END AS the_time_pass,
	ROUND(AVG(nd.now_date - md.min_date),0) AS time_p_AVG,
	COUNT(*) AS costumer_count
FROM now_date nd
JOIN min_date md ON nd.customer_id = md.customer_id
GROUP BY the_time_pass
ORDER BY CASE	
	WHEN the_time_pass = '0-30' THEN 1
	WHEN the_time_pass = '61-90' THEN 2
ELSE 3 END;

-- Qustion 11
-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
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
