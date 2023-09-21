# 🌲 Case Study #7: Balanced Tree
<img src="https://github.com/katiehuangx/8-Week-SQL-Challenge/assets/81607668/8ada3c0c-e90a-47a7-9a5c-8ffd6ee3eef8" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#problem-statement)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#case-Study-questions)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-7/). 

***
## Entity Relationship Diagram

<img width="932" alt="image" src="https://github.com/katiehuangx/8-Week-SQL-Challenge/assets/81607668/2ce4df84-2b05-4fe9-a50c-47c903b392d5">

***
## Problem Statement

Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

## Case Study Questions

### 📈 A. High Level Sales Analysis

**1. What was the total quantity sold for all products?**

```sql
SELECT 
    pd.product_name, SUM(s.qty) AS total_qty
FROM
    sales s
        JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 1;
```

| product_name                     | total_qty |
| ------------------------------   | --------- |
|White Striped Socks - Mens        |  3655     |
|Pink Fluro Polkadot Socks - Mens  |  3770     |
|Cream Relaxed Jeans - Womens	   |  3707     |
|Indigo Rain Jacket - Womens       |  3757     |
|Blue Polo Shirt - Mens            |  3819     |
|Navy Solid Socks - Mens	       |  3792     |
|Black Straight Jeans - Womens     |  3786     |
|Khaki Suit Jacket - Womens	       |  3752     |
|Grey Fashion Jacket - Womens	   |  3876     |
|Teal Button Up Shirt - Mens	   |  3646     |

**2. What is the total generated revenue for all products before discounts?**

```sql
SELECT 
    pd.product_name,SUM(s.qty * s.price) AS total_revenue
FROM
    sales s
        JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 1;
```
|         product_name           | total_revenue |
| ------------------------------ | ------------- |
|Navy Oversized Jeans - Womens   |	    50128    |
|White Tee Shirt - Mens          |	    152000   |
|White Striped Socks - Mens      |	    62135    |
|Pink Fluro Polkadot Socks - Mens|	    109330   |
|Cream Relaxed Jeans - Womens    |	    37070    |
|Indigo Rain Jacket - Womens     |	    71383    |
|Blue Polo Shirt - Mens          |	    217683   |
|Navy Solid Socks - Mens         |	    136512   |
|Black Straight Jeans - Womens   |	    121152   |
|Khaki Suit Jacket - Womens      |	    86296    |
|Grey Fashion Jacket - Womens    |	    209304   |
|Teal Button Up Shirt - Mens     |  	36460    |

**3. What was the total discount amount for all products?**

```sql
SELECT 
    pd.product_name,ROUND(SUM(s.qty * s.price * (s.discount / 100)), 1) AS total_discount
FROM
    sales s
     JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 1;
```


|         product_name           |total_discount |
| ------------------------------ | ------------- |
|Navy Oversized Jeans - Womens   |	   6135.6    |
|White Tee Shirt - Mens          |	   18377.6   |
|White Striped Socks - Mens      |	   7410.8    |
|Pink Fluro Polkadot Socks - Mens|	   12952.3   |
|Cream Relaxed Jeans - Womens    |	   4463.4    |
|Indigo Rain Jacket - Womens     |	   8642.5    |
|Blue Polo Shirt - Mens          |	   26819.1   |
|Navy Solid Socks - Mens         |	   16650.4   |
|Black Straight Jeans - Womens   |	   14745.0   |
|Khaki Suit Jacket - Womens      |	   10243.1   |
|Grey Fashion Jacket - Womens    |	   25391.9   |
|Teal Button Up Shirt - Mens     |     4397.6    |

### 🧾 B. Transaction Analysis

**1. How many unique transactions were there?**

```sql
SELECT 
   COUNT(DISTINCT txn_id) as total_txn
FROM
    sales;
```

| total_txn |
| --------- |
|   2500    |

**2. What is the average unique products purchased in each transaction?**

```sql
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
```

| avg_product_per_txn |
| ------------------- |
|         6.0         |


**3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?**

```sql
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
```

| revenue |   p   |
| ------- | ----- |
|   377   | 0.25  |
|   510   | 0.5   |
|   647	  | 0.75  |
|   1134  | 1     |

**4. What is the average discount value per transaction?**

```sql
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
```

| avg_discount_per_txn |
| -------------------- |
|       62.5           |


**5. What is the percentage split of all transactions for members vs non-members?**

```sql
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
```

| member | count_m | p  |
| ------ | ------- | -- |
|t       |1505     |60.2|
|f       |995      |39.8|

**6. What is the average revenue for member transactions and non-member transactions?**

```sql
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
```

| member | avg_txn |
| ------ | ------- |
|t       |516.3    |
|f       |515.0    |

### 👚 C. Product Analysis

**1. What are the top 3 products by total revenue before discount?**

```sql
SELECT 
    pd.product_name, SUM(s.qty * s.price) AS total_revenue
FROM
    sales s
        JOIN
    product_details pd ON s.prod_id = pd.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;
```

| product_name                 | total_revenue |
| ---------------------------- | ------------- |
| Blue Polo Shirt - Mens       | 217683        |
| Grey Fashion Jacket - Womens | 209304        |
| White Tee Shirt - Mens       | 152000        |

**2. What is the total quantity, revenue and discount for each segment?**

```sql
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
```

| segment_name | qty            |    revenue    | total_discount |
| ------------ | -------------- | ------------- | -------------- |
| Jacket       | 11385          | 366983        | 44277.5        |
| Jeans        | 11349          | 208350        | 25344.0        |
| Shirt        | 11265          | 406143        | 49594.3        |
| Socks        | 11217          | 307977        | 37013.4        |

**3. What is the top selling product for each segment?**

```sql
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
	product_name,qty,revenue,total_discount,segment_name
FROM
	rank_product
WHERE ranks = 1;
```

|product_name	                |qty	|revenue|total_discount|segment_name|
| ----------------------------- | ----- | ----- | ------------ | ---------- |
|Grey Fashion Jacket - Womens	|3876	|209304	|25391.9       |Jacket      |
|Black Straight Jeans - Womens	|3786	|121152	|14745.0       |Jeans       |
|Blue Polo Shirt - Mens	        |3819	|217683	|26819.1       |Shirt       |       
|Navy Solid Socks - Mens	|3792	|136512	|16650.4       |Socks       |

**4. What is the total quantity, revenue and discount for each category?**

```sql
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
```

| category_name |   qty          |    revenue    | total_discount |
| ------------- | -------------- | ------------- | -------------- |
| Mens          | 22482          | 714120        | 86607.71       |
| Womens        | 22734          | 575333        | 69621.43       |

**5. What is the top selling product for each category?**

```sql
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
```

|product_name	                |qty	|revenue	|total_discount	|category_name|
| ----------------------------- | ----- | ------------- | ------------- | ----------- |
|Blue Polo Shirt - Mens	        |3819	|217683	        |26819.1	|Mens         |
|Grey Fashion Jacket - Womens	|3876	|209304	        |25391.9	|Womens       |

