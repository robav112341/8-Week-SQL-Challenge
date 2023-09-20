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

**6. Which item was purchased first by the customer after they became a member?**

````sql
WITH min_date AS (
	SELECT 
		s.customer_id, MIN(s.order_date) AS order_date
	FROM
		sales s
	JOIN
		members m ON s.customer_id = m.customer_id
        AND s.order_date >= m.join_date
	GROUP BY s.customer_id)
SELECT
	s.*,
	m.product_name
FROM
	sales s
JOIN min_date mn ON s.customer_id = mn.customer_id AND s.order_date = mn.order_date
JOIN menu m ON s.product_id = m.product_id 
ORDER BY s.customer_id;
````

| customer_id | order_date   | product_id  | product_name|
| ----------- | ------------ | ----------  |-------------|
| A           | 2021-01-07   | 2           |  curry      |
| B           | 2021-01-11   | 1           |  sushi      |

**7. Which item was purchased just before the customer became a member?**

````sql
WITH max_date AS (
	SELECT 
		s.customer_id, 
		MAX(s.order_date) AS order_date
	FROM
		sales s
	JOIN
		members m ON s.customer_id = m.customer_id
        AND s.order_date < m.join_date
	GROUP BY s.customer_id),
rank_table AS (	
	SELECT
		s.*,
		m.product_name,
		ROW_NUMBER() OVER (PARTITION BY s.customer_id ) AS row_num,
		LEAD(s.order_date) OVER (PARTITION BY s.customer_id) AS if_null
	FROM
		sales s
	JOIN max_date md ON s.customer_id = md.customer_id AND s.order_date = md.order_date
	JOIN menu m ON s.product_id = m.product_id )
SELECT
    customer_id,
    product_id,
    product_name,
    order_date
FROM
    rank_table
WHERE if_null IS NULL;
````

| customer_id | product_id   | product_name | order_date  |
| ----------- | ------------ | -----------  |-------------|
| A           | 2            |  curry       |  2021-01-01 |
| B           | 1            |  sushi       |  2021-01-04 |

**8. What is the total items and amount spent for each member before they became a member?**

````sql
SELECT 
    s.customer_id,
    COUNT(*) AS prod_num,
    SUM(mn.price) AS sum_amount
FROM
    sales s
        JOIN
    members m ON s.customer_id = m.customer_id
        AND s.order_date < m.join_date
        JOIN
    menu mn ON s.product_id = mn.product_id
GROUP BY 1
ORDER BY 1;
````
| customer_id | prod_num     | sum_amount   | 
| ----------- | ------------ | -----------  |
| A           | 2            |  25          |  
| B           | 3            |  40          |

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

````sql
SELECT 
    s.customer_id,
    COUNT(*) AS count_orders,
    SUM(CASE
        WHEN m.product_name = 'sushi' THEN m.price * 20
        ELSE m.price*10
    END) AS points
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY 1;
````

| customer_id | count_orders | points    | 
| ----------- | ------------ | --------  |
| A           | 6            |  860      |  
| B           | 6            |  940      |
| C           | 3            |  360      |

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

````sql
SELECT 
    s.customer_id,
    COUNT(*) AS count_orders,
    SUM(CASE
        WHEN
            s.order_date >= m.join_date
                AND s.order_date < DATE_ADD(m.join_date, INTERVAL 7 DAY)
                AND mn.product_name != 'sushi'
        THEN
            mn.price * 20
        WHEN mn.product_name = 'sushi' THEN mn.price * 20
        ELSE mn.price * 10
    END) AS points
FROM
    sales s
        JOIN
    menu mn ON s.product_id = mn.product_id
        JOIN
    members m ON s.customer_id = m.customer_id
GROUP BY 1
ORDER BY 1;
````

| customer_id | count_orders | points    | 
| ----------- | ------------ | --------  |
| A           | 6            |  1370     |  
| B           | 6            |  940      |

**Bonus Questions**

Join All Things:

````sql
SELECT 
    s.customer_id,
    s.order_date,
    mn.product_name,
    mn.price,
    (SELECT 
            CASE
                    WHEN
                        s.customer_id = m.customer_id
                            AND s.order_date >= m.join_date
                    THEN
                        'Y'
                    ELSE 'N'
                END
        ) AS membership
FROM
    sales s
        LEFT JOIN
    members m ON s.customer_id = m.customer_id
        JOIN
    menu mn ON s.product_id = mn.product_id
ORDER BY 1 , 3, 2;
````

| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | ------------ | ----- | ------ |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | sushi        | 10    | N      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

