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
  - [E. Bonus Question](#e-bonus-question)

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

**1. What are the standard ingredients for each pizza?**

it was much easier with postgreSQL due the fact it has arrays, i found 2 ways which it can be solved in MySQL workbench,
the first one is WITH RECURSIVE and regexp:

```sql
WITH RECURSIVE
  unwound AS (
    SELECT *
      FROM pizza_recipes
    UNION ALL
    SELECT pizza_id, regexp_replace(toppings, '^[^,]*,', '') toppings
      FROM unwound
      WHERE toppings LIKE '%,%'
  ),
  separate_toppings AS(
  SELECT pizza_id, regexp_replace(toppings, ',.*', '') topping_id
    FROM unwound
    ORDER BY pizza_id)
SELECT
pn.pizza_name, GROUP_CONCAT(pt.topping_name) AS recipie 
FROM
separate_toppings st
JOIN
pizza_toppings pt ON st.topping_id = pt.topping_id
JOIN
pizza_names pn ON st.pizza_id = pn.pizza_id
GROUP BY st.pizza_id;
```
the second way i found is with creating table and insert each pizza topping manully, and then group concat it:

```sql
DROP TABLE IF EXISTS pizza_help;
CREATE TABLE pizza_help (
    pizza_id INT,
    topping_id INT,
    PRIMARY KEY (pizza_id, topping_id)
);

INSERT INTO pizza_help (pizza_id, topping_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 8), (1, 10),
(2, 4), (2, 6), (2, 7), (2, 9), (2, 11), (2, 12);

SELECT 
     p.pizza_name,
    GROUP_CONCAT(t.topping_name SEPARATOR ', ') as all_toppings
FROM 
    pizza_names p
JOIN 
    pizza_help h ON p.pizza_id = h.pizza_id
JOIN 
    pizza_toppings t ON h.topping_id = t.topping_id
GROUP BY 
    p.pizza_name;
```
anyway, the result is the same:

| pizza_name  | recipie                                   		               |
|-------------|----------------------------------------------------------------------- |
| Meatlovers  | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami  |
| Vegetarian  | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce 	       |

**2. What was the most commonly added extra??**

```
WITH RECURSIVE
  unwound AS (
    SELECT order_id, extras
      FROM customer_orders
    UNION ALL
    SELECT order_id, regexp_replace(extras, '^[^,]*,', '') extras
      FROM unwound
      WHERE extras LIKE '%,%'
  ),
  separate_extras AS(
  SELECT order_id, regexp_replace(extras, ',.*', '') extras
    FROM unwound
    ORDER BY order_id)
SELECT 
    pt.topping_name, COUNT(*) as ordered
FROM
    separate_extras sp
JOIN
	pizza_toppings pt ON pt.topping_id = sp.extras
WHERE
    extras != 'null'
GROUP BY sp.extras
ORDER BY COUNT(*) DESC;
```

| topping_name | ordered |
|--------------|---------|
| Bacon        | 4       |
| Chicken      | 1       |
| Cheese       | 1       |

**3. What was the most common exclusions?**

```sql
WITH RECURSIVE
  unwound AS (
    SELECT order_id, exclusions
      FROM customer_orders
    UNION ALL
    SELECT order_id, regexp_replace(exclusions, '^[^,]*,', '') exclusions
      FROM unwound
      WHERE exclusions LIKE '%,%'
  ),
  separate_exclusions AS(
  SELECT order_id, regexp_replace(exclusions, ',.*', '') exclusions
    FROM unwound
    ORDER BY order_id)
SELECT 
    pt.topping_name, COUNT(*) as ordered
FROM
    separate_exclusions sp
JOIN
	pizza_toppings pt ON pt.topping_id = sp.exclusions
WHERE
    exclusions != 'null'
GROUP BY sp.exclusions
ORDER BY COUNT(*) DESC;
```

| Topping Name | Ordered |
|--------------|---------|
| Cheese       |    4    |
| BBQ Sauce    |    1    |
| Mushrooms    |    1    |

**4. Generate an order item for each record in the customers_orders table in the format of one of the following**

Meat Lovers

Meat Lovers - Exclude Beef

Meat Lovers - Extra Bacon

Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```sql
SELECT 
    co.order_id,
    CONCAT(pn.pizza_name,
            CASE
                WHEN co.extras = '' THEN ''
                WHEN co.extras = 'null' THEN ''
                WHEN co.extras IS NULL THEN ''
                ELSE CONCAT(' Extra ', (
                WITH RECURSIVE
				  unwound AS (
					SELECT  extras
					UNION ALL
					SELECT regexp_replace(extras, '^[^,]*,', '') exclusions
					  FROM unwound
					  WHERE extras LIKE '%,%'
				  ),
				  separate_extras AS(
				  SELECT regexp_replace(extras, ',.*', '') exclusions
					FROM unwound)
				SELECT
				group_concat(pt.topping_name)
				FROM 
				separate_extras se
				JOIN
				pizza_toppings pt ON se.exclusions = pt.topping_id)) END,
                CASE
                WHEN co.exclusions = '' THEN ''
                WHEN co.exclusions = 'null' THEN ''
                WHEN co.exclusions IS NULL THEN ''
                ELSE CONCAT(' Exlude ', (
                WITH RECURSIVE
				  unwound AS (
					SELECT  exclusions
					UNION ALL
					SELECT regexp_replace(exclusions, '^[^,]*,', '') exclusions
					  FROM unwound
					  WHERE exclusions LIKE '%,%'
				  ),
				  separate_exclusions AS(
				  SELECT regexp_replace(exclusions, ',.*', '') exclusions
					FROM unwound)
				SELECT
				group_concat(pt.topping_name)
				FROM 
				separate_exclusions se
				JOIN
				pizza_toppings pt ON se.exclusions = pt.topping_id)) END) as pizza_name
FROM
    customer_orders co
        JOIN
    pizza_names pn ON co.pizza_id = pn.pizza_id
        LEFT JOIN
    pizza_toppings pt ON co.extras = pt.topping_id
        LEFT JOIN
    pizza_toppings pt1 ON co.exclusions = pt1.topping_id;
```

| order_id | pizza_id | pizza_name                                                |
|----------|----------|-----------------------------------------------------------|
| 1        | 1        | Meatlovers                                                |
| 2        | 1        | Meatlovers                                                |
| 3        | 1        | Meatlovers                                                |
| 3        | 2        | Vegetarian                                                |
| 4        | 1        | Meatlovers exclude Cheese                                 |
| 4        | 1        | Meatlovers exclude Cheese                      		  |
| 4        | 2        | Vegetarian exclude Cheese                   	          |
| 5        | 1        | Meatlovers extra Bacon                      	          |
| 6        | 2        | Vegetarian                                   	 	  |
| 7        | 2        | Vegetarian extra Bacon                       	          |
| 8        | 1        | Meatlovers                                     		  |
| 9        | 1        | Meatlovers extra Bacon,Chicken exclude Cheese      	  |
| 10       | 1        | Meatlovers                                                |
| 10       | 1        | Meatlovers extra Bacon,Cheese exclude BBQ Sauce,Mushrooms |

**5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients**

**6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**

```sql
question 5+6 gives me a hard time because I can't use arrays on MySQL, later on, I will try to deal with those questions, as it's not worth the effort atm.
```

### D. Pricing And Ratings

**1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**

```sql
SELECT 
    co.pizza_id,
    COUNT(*) AS count_orders,
    (CASE
        WHEN pizza_id = 1 THEN COUNT(*) * 12
        ELSE COUNT(*) * 10
    END) AS sum_revenue
FROM
    customer_orders co
        JOIN
    runner_orders ro ON co.order_id = ro.order_id
WHERE
    ro.distance <> 'null'
GROUP BY pizza_id;
```

| pizza_id | count_orders | sum_revenue |
|----------|--------------|------------|
| 1        | 9            | 108        |
| 2        | 3            | 30         |

**2. What if there was an additional $1 charge for any pizza extras?**

```sql
WITH RECURSIVE
  unwound AS (
    SELECT order_id, extras
      FROM customer_orders
    UNION ALL
    SELECT order_id, regexp_replace(extras, '^[^,]*,', '') extras
      FROM unwound
      WHERE extras LIKE '%,%'
  ),
  separate_extras AS(
  SELECT order_id, regexp_replace(extras, ',.*', '') extras
    FROM unwound
    ORDER BY order_id),
count_extras AS (SELECT count(extras) AS count_extras
FROM
separate_extras 
WHERE extras <> 'null' AND length(extras) >= 1),
pizza_sum AS (SELECT 
    co.pizza_id,
    COUNT(*) AS count_orders,
    (CASE
        WHEN pizza_id = 1 THEN COUNT(*) * 12
        ELSE COUNT(*) * 10
    END) AS sum_revenue
FROM
    customer_orders co
        JOIN
    runner_orders ro ON co.order_id = ro.order_id
WHERE
    ro.distance <> 'null'
GROUP BY pizza_id)
SELECT
((SELECT SUM(sum_revenue) FROM pizza_sum) + (SELECT 1*count_extras FROM count_extras)) AS total_revenue;
```

| total_revenue |
|---------------|
| 144           |

**3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5** 

```sql
DROP TABLE IF EXISTS runner_rating;
CREATE TABLE runner_rating (
    id SERIAL PRIMARY KEY,
    order_id INTEGER,
    customer_id INTEGER,
    runner_id INTEGER,
    rating INTEGER,
    rating_time TIMESTAMP
  );
INSERT INTO
  runner_rating (
    order_id,
    customer_id,
    runner_id,
    rating,
    rating_time
  )
VALUES
  ('1', '101', '1', '5', '2020-01-01 19:34:51'),
  ('2', '101', '1', '5', '2020-01-01 20:23:03'),
  ('3', '102', '1', '4', '2020-01-03 10:12:58'),
  ('4', '103', '2', '5', '2020-01-04 16:47:06'),
  ('5', '104', '3', '5', '2020-01-08 23:09:27'),
  ('7', '105', '2', '4', '2020-01-08 23:50:12'),
  ('8', '102', '2', '4', '2020-01-10 12:30:45'),
  ('10', '104', '1', '5', '2020-01-11 20:05:35');
 SELECT
 *
 FROM
 runner_rating;
```

| id | order_id | customer_id | runner_id | rating | rating_time        |
|----|----------|-------------|-----------|--------|--------------------|
| 1  | 1        | 101         | 1         | 5      | 2020-01-01 19:34:51|
| 2  | 2        | 101         | 1         | 5      | 2020-01-01 20:23:03|
| 3  | 3        | 102         | 1         | 4      | 2020-01-03 10:12:58|
| 4  | 4        | 103         | 2         | 5      | 2020-01-04 16:47:06|
| 5  | 5        | 104         | 3         | 5      | 2020-01-08 23:09:27|
| 6  | 7        | 105         | 2         | 4      | 2020-01-08 23:50:12|
| 7  | 8        | 102         | 2         | 4      | 2020-01-10 12:30:45|
| 8  | 10       | 104         | 1         | 5      | 2020-01-11 20:05:35|

**4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?** 

```sql
SELECT 
    co.customer_id,
    ro.order_id,
    ro.runner_id,
    rr.id,
    rr.rating,
    co.order_time,
    ro.pickup_time,
    ro.duration,
    - TIMESTAMPDIFF(MINUTE,
        ro.pickup_time,
        co.order_time) AS time_to_pickup,
    ROUND((ro.distance / (ro.duration / 60)), 1) AS avg_speed,
    COUNT(*) AS pizza_num
FROM
    runner_orders ro
        JOIN
    customer_orders co ON ro.order_id = co.order_id
        JOIN
    runner_rating rr ON ro.order_id = rr.order_id
GROUP BY 2;
```

| customer_id | order_id | runner_id | id | rating | order_time           | pickup_time         | duration   | time_to_pickup | avg_speed | pizza_num |
|-------------|----------|-----------|----|--------|----------------------|---------------------|------------|----------------|-----------|-----------|
| 101         | 1        | 1         | 1  | 5      | 2020-01-01 18:05:02  | 2020-01-01 18:15:34 | 32 minutes | 10             | 37.5      | 1         |
| 101         | 2        | 1         | 2  | 5      | 2020-01-01 19:00:52  | 2020-01-01 19:10:54 | 27 minutes | 10             | 44.4      | 1         |
| 102         | 3        | 1         | 3  | 4      | 2020-01-02 23:51:23  | 2020-01-03 00:12:37 | 20 mins    | 21             | 40.2      | 2         |
| 103         | 4        | 2         | 4  | 5      | 2020-01-04 13:23:46  | 2020-01-04 13:53:03 | 40         | 29             | 35.1      | 3         |
| 104         | 5        | 3         | 5  | 5      | 2020-01-08 21:00:29  | 2020-01-08 21:10:57 | 15         | 10             | 40        | 1         |
| 105         | 7        | 2         | 6  | 4      | 2020-01-08 21:20:29  | 2020-01-08 21:30:45 | 25mins     | 10             | 60        | 1         |
| 102         | 8        | 2         | 7  | 4      | 2020-01-09 23:54:33  | 2020-01-10 00:15:02 | 15 minute  | 20             | 93.6      | 1         |
| 104         | 10       | 1         | 8  | 5      | 2020-01-11 18:34:49  | 2020-01-11 18:50:20 | 10minutes  | 15             | 60        | 2         |

**4. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?**

```sql
WITH pizza_revenue AS(
	SELECT 
    co.pizza_id,
    COUNT(*) AS count_orders,
    (CASE
        WHEN pizza_id = 1 THEN COUNT(*) * 12
        ELSE COUNT(*) * 10
    END) AS sum_revenue
FROM
    customer_orders co
        JOIN
    runner_orders ro ON co.order_id = ro.order_id
WHERE
    ro.distance <> 'null'
GROUP BY pizza_id)
SELECT
SUM(sum_revenue) - (SELECT SUM(distance)*0.3 FROM runner_orders WHERE distance <> 'null') AS total_revenue
FROM
pizza_revenue;
```

| total_revenue |
|--------------|
| 94.44        |

### E. Bonus Question

**If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?**

```sql
INSERT INTO
  pizza_runner.pizza_names (pizza_id, pizza_name)
VALUES
  (3, 'Supreme');
INSERT INTO
  pizza_runner.pizza_recipes (pizza_id, toppings)
VALUES
  (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
```
