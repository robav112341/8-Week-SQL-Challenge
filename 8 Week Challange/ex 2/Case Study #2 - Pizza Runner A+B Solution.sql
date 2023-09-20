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
 WITH pizza_changed AS (SELECT 
    customer_id, COUNT(order_id) as changed_p
FROM
    customer_orders 
WHERE
    LENGTH(extras) > 0
        OR LENGTH(exclusions) > 0
        AND order_id IN (SELECT 
            order_id
        FROM
            runner_orders
        WHERE
            cancellation NOT IN ('Restaurant Cancellation' , 'Customer Cancellation')
                OR cancellation IS NULL)
GROUP BY 1),
no_change AS (SELECT customer_id, COUNT(*) as no_change FROM customer_orders WHERE LENGTH(extras) = 0
        AND LENGTH(exclusions) = 0 GROUP BY 1 ORDER BY 1)
SELECT
pc.customer_id,
pc.changed_p,
(SELECT CASE WHEN nc.no_change IS NULL THEN 0
ELSE nc.no_change END) as no_change
FROM pizza_changed pc
LEFT JOIN no_change nc ON pc.customer_id = nc.customer_id
ORDER BY 1;

-- Question 8:
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
    COUNT(*) extars_and_exclusions
FROM
    customer_orders co
        JOIN
    runner_orders ro ON co.order_id = ro.order_id
WHERE
    LENGTH(co.extras) > 0
        AND LENGTH(co.exclusions) > 0
        AND (ro.cancellation NOT IN ('Restaurant Cancellation' , 'Customer Cancellation')
        OR ro.cancellation IS NULL);

-- Question 9
-- What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    HOUR(order_time), COUNT(*)
FROM
    customer_orders
GROUP BY 1
ORDER BY 1;

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
GROUP BY DAYOFWEEK(order_time);

-- B.Runner and Customer Experience:
-- Question 1:
-- What is the successful delivery percentage for each runner?
SELECT 
    COUNT(*) AS count_runners,
    CONCAT('Week', ' ', WEEK(registration_date)) AS Week
FROM
    runners
GROUP BY WEEK(registration_date);

-- Question 2:
-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH cte AS (SELECT * FROM customer_orders GROUP BY order_id)
SELECT
	ro.runner_id,
   - ROUND(AVG(timestampdiff(MINUTE,ro.pickup_time,c.order_time)),1) AS avg_time
FROM
    cte c
        JOIN
    runner_orders ro ON c.order_id = ro.order_id
WHERE
    timestampdiff(MINUTE,ro.pickup_time,c.order_time) IS NOT NULL
GROUP BY 1; 

-- Question 3:
-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH cte AS (SELECT * FROM customer_orders GROUP BY order_id),
pizza_count AS (SELECT order_id, COUNT(*) AS pizza_number FROM customer_orders GROUP BY 1)
SELECT
	c.order_id,
   - ROUND((timestampdiff(MINUTE,ro.pickup_time,c.order_time)),1) AS avg_time,
    pc.pizza_number,
	-(ROUND((timestampdiff(MINUTE,ro.pickup_time,c.order_time)/pc.pizza_number),1)) AS time_per_pizza
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

