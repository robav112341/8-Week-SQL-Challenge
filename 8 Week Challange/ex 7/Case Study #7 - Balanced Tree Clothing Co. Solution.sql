-- Case Study #7 - Balanced Tree Clothing Co. solution, part VII of SQL 8 week challange by Robert Avdalimov:

-- High Level Sales Analysis:
-- Question 1:
-- What was the total quantity sold for all products?
SELECT 
    pd.product_name, SUM(s.qty) AS total_qty
FROM
    sales s
        JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 1;

-- Question 2:
-- What is the total generated revenue for all products before discounts?
SELECT 
    pd.product_name,SUM(s.qty * s.price) AS total_revenue
FROM
    sales s
        JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 1;
    
-- Question 3:
-- What was the total discount amount for all products?
SELECT 
    pd.product_name,ROUND(SUM(s.qty * s.price * (s.discount / 100)), 1) AS total_discount
FROM
    sales s
     JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 1;
    
-- Transaction Analysis
-- Question 1:
-- How many unique transactions were there?
SELECT 
   COUNT(DISTINCT txn_id) as total_txn
FROM
    sales;

-- Question 2:
-- What is the average unique products purchased in each transaction?
WITH unique_count AS 
(	SELECT 
		txn_id, COUNT(DISTINCT prod_id) AS unique_count
	FROM
		sales
	GROUP BY 1)
SELECT 
	ROUND(AVG(unique_count),1) AS avg_product_per_txn
FROM
	unique_count;

-- Question 3:
-- What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH txn_revenue AS
(	SELECT 
		ROW_NUMBER() OVER(ORDER BY txn_id) AS txn_num
		,txn_id, SUM(price * qty) AS revenue,
		ROUND(percent_rank() OVER (ORDER BY SUM(price * qty)),2) p
	FROM
		sales
	GROUP BY 2)
SELECT
	ROUND(AVG(revenue)) as revenue,
	p
FROM txn_revenue
WHERE p = 0.25 OR p= 0.5 OR p = 0.75 or p = 1
GROUP BY 2;

-- Question 4:
-- What is the average discount value per transaction?
WITH txn_discount AS(
	SELECT 
		txn_id,
		ROUND(SUM(qty * price * (discount / 100)), 1) AS discount
	FROM
		sales
	GROUP BY 1)
SELECT
	ROUND(AVG(discount),1) avg_discount_per_txn
FROM
	txn_discount;

-- Question 5:
-- What is the percentage split of all transactions for members vs non-members?
WITH unique_txn AS(
	SELECT 
		*
	FROM
		sales
	GROUP BY txn_id),
count_members AS (
	SELECT
	member,
		COUNT(*) as count_m,
		ROUND(COUNT(*)/(SELECT COUNT(*) FROM unique_txn)*100,1) as p
	FROM
		unique_txn 
	GROUP BY 1)
SELECT
	*
FROM
	count_members;

-- Question 6:
-- What is the average revenue for member transactions and non-member transactions?
WITH unique_txn AS(
	SELECT 
		member,
		SUM(qty*price) as revenue
	FROM
		sales
	GROUP BY txn_id),
count_members AS (
	SELECT
		member,
		ROUND(AVG(revenue),1) as avg_txn
	FROM
		unique_txn 
	GROUP BY 1)
SELECT
	*
FROM
	count_members;

-- Product Analysis
-- Question 1:
-- What are the top 3 products by total revenue before discount?
SELECT 
    pd.product_name, SUM(s.qty * s.price) AS total_revenue
FROM
    sales s
        JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- Question 2:
-- What is the total quantity, revenue and discount for each segment?
SELECT 
    pd.segment_name,
    SUM(s.qty) AS qty,
    SUM(s.price * s.qty) AS revenue,
    ROUND(SUM(s.price * s.qty * (s.discount / 100)),
            1) AS total_discount
FROM
    sales s
JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 1
ORDER BY 1;

-- Question 3:
-- What is the top selling product for each segment?
WITH rank_product AS(
	SELECT 
		pd.product_name,
		SUM(s.qty) AS qty,
		SUM(s.price * s.qty) AS revenue,
		ROUND(SUM(s.price * s.qty * (s.discount / 100)),
				1) AS total_discount,
		pd.segment_name,
		rank() OVER(PARTITION BY pd.segment_name ORDER BY SUM(s.price * s.qty) DESC) AS ranks
	FROM
		sales s
	JOIN
		product_details pd ON s.prod_id = pd.product_id
	GROUP BY 1
	ORDER BY 5)
SELECT
	*
FROM
	rank_product
WHERE ranks = 1;

-- Question 4:
-- What is the total quantity, revenue and discount for each category?
SELECT 
    pd.category_name,
    SUM(s.qty) AS qty,
    SUM(s.price * s.qty) AS revenue,
    ROUND(SUM(s.price * s.qty * (s.discount / 100)),
            1) AS total_discount
FROM
    sales s
        JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 1
ORDER BY 1;

-- Question 5:
-- What is the top selling product for each category?
WITH ranked_product AS (
	SELECT 
		pd.product_name,
		SUM(s.qty) AS qty,
		SUM(s.price * s.qty) AS revenue,
		ROUND(SUM(s.price * s.qty * (s.discount / 100)),
				1) AS total_discount,
		pd.category_name,
		rank() OVER(PARTITION BY pd.category_name ORDER BY SUM(s.price * s.qty) DESC) AS ranks
	FROM
		sales s
	JOIN
		product_details pd ON s.prod_id = pd.product_id
	GROUP BY 1
	ORDER BY 5)
SELECT
	product_name,qty,revenue,total_discount,category_name
FROM
	ranked_product
WHERE ranks = 1;

-- Question 6:
-- What is the percentage split of revenue by product for each segment?
SELECT 
    pd.segment_name,
    pd.product_name,
    SUM(s.qty * s.price) AS revenue,
    ROUND(SUM(s.qty * s.price) / (SELECT 
                    SUM(x.qty * x.price)
                FROM
                    sales x
                        JOIN
                    product_details px ON x.prod_id = px.product_id
                WHERE
                    px.segment_id = pd.segment_id),
            2) AS precentage
FROM
    sales s
        JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 2
ORDER BY 1;

-- Question 7:
-- What is the percentage split of revenue by segment for each category?
SELECT 
    pd.category_name,
    pd.segment_name,
    SUM(s.qty * s.price) AS revenue,
    ROUND(SUM(s.qty * s.price) / (SELECT 
                    SUM(x.qty * x.price)
                FROM
                    sales x
                        JOIN
                    product_details y ON x.prod_id = y.product_id
                WHERE
                    y.category_name = pd.category_name),
            2) AS precentage
FROM
    sales s
        JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 2
ORDER BY 1;

-- Question 8:
-- What is the percentage split of revenue by product for each segment?
SELECT 
    pd.category_name,
    SUM(s.qty * s.price) AS revenue,
    ROUND(SUM(s.qty * s.price) / (SELECT 
                    SUM(qty * price)
                FROM
                    sales),
            2) AS precentage
FROM
    sales s
        JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 1;

-- Question 9:
-- What is the total transaction “penetration” for each product?
WITH ranked_sales  AS(
	SELECT 
		*,
		RANK() OVER(PARTITION BY prod_id ORDER BY qty) AS ranks
	FROM
		sales),
prod_count AS (
	SELECT 
		*,
		COUNT(*) as count_p
	FROM
		ranked_sales 
	WHERE
		ranks >= 1
	GROUP BY prod_id)
SELECT
	pd.product_name,
	ROUND(pc.count_p/(SELECT COUNT(DISTINCT txn_id) FROM sales)*100,2) AS p
FROM	
	prod_count pc
JOIN
	product_details pd ON pc.prod_id = pd.product_id
ORDER BY 2 DESC;

-- Question 10:
-- Sorry, I do not fully understand the output required.

-- Bonus Challange:
-- Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.
WITH part_one AS(
	SELECT 
		pp.product_id,
		pp.price,
		ph.id AS style_id,
		(SELECT 
            id
        FROM
            product_hierarchy
        WHERE
            id = ph.parent_id) AS segment_id,
		(SELECT 
            level_text
        FROM
            product_hierarchy
        WHERE
            id = ph.parent_id) AS segment_name,
		ph.level_text AS style_name
	FROM
		product_prices pp
	JOIN
		product_hierarchy ph ON pp.id = ph.id),
part_two AS(
	SELECT
		product_id,
		price,
        (SELECT parent_id FROM product_hierarchy WHERE level_text = segment_name) as category_id,
        style_id,
        segment_id,
        segment_name,
        (SELECT level_text FROM product_hierarchy WHERE id = (SELECT parent_id FROM product_hierarchy WHERE level_text = segment_name)) as category_name,
        style_name
	FROM
		part_one)
	SELECT
    product_id,
    price,
    CONCAT(style_name,' ',segment_name,' - ',category_name) AS product_name,
    category_id,
    segment_id,
	style_id,
    category_name,
    segment_name,
    style_name
FROM 
    part_two;
