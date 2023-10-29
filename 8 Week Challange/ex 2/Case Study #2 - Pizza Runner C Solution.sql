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

-- other way:
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
    GROUP_CONCAT(t.topping_name SEPARATOR ', ') as recipie
FROM 
    pizza_names p
JOIN 
    pizza_help h ON p.pizza_id = h.pizza_id
JOIN 
    pizza_toppings t ON h.topping_id = t.topping_id
GROUP BY 
    p.pizza_name;
    
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

-- Question 5+6 work in progress 
