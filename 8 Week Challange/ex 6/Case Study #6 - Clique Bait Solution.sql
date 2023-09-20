-- Clique Bait solution, part VI of SQL 8 week challange by Robert Avdalimov:

USE clique_bait;
-- 2.Digital Analysis
-- Question 1:
-- How many users are there?
SELECT 
    COUNT(DISTINCT user_id) AS users_count
FROM
    USERS
;

-- Question 2:
-- How many cookies does each user have on average?
SELECT 
    COUNT(*) / COUNT(DISTINCT user_id) AS avg_per_user
FROM
    USERS
;

-- Question 3:
-- What is the unique number of visits by all users per month?
SELECT 
    MONTHNAME(event_time) AS month_name,
    COUNT(DISTINCT visit_id) AS visits_count
FROM
    EVENTS
GROUP BY 1
ORDER BY event_time;

-- Question 4:
--  What is the number of events for each event type?
SELECT 
    ei.event_name, COUNT(*) AS count_events
FROM
    events e
        JOIN
    event_identifier ei ON e.event_type = ei.event_type
GROUP BY e.event_type;

-- Question 5:
--  What is the percentage of visits which have a purchase event?
SELECT 
    e.event_type,
    ei.event_name,
    COUNT(DISTINCT visit_id) AS count_type3,
    ROUND(COUNT(*) / (SELECT 
                    COUNT(DISTINCT visit_id)
                FROM
                    events) * 100,
            1) AS precentage
FROM
    events e
        JOIN
    event_identifier ei ON e.event_type = ei.event_type
WHERE
    e.event_type = 3
GROUP BY 1;

-- Question 6:
-- What is the percentage of visits which view the checkout page but do not have a purchase event?
SELECT 
    COUNT(DISTINCT visit_id) AS count_,
    ROUND(COUNT(DISTINCT visit_id) / (SELECT 
                    COUNT(DISTINCT visit_id)
                FROM
                    events) * 100,
            1) AS precentage
FROM
    events e
        JOIN
    event_identifier ei ON e.event_type = ei.event_type
        JOIN
    page_hierarchy ph ON e.page_id = ph.page_id
WHERE
    e.event_type <> 3 AND ph.page_id = 12
        AND visit_id NOT IN (SELECT DISTINCT
            visit_id
        FROM
            events
        WHERE
            event_type = 3);
            
-- Question 7:
-- What are the top 3 pages by number of views?
SELECT 
    ph.page_name, COUNT(*) AS count_views
FROM
    events e
        JOIN
    page_hierarchy ph ON e.page_id = ph.page_id
WHERE
    e.event_type = 1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- Question 8:
-- What is the number of views and cart adds for each product category?
WITH count_views AS (
	SELECT 
		page_id, COUNT(*) AS count_views
	FROM
		EVENTS
	WHERE
		page_id BETWEEN 3 AND 12
			AND event_type = 1
	GROUP BY page_id),
count_add_cart AS ( 
	SELECT 
		page_id, COUNT(*) AS count_add_cart
	FROM
		EVENTS
	WHERE
		page_id BETWEEN 3 AND 12
			AND event_type = 2
	GROUP BY 1),
final_table AS (
	SELECT
		cv.page_id, cv.count_views,cc.count_add_cart
	FROM
		count_views cv 
	JOIN
		count_add_cart cc 
	ON cv.page_id = cc.page_id
	ORDER BY 1)
SELECT
	ph.product_category, SUM(ft.count_views) AS views, SUM(ft.count_add_cart) AS add_cart
FROM
	final_table ft
JOIN
	page_hierarchy ph ON ft.page_id = ph.page_id
GROUP BY 1;

-- Question 9:
-- What are the top 3 products by purchases?
WITH rank_events  AS (
	SELECT
		*
	FROM
		events
	WHERE event_type BETWEEN 2 AND 3)
SELECT
	ph.page_name,
	count(*)
FROM
	rank_events re
JOIN
	page_hierarchy ph ON re.page_id = ph.page_id
WHERE event_type = 2
AND visit_id IN (SELECT visit_id FROM rank_events where event_type = 3)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- 3.Product Funnel Analysis
-- Question 1:
-- Which product had the most views, cart adds and purchases?
WITH count_views AS(
	SELECT 
		page_id, COUNT(*) AS count_views
	FROM
		events
	WHERE
		event_type = 1
	GROUP BY 1),
count_add_cart as(
	SELECT 
		page_id, COUNT(*) AS count_cart
	FROM
		events
	WHERE
		event_type = 2
	GROUP BY 1),
count_purchase as(
	WITH rank_events  AS (
		SELECT
			*
		FROM
			events
		WHERE event_type BETWEEN 2 AND 3)
	SELECT
		page_id,
		count(*) count_purchase
	FROM
		rank_events 
	WHERE event_type = 2
	AND visit_id IN (SELECT visit_id FROM rank_events where event_type = 3)
	GROUP BY 1
	ORDER BY 2 DESC)
SELECT
	ph.page_name, cv.count_views, cc.count_cart, cp.count_purchase
FROM
	count_views cv
JOIN 
	count_add_cart cc ON cv.page_id = cc.page_id
JOIN
	count_purchase cp ON cv.page_id = cp.page_id
JOIN
	page_hierarchy ph ON cv.page_id = ph.page_id
WHERE 
	cv.count_views = (SELECT MAX(count_views) from count_views WHERE page_id BETWEEN 3 and 11)
	OR cc.count_cart IN (SELECT MAX(count_cart) FROM count_add_cart)
	OR cp.count_purchase IN (SELECT MAX(count_purchase) FROM count_purchase);

-- Question 2:
-- Which product was most likely to be abandoned?
SELECT 
    ph.page_name, COUNT(*)
FROM
    events e
        JOIN
    page_hierarchy ph ON e.page_id = ph.page_id
WHERE
    e.event_type = 2
        AND e.visit_id NOT IN (SELECT DISTINCT
            visit_id
        FROM
            events
        WHERE
            event_type = 3)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Question 3:
-- Which product had the highest view to purchase percentage?
WITH count_views AS(
	SELECT 
		page_id, COUNT(*) AS count_views
	FROM
		events
	WHERE
    event_type = 1
	GROUP BY 1),
count_add_cart as(
	SELECT 
		page_id, COUNT(*) AS count_cart
	FROM
		events
	WHERE
		event_type = 2
	GROUP BY 1),
count_purchase as(
	WITH rank_events  AS (
	SELECT
		*
	FROM
		events
	WHERE event_type BETWEEN 2 AND 3)
	SELECT
		page_id,
		count(*) count_purchase
	FROM
		rank_events 
	WHERE event_type = 2
	AND visit_id IN (SELECT visit_id FROM rank_events where event_type = 3)
	GROUP BY 1
	ORDER BY 2 DESC)
SELECT
	ph.page_name, ROUND((cp.count_purchase/cv.count_views*100),1 ) AS view_to_purchase
FROM
	count_views cv
JOIN 
	count_add_cart cc ON cv.page_id = cc.page_id
JOIN
	count_purchase cp ON cv.page_id = cp.page_id
JOIN
	page_hierarchy ph ON cv.page_id = ph.page_id
ORDER BY 2 DESC
LIMIT 1;

-- Question 4:
-- What is the average conversion rate from view to cart add?
WITH cte_views AS (
	SELECT 
		page_id, COUNT(*) AS count_views
	FROM
		events
	WHERE
		event_type = 1
	GROUP BY 1),
cte_addcart AS (
	SELECT
		page_id,COUNT(*) AS count_add
	FROM
		events
	WHERE
		event_type = 2
	GROUP BY 1)
SELECT
	ROUND(AVG(ca.count_add/cv.count_views)*100,2) AS avg_view_to_cart
FROM
	cte_views cv 
JOIN
	cte_addcart ca
ON
	cv.page_id = ca.page_id;

-- Question 5:
-- What is the average conversion rate from cart add to purchase?
WITH cte_views AS (
	SELECT 
		page_id, COUNT(*) AS count_views
	FROM
		events
	WHERE
		event_type = 2
	GROUP BY 1),
cte_addcart AS (
	SELECT
		page_id,COUNT(*) AS count_add
	FROM
		events
	WHERE
		event_type = 2
	AND visit_id IN (SELECT visit_id FROM events WHERE event_type = 3)
	GROUP BY 1)
SELECT
	ROUND(AVG(ca.count_add/cv.count_views)*100,1) AS avg_view_to_cart
FROM
	cte_views cv 
JOIN
	cte_addcart ca
ON
	cv.page_id = ca.page_id;

