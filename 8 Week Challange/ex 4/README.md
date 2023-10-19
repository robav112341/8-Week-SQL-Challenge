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
