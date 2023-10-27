# 🍕 Case Study #2 Pizza Runner

<img src="https://user-images.githubusercontent.com/81607668/127271856-3c0d5b4a-baab-472c-9e24-3c1e3c3359b2.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- Solution
  - [A. Pizza Metrics](#a-pizza-metrics)
  - [B. Runner and Customer Experience](#b-runner-and-customer-experience)
  - [C. Ingredient Optimisation](#c-ingredient-optimisation)
  - [D. Pricing and Ratings](#d-pricing-and-ratings)

***

## Business Task
Danny is expanding his new Pizza Empire and at the same time, he wants to Uberize it, so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers. 

## Entity Relationship Diagram

![Pizza Runner](https://github.com/katiehuangx/8-Week-SQL-Challenge/assets/81607668/78099a4e-4d0e-421f-a560-b72e4321f530)

## Case Study Questions

### A. Pizza Metrics:

**1. How many pizzas were ordered?**

```sql
SELECT 
    COUNT(*) AS number_of_pizzas
FROM
    customer_orders;
```
| number_of_pizzas        |
| ----------------------- |
| 14                      |

**2. How many unique customer orders were made?**

```sql
SELECT 
    customer_id, COUNT(DISTINCT order_id) AS unique_orders
FROM
    customer_orders
GROUP BY 1;
```

| customer_id | unique_orders          |
| ----------- | ---------------------- |
| 101         | 3                      |
| 102         | 2                      |
| 103         | 2                      |
| 104         | 2                      |
| 105         | 1                      |

**3. How many successful orders were delivered by each runner?**

```sql
SELECT 
    runner_id, COUNT(*) AS num_of_orders
FROM
    runner_orders
WHERE
    cancellation NOT IN ('Restaurant Cancellation' , 'Customer Cancellation')
        OR cancellation IS NULL
GROUP BY 1;
```
| runner_id | num_of_orders    |
| --------- | ---------------- |
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |

**4. How many of each type of pizza was delivered?**

```sql
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
```

| pizza_id | pizza_name  | num_of_orders |
|----------|-------------|---------------|
| 1        | Meatlovers  | 9             |
| 2        | Vegetarian  | 3             |

**5. How many Vegetarian and Meatlovers were ordered by each customer?**

```sql
SELECT 
    co.customer_id, pn.pizza_name, COUNT(*) AS number_of_orders
FROM
    customer_orders co
        JOIN
    pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY 1 , 2
ORDER BY 1 , 2;
```
| customer_id | pizza_name | number_of_orders           |
| ----------- | ---------- | -------------------------- |
| 101         | Meatlovers | 2                          |
| 101         | Vegetarian | 1                          |
| 102         | Meatlovers | 2                          |
| 102         | Vegetarian | 1                          |
| 103         | Meatlovers | 3                          |
| 103         | Vegetarian | 1                          |
| 104         | Meatlovers | 3                          |
| 105         | Vegetarian | 1                          |

**6. What was the maximum number of pizzas delivered in a single order?**

```sql
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
```

| order_id | count_products |
|----------|----------------|
| 4        | 3              |

**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**

```sql
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
```

| customer_id | changed | unchanged |
|-------------|---------|-----------|
| 101         | 0       | 2         |
| 102         | 0       | 3         |
| 103         | 3       | 0         |
| 104         | 2       | 1         |
| 105         | 1       | 0         |

**8. How many pizzas were delivered that had both exclusions and extras?**

```sql
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
```

| exatras_and_exclusions |
| ---------------------- |
|           1            |

**9. What was the total volume of pizzas ordered for each hour of the day?**

```sql
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
```

| hours | count_volume |
|-------|--------------|
| 13    | 3            |
| 18    | 3            |
| 23    | 3            |
| 21    | 2            |
| 19    | 1            |

**10. What was the volume of orders for each day of the week?**

```sql
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
```

| the_day    | order_count |
|------------|-------------|
| Wednesday  | 5           |
| Saturday   | 5           |
| Thursday   | 3           |
| Friday     | 1           |

### B. Runner and Customer Experience

**1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**

```sql
SELECT 
	CONCAT('Week', ' ', FLOOR((DAY(registration_date) - 1) / 7) + 1) AS Week,
    COUNT(*) AS count_runners
FROM
    runners
GROUP BY FLOOR((DAY(registration_date) - 1) / 7) + 1;
```

| Week   | count_runners |
|--------|---------------|
| Week 1 | 2             |
| Week 2 | 1             |
| Week 3 | 1             |

**2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**

```sql
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
```

| runner_id | avg_time |
|-----------|----------|
| 1         | 14.0     |
| 2         | 19.7     |
| 3         | 10.0     |


**3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```sql
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
```
| order_id | avg_pickup_time | pizza_count | time_per_pizza |
|----------|-----------------|-------------|---------------|
| 1        | 10              | 1           | 10.0          |
| 2        | 10              | 1           | 10.0          |
| 3        | 21              | 2           | 10.5          |
| 4        | 29              | 3           | 9.7           |
| 5        | 10              | 1           | 10.0          |
| 7        | 10              | 1           | 10.0          |
| 8        | 20              | 1           | 20.0          |
| 10       | 15              | 2           | 7.5           |

I don't think there is any connection between the number of pizzas in the order, and the avg cooking time, but there sure is a relationship between the avg pick-up time and the pizzas count, the pickup time increases as the count is rising. 

**4. What was the average distance travelled for each customer?**

```sql
SELECT 
    co.customer_id, ROUND(AVG(ro.distance), 1) AS avg_distance
FROM
    customer_orders co
        JOIN
    runner_orders ro ON co.order_id = ro.order_id
WHERE
    ro.distance != 'null'
GROUP BY 1;
```

| customer_id | average_distance    |
|-------------|---------------------|
| 101         | 20                  |
| 102         | 16.7                |
| 103         | 23.4                |
| 104         | 10                  |
| 105         | 25                  |

**5. What was the difference between the longest and shortest delivery times for all orders?**

```sql
WITH max_min AS (
	SELECT
	(SELECT MAX(duration) FROM runner_orders WHERE duration != 'null') AS max_duration,
    (SELECT MIN(duration) FROM runner_orders) AS min_duration)
    SELECT (max_duration - min_duration) AS max_sub_min FROM max_min;
```

| max_sub_min |
|-------------|
| 30          |

**6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**

```sql
SELECT 
    order_id,
    runner_id,
    ROUND((distance / (duration / 60)), 0) AS avg_speed
FROM
    runner_orders
WHERE
    distance != 'null';
```
| order_id | runner_id | avg_speed |
|----------|-----------|-----------|
| 1        | 1         | 38        |
| 2        | 1         | 44        |
| 3        | 1         | 40        |
| 4        | 2         | 35        |
| 5        | 3         | 40        |
| 7        | 2         | 60        |
| 8        | 2         | 94        |
| 10       | 1         | 60        |

it is noticeable that the average speed of runners increases every order.

**7. What is the successful delivery percentage for each runner?**

```sql
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
```

| runner_id | count_successful | percentage |
|-----------|------------------|------------|
| 1         | 4                | 100.0      |
| 2         | 3                | 75.0       |
| 3         | 1                | 50.0       |

### C. Ingredient Optimisation

