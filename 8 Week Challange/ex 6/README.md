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

**4. What is the number of events for each event type?**

````sql
SELECT 
    ei.event_name, COUNT(*) AS count_events
FROM
    events e
        JOIN
    event_identifier ei ON e.event_type = ei.event_type
GROUP BY e.event_type;
````

| event_name    | count_events     |
| ------------- | ---------------- |
| Page View     | 20928            |
| Add to Cart   | 8451             |
| Purchase      | 1777             |
| Ad Impression | 876              |
| Ad Click      | 702              |

**5. What is the percentage of visits which have a purchase event?**

````sql
SELECT 
    e.event_type,
    ei.event_name,
    COUNT(DISTINCT visit_id) AS count_type3,
    ROUND(COUNT(*) / (SELECT 
                    COUNT(DISTINCT visit_id)
                FROM
                    events) * 100,
            1) AS percentage
FROM
    events e
        JOIN
    event_identifier ei ON e.event_type = ei.event_type
WHERE
    e.event_type = 3
GROUP BY 1;
````

| event_type | event_name | count_type 3 | percentage |
| ---------- | ---------- | ------------ | ---------- |
|     3      |  Purchase  |    1777      |   49.9     |
