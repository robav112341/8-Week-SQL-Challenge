# Case Study #4: Data Bank

<img src="https://user-images.githubusercontent.com/81607668/130343294-a8dcceb7-b6c3-4006-8ad2-fab2f6905258.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#case-study-questions)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-4/). 

***

## Business Task
Danny launched a new initiative, Data Bank which runs **banking activities** and also acts as the world’s most secure distributed **data storage platform**!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. 

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

## Entity Relationship Diagram

<img width="631" alt="image" src="https://user-images.githubusercontent.com/81607668/130343339-8c9ff915-c88c-4942-9175-9999da78542c.png">

**Table 1: `regions`**

This regions table contains the `region_id` and their respective `region_name` values.

<img width="176" alt="image" src="https://user-images.githubusercontent.com/81607668/130551759-28cb434f-5cae-4832-a35f-0e2ce14c8811.png">

**Table 2: `customer_nodes`**

Customers are randomly distributed across the nodes according to their region. This random distribution changes frequently to reduce the risk of hackers getting into Data Bank’s system and stealing customer’s money and data!

<img width="412" alt="image" src="https://user-images.githubusercontent.com/81607668/130551806-90a22446-4133-45b5-927c-b5dd918f1fa5.png">

**Table 3: Customer Transactions**

This table stores all customer deposits, withdrawals and purchases made using their Data Bank debit card.

<img width="343" alt="image" src="https://user-images.githubusercontent.com/81607668/130551879-2d6dfc1f-bb74-4ef0-aed6-42c831281760.png">

***

## Case Study Questions

### 🏦 A. Customer Nodes Exploration

**1. How many unique nodes are there on the Data Bank system?**

```sql
SELECT 
    COUNT(DISTINCT node_id) count_nodes
FROM
    customer_nodes;
```

| count_nodes |
|-------------|
|      5      |

**2.  What is the number of nodes per region?**

```sql
SELECT 
    r.region_name, COUNT(DISTINCT node_id) AS node_count
FROM
    customer_nodes cn
        JOIN
    regions r ON cn.region_id = r.region_id
GROUP BY 1
ORDER BY 1;
```

| region_name | node_count |
|-------------|------------|
| Africa      | 5          |
| America     | 5          |
| Asia        | 5          |
| Australia   | 5          |
| Europe      | 5          |

**3. How many customers are allocated to each region?**

non-unique customers:

```sql
SELECT 
    r.region_name, COUNT(customer_id) AS customer_count
FROM
    customer_nodes cn
        JOIN
    regions r ON cn.region_id = r.region_id
GROUP BY 1
ORDER BY 1;
```

| region_name | customer_count |
|-------------|----------------|
| Africa      | 714            |
| America     | 735            |
| Asia        | 665            |
| Australia   | 770            |
| Europe      | 616            |

unique customers:

```sql
SELECT 
    r.region_name, COUNT(DISTINCT customer_id) AS customer_count
FROM
    customer_nodes cn
        JOIN
    regions r ON cn.region_id = r.region_id
GROUP BY 1
ORDER BY 1;
```

| region_name | customer_count |
|-------------|----------------|
| Africa      | 102            |
| America     | 105            |
| Asia        | 95             |
| Australia   | 110            |
| Europe      | 88             |

**4. How many days on average are customers reallocated to a different node?**

```sql
SELECT 
    ROUND(AVG(DATEDIFF(end_date, start_date)), 2) AS avg_node_time
FROM
    customer_nodes
WHERE
    end_date != '9999-12-31';
```

| avg_node_time |
|-------------- |
|     14.63     |

**5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**

```sql
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
```
<details><summary> Click to expand :arrow_down: </summary>
    
| region_name | avg_node_time| percentile |
|-------------|--------------|------------|
| Africa      | 14.83        | 0.5        |
| Africa      | 23.99        | 0.8        |
| Africa      | 26.79        | 0.9        |
| America     | 15.05        | 0.5        |
| America     | 23.55        | 0.8        |
| America     | 26.97        | 0.9        |
| Asia        | 15.15        | 0.5        |
| Asia        | 23.02        | 0.8        |
| Asia        | 26.42        | 0.9        |
| Australia   | 14.89        | 0.5        |
| Australia   | 24.00        | 0.8        |
| Australia   | 27.06        | 0.9        |
| Europe      | 15.48        | 0.5        |
| Europe      | 25.02        | 0.8        |
| Europe      | 27.50        | 0.9        |

</details>

**1. What is the unique count and total amount for each transaction type?**

```sql
SELECT 
    txn_type,
    COUNT(*) AS count_customers,
    SUM(txn_amount) AS total_amount
FROM
    customer_transactions
GROUP BY 1
ORDER BY 1;
```

| txn_type   | count_customers | total_amount |
|------------|----------------|---------------|
| deposit    | 2671           | 1359168       |
| purchase   | 1617           | 806537        |
| withdrawal | 1580           | 793003        |

**2. What is the unique count and total amount for each transaction type?**

```sql
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
```

| avg_count | avg_amount |
|-----------|------------|
| 5.3       | 508.6      |

**3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

```sql
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
```

| month_ | customer_count |
|--------|----------------|
| 1      | 168            |
| 2      | 181            |
| 3      | 192            |
| 4      | 70             |

**4. What is the closing balance for each customer at the end of the month? Also show the change in balance each month in the same table output.**

```sql
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
```
the answer is 1720 rows long, therefore i posting only the first 20:

<details><summary> Click to expand :arrow_down: </summary>
    
| customer_id | _month | monthly_change | balance |
|-------------|--------|----------------|---------|
| 1           | 1      | 312            | 312     |
| 1           | 3      | -952           | -640    |
| 2           | 1      | 549            | 549     |
| 2           | 3      | 61             | 610     |
| 3           | 1      | 144            | 144     |
| 3           | 2      | -965           | -821    |
| 3           | 3      | -401           | -1222   |
| 3           | 4      | 493            | -729    |
| 4           | 1      | 848            | 848     |
| 4           | 3      | -193           | 655     |
| 5           | 1      | 954            | 954     |
| 5           | 3      | -2877          | -1923   |
| 5           | 4      | -490           | -2413   |
| 6           | 1      | 733            | 733     |
| 6           | 2      | -785           | -52     |
| 6           | 3      | 392            | 340     |
| 7           | 1      | 964            | 964     |
| 7           | 2      | 2209           | 3173    |
| 7           | 3      | -640           | 2533    |
| 7           | 4      | 90             | 2623    |
| 8           | 1      | 587            | 587     |

</details>

**5. What is the percentage of customers who increase their closing balance by more than 5%?**

```sql
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
 ```

| balance_grow_by_5P_or_more  | out_of_total |
|-----------------------------|--------------|
| 151                         | 30.20        |
