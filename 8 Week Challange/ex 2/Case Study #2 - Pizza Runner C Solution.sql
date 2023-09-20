########## Case Study #2 - Pizza Runner - Part II SQL 8 Week Challange ##########
-- Solutions By Robert Avdalimov:

-- C. Pizza Metrics:
-- Question 1:
-- What are the standard ingredients for each pizza?
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

-- Question 2:
-- What was the most commonly added extra?

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

-- Question 3:
-- What was the most common exclusions?
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

-- Question 4:
-- Generate an order item for each record in the customers_orders table in the format of one of the following:
#Meat Lovers
#Meat Lovers - Exclude Beef
#Meat Lovers - Extra Bacon
#Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
SELECT 
    co.order_id,
    co.pizza_id,
    (CASE
        WHEN
            (LENGTH(co.extras) = 0
                AND LENGTH(co.exclusions) = 0
                OR (co.extras = 'null'
                AND co.exclusions = 'null')
                OR (LENGTH(co.extras) = 0
                AND co.exclusions IS NULL)
                OR (co.extras IS NULL
                AND LENGTH(co.exclusions) = 0))
        THEN
            pn.pizza_name
        WHEN
            ((LENGTH(co.extras) = 1
                AND LENGTH(co.exclusions) = 0)
                OR (LENGTH(co.extras) = 1
                AND co.exclusions = 'null'))
        THEN
            CONCAT(pn.pizza_name,
                    ' ',
                    'extra',
                    ' ',
                    (SELECT 
                            topping_name
                        FROM
                            pizza_toppings
                        WHERE
                            topping_id = co.extras))
        WHEN
            ((LENGTH(co.extras) = 0
                AND LENGTH(co.exclusions) = 1)
                OR (LENGTH(co.exclusions) = 1
                AND co.extras = 'null'))
        THEN
            CONCAT(pn.pizza_name,
                    ' ',
                    'exclude',
                    ' ',
                    (SELECT 
                            topping_name
                        FROM
                            pizza_toppings
                        WHERE
                            topping_id = co.exclusions))
        WHEN
            ((LENGTH(co.extras) > 1
                AND LENGTH(co.exclusions) = 1))
        THEN
            CONCAT(pn.pizza_name,
                    ' ',
                    'extra',
                    ' ',
                    (WITH RECURSIVE
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
for_concat AS (SELECT
*
FROM
separate_extras
WHERE order_id = 9 AND extras <> 'null')
SELECT
GROUP_CONCAT(pt.topping_name) as toppings
FROM
for_concat fc
JOIN
pizza_toppings pt ON pt.topping_id = fc.extras),' exclude ', (WITH RECURSIVE
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
    ORDER BY order_id),
for_concat AS (SELECT
*
FROM
separate_exclusions 
WHERE order_id = 9 AND exclusions <> 'null')
SELECT
GROUP_CONCAT(pt.topping_name) as toppings
FROM
for_concat fc
JOIN
pizza_toppings pt ON pt.topping_id = fc.exclusions))
WHEN
            ((LENGTH(co.extras) > 1
                AND LENGTH(co.exclusions) > 1))
        THEN
            CONCAT(pn.pizza_name,
                    ' ',
                    'extra',
                    ' ',
                    (WITH RECURSIVE
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
for_concat AS (SELECT
*
FROM
separate_extras
WHERE order_id = 10 AND extras <> 'null')
SELECT
GROUP_CONCAT(pt.topping_name) as toppings
FROM
for_concat fc
JOIN
pizza_toppings pt ON pt.topping_id = fc.extras),' exclude ', (WITH RECURSIVE
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
    ORDER BY order_id),
for_concat AS (SELECT
*
FROM
separate_exclusions 
WHERE order_id = 10 AND exclusions <> 'null')
SELECT
GROUP_CONCAT(pt.topping_name) as toppings
FROM
for_concat fc
JOIN
pizza_toppings pt ON pt.topping_id = fc.exclusions))
        ELSE '0'
    END) AS pizza_name
FROM
    customer_orders co
        JOIN
    pizza_names pn ON co.pizza_id = pn.pizza_id;

-- Question 5+6 work in progress 