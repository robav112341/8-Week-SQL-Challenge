# Case Study #1 - Danny's Diner 
## Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

## Case Study Questions

**1. What is the total amount each customer spent at the restaurant?**

````sql
SELECT 
    s.customer_id, SUM(m.price) AS total_spend
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
````

| customer_id | total_spend |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

**2. How many days has each customer visited the restaurant?**

````sql
SELECT 
    customer_id, COUNT(DISTINCT order_date) AS num_of_days
FROM
    sales
GROUP BY customer_id
ORDER BY 1;
````
| customer_id | num_of_days |
| ----------- | ----------- |
| A           | 4           |
| B           | 5           |
| C           | 6           |

**3. What was the first item from the menu purchased by each customer?**

````sql
SELECT 
    s.customer_id,
    MIN(s.order_date) AS first_purch,
    m.product_name
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY customer_id;
````

| customer_id | first_purch | product_name|
| ----------- | ------------| ----------  |
| A           | 2021-01-01  | sushi       |
| B           | 2021-01-01  | curry       |
| C           | 2021-01-01  | ramen       |

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql
WITH cte AS (
	SELECT
		product_id,
		COUNT(*) AS total
	FROM
		sales
    GROUP BY product_id) 
SELECT
	m.product_name,
	c.product_id,
	c.total
FROM
	cte c
JOIN 
	menu m
ON c.product_id = m.product_id
WHERE total = (SELECT MAX(total) FROM cte);
````

| product_name | product_id | total |
| -----------  | -----------| ----  |
| A            |     3      |   8   |

**5. Which item was the most popular for each customer?**

````sql
WITH cte AS (
	SELECT 
		customer_id,
		product_id,
		ROW_NUMBER() OVER (PARTITION BY customer_id, product_id) AS times
FROM
		sales),
count_table AS (
	SELECT 
		customer_id,
		product_id,
		MAX(times) as purch_times,
		RANK() OVER (PARTITION BY customer_id ORDER BY MAX(times) DESC) AS ranks
	FROM
		cte
	GROUP BY customer_id, product_id)
SELECT
	ct.customer_id,
	m.product_name,
	ct.purch_times
FROM
	count_table ct
JOIN menu m 
	ON ct.product_id = m.product_id
WHERE ct.ranks = 1;
````

| customer_id | product_name | purch_times |
| ----------- | ------------ | ----------  |
| A           | ramen        | 3           |
| B           | sushi        | 2           |
| B           | curry        | 2           |
| B           | ramen        | 2           |
| C           | ramen        | 3           |
