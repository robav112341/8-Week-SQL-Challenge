# Case Study #6: Clique Bait
<img src="https://user-images.githubusercontent.com/81607668/134615258-d1108e0d-0816-4cd7-a972-d45580f82352.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#problem-statement)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#Case-Study-Questions)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-6/). 

***
## Entity Relationship Diagram

<img width="825" alt="image" src="https://user-images.githubusercontent.com/81607668/134619326-f560a7b0-23b2-42ba-964b-95b3c8d55c76.png">

***
## Problem Statement

Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

## Case Study Questions
**Digital Analysis**

**1. How many users are there?**

````sql
SELECT 
    COUNT(DISTINCT user_id) AS users_count
FROM
    USERS
;
````

| users_count |
| ----------- |
|    500      |

**2. How many cookies does each user have on average?** 

````sql
SELECT 
    ROUND(COUNT(*) / COUNT(DISTINCT user_id),2) AS avg_per_user
FROM
    USERS
;
````

| avg_per_user |
| ------------ |
|    3.56      |

**3. What is the unique number of visits by all users per month?**

````sql
SELECT 
    MONTHNAME(event_time) AS month_name,
    COUNT(DISTINCT visit_id) AS visits_count
FROM
    EVENTS
GROUP BY 1
ORDER BY event_time;
````

| month_name| visits_count  |
| --------- | ------------- |
| January   | 876           |
| February  | 1488          |
| March     | 916           |
| April     | 248           |
| May       | 36            |
