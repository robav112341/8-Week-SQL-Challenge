########## Case Study #2 - Pizza Runner - Part II SQL 8 Week Challange ##########
-- Solutions By Robert Avdalimov:

-- A. Pizza Metrics:
-- Question 1:
-- How many pizzas were ordered?
SELECT 
    COUNT(*) AS number_of_pizzas
FROM
    customer_orders;

-- Question 2:
-- How many unique customer orders were made?
SELECT 
    customer_id, COUNT(DISTINCT order_id) AS unique_orders
FROM
    customer_orders
GROUP BY 1;

-- Question 3:
-- How many successful orders were delivered by each runner?
SELECT 
    runner_id, COUNT(*) AS num_of_orders
FROM
    runner_orders
WHERE
    cancellation NOT IN ('Restaurant Cancellation' , 'Customer Cancellation')
        OR cancellation IS NULL
GROUP BY 1;

-- Question 4:
-- How many of each type of pizza was delivered?
SELECT 
    co.pizza_id, pn.pizza_name, COUNT(*) AS num_of_orders
FROM
    customer_orders co
        JOIN
    pizza_names pn ON co.pizza_id = pn.pizza_id
        JOIN
    runner_orders ro ON co.order_id = ro.order_id
WHERE
    ro.cancellation NOT IN ('Restaurant Cancellation' , 'Customer Cancellation')
        OR ro.cancellation IS NULL
GROUP BY 1
ORDER BY 1;

-- Question 5:
-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
    co.customer_id, pn.pizza_name, COUNT(*) AS number_of_orders
FROM
    customer_orders co
        JOIN
    pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY 1 , 2
ORDER BY 1 , 2;

-- Question 6
-- What was the maximum number of pizzas delivered in a single order?
WITH cte AS(
	SELECT
    order_id,
    COUNT(*) AS count_products
    FROM
    customer_orders
    GROUP BY 1)
    SELECT
    c.order_id,
    c.count_products
    FROM
    cte c 
    JOIN runner_orders ro ON c.order_id = ro.order_id AND c.order_id = (SELECT order_id FROM cte WHERE count_products = (SELECT MAX(count_products) FROM cte))
    WHERE
    ro.cancellation NOT IN ('Restaurant Cancellation' , 'Customer Cancellation')
        OR cancellation IS NULL;
 
-- Question 7:
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
 WITH changed_cte AS (
	SELECT 
		co.customer_id,
		SUM(CASE
			WHEN
				(co.extras IS NOT NULL
					AND co.extras <> 'null'
					AND co.extras <> '')
					OR (co.exclusions IS NOT NULL
					AND co.exclusions <> 'null'
					AND exclusions <> '')
			THEN
				1
			ELSE 0
		END) AS changed
	FROM
		customer_orders co
	JOIN
    runner_orders ro ON co.order_id = ro.order_id
	WHERE
		distance <> 'null'
	GROUP BY 1
	ORDER BY 1),
unchanged_cte AS (
	SELECT 
		co.customer_id,
		SUM(CASE
			WHEN extras = '' AND exclusions = '' THEN 1
			WHEN extras = '' AND exclusions = 'null' THEN 1
			WHEN extras = 'null' AND exclusions = 'null' THEN 1
			WHEN extras = 'null' AND exclusions = '' THEN 1
			WHEN extras IS NULL AND exclusions = '' THEN 1
			WHEN extras = '' AND exclusions IS NULL THEN 1
			ELSE 0
		END) AS unchanged
	FROM
		customer_orders co
	JOIN
		runner_orders ro ON co.order_id = ro.order_id
	WHERE distance <> 'null'
	GROUP BY 1
	ORDER BY 1),
combined_cte AS (
	SELECT
		cc.customer_id,
		cc.changed,
		uc.unchanged
	FROM
		changed_cte cc
	JOIN
		unchanged_cte uc ON cc.customer_id = uc.customer_id)
SELECT
	cc.*
FROM
	combined_cte cc;

-- Question 8:
-- How many pizzas were delivered that had both exclusions and extras?
SELECT 
    COUNT(*) AS exatras_and_exclusions
FROM
    customer_orders co
JOIN
	runner_orders ro ON co.order_id = ro.order_id
WHERE
    LENGTH(co.exclusions) > 0
        AND LENGTH(co.extras) > 0
        AND co.exclusions <> 'null'
        AND co.extras <> 'null'
        AND ro.distance <> 'null';

-- Question 9
-- What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    HOUR(co.order_time) AS hours , COUNT(*) as count_volume
FROM
    customer_orders co
JOIN
	runner_orders ro ON co.order_id = ro.order_id
WHERE
	ro.distance <> 'null'
GROUP BY 1
ORDER BY 2 DESC, 1;

-- Question 10
-- What was the volume of orders for each day of the week?

SELECT 
    (SELECT 
            CASE
                    WHEN DAYOFWEEK(order_time) = 1 THEN 'Sunday'
                    WHEN DAYOFWEEK(order_time) = 2 THEN 'Monday'
                    WHEN DAYOFWEEK(order_time) = 3 THEN 'Tuesday'
                    WHEN DAYOFWEEK(order_time) = 4 THEN 'Wednesnday'
                    WHEN DAYOFWEEK(order_time) = 5 THEN 'Thursday'
                    WHEN DAYOFWEEK(order_time) = 6 THEN 'Friday'
                    ELSE 'Saturday'
                END
        ) AS the_day,
    COUNT(*) AS order_count
FROM
    customer_orders
GROUP BY DAYOFWEEK(order_time)
ORDER BY 2 DESC;

-- B.Runner and Customer Experience:
-- Question 1:
-- How many runners signed up for each 1 week period?
SELECT 
	CONCAT('Week', ' ', FLOOR((DAY(registration_date) - 1) / 7) + 1) AS Week,
    COUNT(*) AS count_runners
FROM
    runners
GROUP BY FLOOR((DAY(registration_date) - 1) / 7) + 1;

-- Question 2:
-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH cte AS (
	SELECT
		* 
	FROM 
		customer_orders
    GROUP BY order_id)
SELECT
	ro.runner_id,
   - ROUND(AVG(timestampdiff(MINUTE,ro.pickup_time,c.order_time)),1) AS avg_time
FROM
    cte c
        JOIN
    runner_orders ro ON c.order_id = ro.order_id
WHERE
    distance <> 'null'
GROUP BY 1;

-- Question 3:
-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH cte AS (
	SELECT 
		* 
	FROM 
		customer_orders
    GROUP BY order_id),
pizza_count AS (
	SELECT
		order_id,
		COUNT(*) AS pizza_count
    FROM 
		customer_orders
    GROUP BY 1)
SELECT
	c.order_id,
   - ROUND((timestampdiff(MINUTE,ro.pickup_time,c.order_time)),1) AS avg_pickup_time,
    pc.pizza_count,
	-(ROUND((timestampdiff(MINUTE,ro.pickup_time,c.order_time)/pc.pizza_count),1)) AS time_per_pizza
FROM
    cte c
        JOIN
    runner_orders ro ON c.order_id = ro.order_id
		JOIN
	pizza_count pc ON c.order_id = pc.order_id
WHERE
    timestampdiff(MINUTE,ro.pickup_time,c.order_time) IS NOT NULL; 

-- Question 4:
-- What was the average distance travelled for each customer?
SELECT 
    co.customer_id, ROUND(AVG(ro.distance), 1) AS avg_distance
FROM
    customer_orders co
        JOIN
    runner_orders ro ON co.order_id = ro.order_id
WHERE
    ro.distance != 'null'
GROUP BY 1; 

-- Question 5:
-- What was the difference between the longest and shortest delivery times for all orders?
WITH max_min AS (
	SELECT
	(SELECT MAX(duration) FROM runner_orders WHERE duration != 'null') AS max_duration,
    (SELECT MIN(duration) FROM runner_orders) AS min_duration)
    SELECT (max_duration - min_duration) AS max_sub_min FROM max_min;

-- Question 6:
-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
    order_id,
    runner_id,
    ROUND((distance / (duration / 60)), 0) AS avg_speed
FROM
    runner_orders
WHERE
    distance != 'null';
   
-- Question 7:
-- What is the successful delivery percentage for each runner?
SELECT 
    runner_id,
    COUNT(*) AS count_successful,
    ROUND(COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    runner_orders ro2
                WHERE
                    ro1.runner_id = ro2.runner_id
                GROUP BY ro2.runner_id) * 100,
            1) AS percentage
FROM
    runner_orders ro1
WHERE
    cancellation NOT IN ('Restaurant Cancellation' , 'Customer Cancellation')
        OR cancellation IS NULL
GROUP BY 1;

