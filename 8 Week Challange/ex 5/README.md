# Case Study #5: Data Mart :shopping:
<img src="https://user-images.githubusercontent.com/81607668/131437982-fc087a4c-0b77-4714-907b-54e0420e7166.png" alt="Image" width="500" height="520">
## 📚 Table of Contents
- [Business Task](#problem-statement)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#case-Study-questions)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-5/). 

***
## Entity Relationship Diagram

<img width="287" alt="image" src="https://user-images.githubusercontent.com/81607668/131438278-45e6a4e8-7cf5-468a-937b-2c306a792782.png">

***
## Problem Statement

Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas..

## Case Study Questions

### 🧼 A. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the `data_mart` schema named `clean_weekly_sales`:
- Convert the `week_date` to a `DATE` format
- Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a `month_number` with the calendar month for each `week_date` value as the 3rd column
- Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called `age_band` after the original segment column using the following mapping on the number inside the segment value
  
| segment | age_band    | 
| ------- | ----------- |
| 1       | Young Adults|
| 2       | Middle Aged |
| 3 OR 4  | Retirees    |

- Add a new `demographic` column using the following mapping for the first letter in the `segment` values:  

| segment | demographic | 
| ------- | ----------- |
| C | Couples |
| F | Families |

- Ensure all `null` string values with an "unknown" string value in the original `segment` column as well as the new `age_band` and `demographic` columns
- Generate a new `avg_transaction` column as the sales value divided by transactions rounded to 2 decimal places for each record

**Query:**

```sql
DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TABLE IF NOT EXISTS `clean_weekly_sales` (
    `week_date` DATE DEFAULT NULL,
    `week_number` INT DEFAULT NULL,
    `month_number` INT DEFAULT NULL,
    `calendar_year` INT DEFAULT NULL,
    `region` VARCHAR(15) DEFAULT NULL,
    `platform` VARCHAR(9) DEFAULT NULL,
    `segment` VARCHAR(4) DEFAULT NULL,
    `customer_type` VARCHAR(11) DEFAULT NULL,
    `demographic` VARCHAR(20) DEFAULT NULL,
    `transactions` INT DEFAULT NULL,
    `sales` INT DEFAULT NULL,
    `avg_transaction` DOUBLE DEFAULT NULL
);

INSERT INTO clean_weekly_sales (
week_date,
week_number,
month_number,
calendar_year,
region,
platform,
segment,
customer_type,
demographic,
transactions,
sales,
avg_transaction)
SELECT 
    STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,
    EXTRACT(WEEK FROM STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number,
    EXTRACT(MONTH FROM STR_TO_DATE(week_date, '%d/%m/%y')) AS month_number,
    EXTRACT(YEAR FROM STR_TO_DATE(week_date, '%d/%m/%y')) AS calendar_year,
    region,
    platform,
    segment,
    customer_type,
    (CASE
        WHEN SUBSTRING(segment, 1, 1) = 'C' THEN 'Couples'
        WHEN SUBSTRING(segment, 1, 1) = 'F' THEN 'Families'
        ELSE 'Unknown'
    END) AS demographic,
    transactions,
    sales,
    ROUND((sales / transactions), 1) AS avg_transaction 
FROM
    Weekly_sales
ORDER BY 4;

-- some kind of error in age_band, saved query for later use:
 SELECT 
    (CASE
        WHEN SUBSTRING(segment, 2, 2) = 1 THEN 'Young Adults'
        WHEN SUBSTRING(segment, 2, 2) = 2 THEN 'Middle Aged'
        WHEN SUBSTRING(segment, 2, 2) IN (3 , 4) THEN 'Retirees'
        ELSE 'Unknown'
    END) AS age_band
FROM
    clean_weekly_sales;
```

### 🛍 B. Data Exploration

**1. What day of the week is used for each week_date value?**

```sql
SELECT 
    IF(DAYOFWEEK(week_date) = 2,
        'Monday',
        'ELSE') AS day_of_week
FROM
    clean_weekly_sales
GROUP BY DAYOFWEEK(week_date);
```
|day_of_week|
| --------- |
|  Monday   |

**2. What range of week numbers are missing from the dataset?**

```sql
WITH RECURSIVE weeks_list (week_number) AS (
	SELECT 1 
	UNION ALL
	SELECT week_number+1 FROM weeks_list WHERE week_number < 52
) 
SELECT 
	*
FROM
	weeks_list
WHERE week_number NOT IN ( SELECT week_number FROM clean_weekly_sales);
```

<details><summary> Click to expand :arrow_down: </summary>
  
| missing_weeks  |
|----------------|
| 1              | 
| 2              |
| 3              |
| 4              |
| 5              |
| 6              |
| 7              |
| 8              |
| 9              |
| 10             |
| 11             |
| 12             |
| 37             |
| 38             |
| 39             |
| 40             |
| 41             |
| 42             |
| 43             |
| 44             |
| 45             |
| 46             |
| 47             |
| 48             |
| 49             |
| 50             |
| 51             |
| 52             |
  
</details>

**3. How many total transactions were there for each year in the dataset?**

```sql
SELECT 
    calendar_year, SUM(transactions) AS total_transactions
FROM
    clean_weekly_sales
GROUP BY 1;
```

| calendar_year | total_transactions            |
|---------------|-------------------------------|
| 2018          | 346406460                     |
| 2019          | 365639285                     |
| 2020          | 375813651                     |

**4. 4. What is the total sales for each region for each month?**

```sql
SELECT 
    region, month_number, SUM(sales)
FROM
    clean_weekly_sales
GROUP BY 1 , 2
ORDER BY 1 , 2;
```

<details><summary> Click to expand :arrow_down: </summary>
  
| region        | month_number | total_sales  |
|---------------|--------------|--------------|
| AFRICA        | 3            | 567767480    |
| AFRICA        | 4            | 1911783504   |
| AFRICA        | 5            | 1647244738   |
| AFRICA        | 6            | 1767559760   |
| AFRICA        | 7            | 1960219710   |
| AFRICA        | 8            | 1809596890   |
| AFRICA        | 9            | 276320987    |
| ASIA          | 3            | 529770793    |
| ASIA          | 4            | 1804628707   |
| ASIA          | 5            | 1526285399   |
| ASIA          | 6            | 1619482889   |
| ASIA          | 7            | 1768844756   |
| ASIA          | 8            | 1663320609   |
| ASIA          | 9            | 252836807    |
| CANADA        | 3            | 144634329    |
| CANADA        | 4            | 484552594    |
| CANADA        | 5            | 412378365    |
| CANADA        | 6            | 443846698    |
| CANADA        | 7            | 477134947    |
| CANADA        | 8            | 447073019    |
| CANADA        | 9            | 69067959     |
| EUROPE        | 3            | 35337093     |
| EUROPE        | 4            | 127334255    |
| EUROPE        | 5            | 109338389    |
| EUROPE        | 6            | 122813826    |
| EUROPE        | 7            | 136757466    |
| EUROPE        | 8            | 122102995    |
| EUROPE        | 9            | 18877433     |
| OCEANIA       | 3            | 783282888    |
| OCEANIA       | 4            | 2599767620   |
| OCEANIA       | 5            | 2215657304   |
| OCEANIA       | 6            | 2371884744   |
| OCEANIA       | 7            | 2563459400   |
| OCEANIA       | 8            | 2432313652   |
| OCEANIA       | 9            | 372465518    |
| SOUTH AMERICA | 3            | 71023109     |
| SOUTH AMERICA | 4            | 238451531    |
| SOUTH AMERICA | 5            | 201391809    |
| SOUTH AMERICA | 6            | 218247455    |
| SOUTH AMERICA | 7            | 235582776    |
| SOUTH AMERICA | 8            | 221166052    |
| SOUTH AMERICA | 9            | 34175583     |
| USA           | 3            | 225353043    |
| USA           | 4            | 759786323    |
| USA           | 5            | 655967121    |
| USA           | 6            | 703878990    |
| USA           | 7            | 760331754    |
| USA           | 8            | 712002790    |
| USA           | 9            | 110532368    |

</details>
