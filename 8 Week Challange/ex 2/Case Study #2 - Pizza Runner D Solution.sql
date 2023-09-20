########## Case Study #2 - Pizza Runner - Part II SQL 8 Week Challange ##########
-- Solutions By Robert Avdalimov:

-- D. Pricing and Ratings
-- Question 1:
-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
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

-- Question 2:
-- What if there was an additional $1 charge for any pizza extras?
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

-- Question 3:
-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
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
 
-- Question 4: 
-- Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
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

-- Question 4: 
-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
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

-- E.Bonus Question:
-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
INSERT INTO
  pizza_runner.pizza_names (pizza_id, pizza_name)
VALUES
  (3, 'Supreme');
INSERT INTO
  pizza_runner.pizza_recipes (pizza_id, toppings)
VALUES
  (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');