# 🥑 Case Study #3: Foodie-Fi 
<img src="https://user-images.githubusercontent.com/81607668/129742132-8e13c136-adf2-49c4-9866-dec6be0d30f0.png" width="500" height="520" alt="image">

## 📚 Table of Contents
- [Business Task](#problem-statement)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#case-Study-questions)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-3/). 

***
## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/129744449-37b3229b-80b2-4cce-b8e0-707d7f48dcec.png)

***
## Problem Statement

Danny realised that he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows! Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

This case study focuses on using subscription style digital data to answer important business questions.

## Case Study Questions

**Data Analysis Questions**
**1. How many customers has Foodie-Fi ever had?**

````sql
SELECT 
    COUNT(DISTINCT customer_id) AS number_of_customers
FROM
    subscriptions;
````

| number_of_customers       |
| ------------------------- |
| 1000                      |

**2. What is the monthly distribution of trial plan start_date values for our dataset?**

````sql
SELECT 
    MONTHNAME(start_date) AS month_, COUNT(customer_id) AS count_customers
FROM
    subscriptions
WHERE
    plan_id = 0
GROUP BY MONTH(start_date)
ORDER BY MONTH(start_date);
````

| MONTH   | number_of_customers    |
| ------- |  --------------------- |
| January   |  88                  |
| February  |  68                  |
| March     |  94                  |
| April     |  81                  |
| May       |  88                  |
| June      |  79                  |
| July      |  89                  |
| August    |  88                  |
| September |  87                  |
| October   |  79                  |
| November  |  75                  |
| December  |  84                  |
