-- Case Study #8 - Fresh Segments solution, part IV of SQL 8 week challange by Robert Avdalimov:

-- A. Customer Nodes Exploration
-- 1.How many unique nodes are there on the Data Bank system?
SELECT 
    COUNT(DISTINCT node_id) count_nodes
FROM
    customer_nodes;
    
-- Question 2
-- What is the number of nodes per region?
SELECT 
    r.region_name, COUNT(DISTINCT node_id) AS node_count
FROM
    customer_nodes cn
        JOIN
    regions r ON cn.region_id = r.region_id
GROUP BY 1
ORDER BY 1;

-- Question 3:
-- How many customers are allocated to each region?
-- Non-unique customers:
SELECT 
    r.region_name, COUNT(customer_id) AS customer_count
FROM
    customer_nodes cn
        JOIN
    regions r ON cn.region_id = r.region_id
GROUP BY 1
ORDER BY 1;

-- Unique customers:
SELECT 
    r.region_name, COUNT(DISTINCT customer_id) AS customer_count
FROM
    customer_nodes cn
        JOIN
    regions r ON cn.region_id = r.region_id
GROUP BY 1
ORDER BY 1;

-- Question 4:
-- How many days on average are customers reallocated to a different node?
SELECT 
    ROUND(AVG(DATEDIFF(end_date, start_date)), 2) AS avg_node_time
FROM
    customer_nodes
WHERE
    end_date != '9999-12-31';
    
-- Question 5:
-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH percentile_cte AS (
	SELECT 
		*, 	
		DATEDIFF(end_date, start_date) AS avg_time,
		ROUND(PERCENT_RANK() OVER (PARTITION BY region_id ORDER BY DATEDIFF(end_date, start_date)),1) AS percentile

	FROM
		customer_nodes
	WHERE
		end_date != '9999-12-31')
SELECT 
	r.region_name,
	ROUND(AVG(pc.avg_time),2) AS avg_node_time,
	pc.percentile
FROM
	percentile_cte pc
JOIN
	regions r ON pc.region_id = r.region_id
WHERE pc.percentile = 0.5 OR pc.percentile = 0.8 OR pc.percentile = 0.9
GROUP BY 1, 3
ORDER BY 1, 3;

-- Customer Transactions
-- Question 1:
-- What is the unique count and total amount for each transaction type?
SELECT 
    txn_type,
    COUNT(*) AS count_customers,
    SUM(txn_amount) AS total_amount
FROM
    customer_transactions
GROUP BY 1
ORDER BY 1;

-- Question 2:
-- What is the average total historical deposit counts and amounts for all customers?
WITH count_cte AS(
	SELECT 
		customer_id,
        COUNT(*) AS time_count,
        AVG(txn_amount) AS avg_amount
	FROM
		customer_transactions
	WHERE
		txn_type = 'deposit'
	GROUP BY 1)
SELECT
	ROUND(AVG(time_count),1) as avg_count,
	ROUND(AVG(avg_amount),1) as avg_amount
FROM
	count_cte;
    
-- Question 3:
-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH type_count AS(
	SELECT
		customer_id,
        MONTH(txn_date) AS month_,
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_c,
		SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_c,
        SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_C
	FROM
        customer_transactions 
	GROUP BY 1,2
    ORDER BY 1)
SELECT
  month_,
  COUNT(customer_id) AS customer_count
FROM type_count
WHERE deposit_c > 1 
  AND (purchase_c >= 1 OR withdrawal_c >= 1)
GROUP BY 1
ORDER BY 1;

-- Question 4:
-- What is the closing balance for each customer at the end of the month? Also show the change in balance each month in the same table output.
WITH month_sum AS(
	SELECT 
		customer_id,
		MONTH(txn_date) AS _month,
		SUM(CASE
			WHEN txn_type = 'deposit' THEN txn_amount
			ELSE - txn_amount
			END) AS monthly_change
	FROM
		customer_transactions
	GROUP BY 1 , 2
	ORDER BY 1 , 2)
SELECT 
*,
sum(monthly_change) OVER(PARTITION BY customer_id
                                     ORDER BY _month ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS balance
FROM month_sum;

-- Question 5:
-- What is the percentage of customers who increase their closing balance by more than 5%?
WITH month_sum AS(
	SELECT 
		customer_id,
		MONTH(txn_date) AS _month,
		SUM(CASE
			WHEN txn_type = 'deposit' THEN txn_amount
			ELSE - txn_amount
			END) AS monthly_change
	FROM
		customer_transactions
	GROUP BY 1 , 2
	ORDER BY 1 , 2),
balance AS (
	SELECT 
		*,
		sum(monthly_change) OVER(PARTITION BY customer_id
                                     ORDER BY _month ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS balance
	FROM month_sum),
first_row AS (	
    SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY _month) AS first_row
    FROM
		balance),
last_row AS (	
    SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY _month DESC) AS last_row
    FROM
		balance),
first_txn AS(
	SELECT 
		*
	FROM
		first_row
	WHERE 
		first_row = 1),
last_txn AS(
	SELECT 
		*
	FROM
		last_row
	WHERE 
		last_row = 1)
SELECT 
	COUNT(*) AS blanace_grow_by_5P_or_more,
    ROUND(COUNT(*)/(SELECT COUNT(DISTINCT customer_id) FROM customer_transactions) * 100,2) AS out_of_total
FROM
	first_txn ft
JOIN
	last_txn lt ON ft.customer_id = lt.customer_id
WHERE (lt.balance > 0 AND  ft.balance > 0 AND lt.balance AND lt.balance/ft.balance -1 > 0.05)
	OR (lt.balance > 0 AND  ft.balance < 0)