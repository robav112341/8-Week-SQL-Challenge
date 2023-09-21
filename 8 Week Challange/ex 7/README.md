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


