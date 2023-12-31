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

**4. What is the total sales for each region for each month?**

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

**5. What is the total count of transactions for each platform?**

```sql
SELECT 
    platform, SUM(transactions) AS total_transcations
FROM
    clean_weekly_sales
GROUP BY 1
ORDER BY 1;
```

| platform | total_transactions  |
|----------|---------------------|
| Retail   | 1081934227          |
| Shopify  | 5925169             |

**6. What is the percentage of sales for Retail vs Shopify for each month?**

```sql
SELECT 
    s1.calendar_year,
    s1.month_number,
    s1.platform,
    SUM(s1.sales) AS total_sales,
    ROUND((SUM(sales) / (SELECT 
                    SUM(s2.sales)
                FROM
                    clean_weekly_sales s2
                WHERE
                    s2.calendar_year = s1.calendar_year
                        AND s2.month_number = s1.month_number
                GROUP BY s2.calendar_year , s2.month_number)) * 100,
            1) AS precentage
FROM
    clean_weekly_sales s1
GROUP BY 1 , 2 , 3
ORDER BY 1 , 2 , 3;
```

<details><summary> Click to expand :arrow_down: </summary>
	
|calendar_year|	month_number| platform | total_sales |	precentage |
| ----------- | ----------- | -------- | ----------- | ----------- |
|2018		|3	|Retail		|525583061	|97.9|
|2018		|3	|Shopify	|11172391	|2.1|
|2018		|4	|Retail		|2617369077	|97.9|
|2018		|4	|Shopify	|55435570	|2.1|
|2018		|5	|Retail		|2080290488	|97.7|
|2018		|5	|Shopify	|48365936	|2.3|
|2018		|6	|Retail		|2061128568	|97.8|
|2018		|6	|Shopify	|47323635	|2.2|
|2018		|7	|Retail		|2646368290	|97.8|
|2018		|7	|Shopify	|60830182	|2.2|
|2018		|8	|Retail		|2140297292	|97.7|
|2018		|8	|Shopify	|50244975	|2.3|
|2018		|9	|Retail		|540134542	|97.7|
|2018		|9	|Shopify	|12836820	|2.3|
|2019		|3	|Retail		|567984858	|97.7|
|2019		|3	|Shopify	|13332196	|2.3|
|2019		|4	|Retail		|2836349313	|97.8|
|2019		|4	|Shopify	|63798008	|2.2|
|2019		|5	|Retail		|2221160706	|97.5|
|2019		|5	|Shopify	|56371106	|2.5|
|2019		|6	|Retail		|2181126868	|97.4|
|2019		|6	|Shopify	|57727053	|2.6|
|2019		|7	|Retail		|2785870177	|97.4|
|2019		|7	|Shopify	|75766614	|2.6|
|2019		|8	|Retail		|2240942490	|97.2|
|2019		|8	|Shopify	|64297818	|2.8|
|2019		|9	|Retail		|564372315	|97.1|
|2019		|9	|Shopify	|16932978	|2.9|
|2020		|3	|Retail		|1205620498	|97.3|
|2020		|3	|Shopify	|33475731	|2.7|
|2020		|4	|Retail		|2281873844	|97.0|
|2020		|4	|Shopify	|71478722	|3.0|
|2020		|5	|Retail		|2284387029	|96.7|
|2020		|5	|Shopify	|77687860	|3.3|
|2020		|6	|Retail		|2807693824	|96.8|
|2020		|6	|Shopify	|92714414	|3.2|
|2020		|7	|Retail		|2255852981	|96.7|
|2020		|7	|Shopify	|77642565	|3.3|
|2020		|8	|Retail		|2810210216	|96.5|
|2020		|8	|Shopify	|101583216	|3.5|
</details>

**7. What is the percentage of sales by demographic for each year in the dataset?**

```sql
SELECT 
    s1.calendar_year,
    s1.demographic,
    SUM(s1.sales) AS total_sales,
    ROUND((SUM(s1.sales) / (SELECT 
                    SUM(s2.sales)
                FROM
                    clean_weekly_sales s2
                WHERE
                    s1.calendar_year = s2.calendar_year
                GROUP BY s2.calendar_year)) * 100,
            1) AS total_sales_P
FROM
    clean_weekly_sales s1
GROUP BY 1 , 2
ORDER BY 1 , 2;
```

| calendar_year | demographic |	total_sales | total_sales_P |
| ------------- | ----------- | ----------- | ------------- |
|2018		|Couples	|3402388688		|26.4|
|2018		|Families	|4125558033		|32.0|
|2018		|Unknown	|5369434106		|41.6|
|2019		|Couples	|3749251935		|27.3|
|2019		|Families	|4463918344		|32.5|
|2019		|Unknown	|5532862221		|40.3|
|2020		|Couples	|4049566928		|28.7|
|2020		|Families	|4614338065		|32.7|
|2020		|Unknown	|5436315907		|38.6|

**8. Which age_band and demographic values contribute the most to Retail sales?**

```sql
WITH full_data AS (
	SELECT 
    *,
    (CASE
        WHEN SUBSTRING(segment, 2, 2) = 1 THEN 'Young Adults'
        WHEN SUBSTRING(segment, 2, 2) = 2 THEN 'Middle Aged'
        WHEN SUBSTRING(segment, 2, 2) IN (3 , 4) THEN 'Retirees'
        ELSE 'Unknown'
    END) AS age_band
FROM
    clean_weekly_sales)
SELECT
	age_band,
	sum(sales) as total_sales
FROM
	full_data
WHERE platform = 'Retail' AND age_band <> 'Unknown'
GROUP BY age_band
ORDER BY sum(sales) DESC
LIMIT 1;
```

| age_band | total_sales | 
|----------|-------------|
| Retirees | 13005266930 | 

**8. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**

```sql
SELECT 
    calendar_year,
    platform,
    ROUND(SUM(sales) / SUM(transactions), 1) AS avg_transaction
FROM
    clean_weekly_sales
GROUP BY 1 , 2
ORDER BY 1 , 2;
```

| calendar_year | platform | avg_transaction | 
|---------------|----------|-----------------|
| 2018          | Retail   | 36.6            | 
| 2018          | Shopify  | 192.5           |
| 2019          | Retail   | 36.8            | 
| 2019          | Shopify  | 183.4           | 
| 2020          | Retail   | 36.6            | 
| 2020          | Shopify  | 179.0           | 

### 🧼 C. Before & After Analysis

**1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?**

```sql
WITH w_number AS (
	SELECT 
		week_number
	FROM
		clean_weekly_sales
	WHERE
		week_date = '2020-06-15'
    GROUP BY week_number),
total_sales_before AS (
	SELECT sum(sales) as sum_before
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number) -4  AND (SELECT week_number FROM w_number) -1 AND calendar_year = 2020),
total_sales_after AS (
	SELECT sum(sales) as sum_after
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number)   AND (SELECT week_number FROM w_number) +3 AND calendar_year = 2020),
sum_table AS (
	SELECT (SELECT sum_before FROM total_sales_before) AS sales_before,
		(SELECT sum_after FROM total_sales_after) AS sales_after)
SELECT 
	sales_before,
    sales_after,
    -(sales_before-sales_after) AS change_in_sales,
    (sales_before/sales_after-1)*100 AS change_in_p
    FROM
    sum_table;
```

| sales_before       | sales_after       | change_in_sales | change_in_p           |
|--------------------|-------------------|-----------------|-----------------------|
| 2345878357         | 2318994169        | -26884188       | -1.1593               |

**2. What about the entire 12 weeks before and after?**

```sql
WITH w_number AS (
	SELECT 
		week_number
	FROM
		clean_weekly_sales
	WHERE
		week_date = '2020-06-15'
    GROUP BY week_number),
total_sales_before AS (
	SELECT sum(sales) as sum_before
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number) -12  AND (SELECT week_number FROM w_number) -1 AND calendar_year = 2020),
total_sales_after AS (
	SELECT sum(sales) as sum_after
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number)   AND (SELECT week_number FROM w_number) +11 AND calendar_year = 2020),
sum_table AS (
SELECT (SELECT sum_before FROM total_sales_before) AS sales_before,
		(SELECT sum_after FROM total_sales_after) AS sales_after)
SELECT 
	sales_before,
	sales_after,
    -(sales_before-sales_after) AS change_in_sales,
    (sales_before/sales_after-1)*100 AS change_in_p 
    FROM 
    sum_table;
```
| sales_before       | sales_after       | change_in_sales | change_in_p           |
|--------------------|-------------------|-----------------|-----------------------|
| 7126273147         | 6973947753        | -152325394      | -2.1842               |

**3. What about the entire 12 weeks before and after?**

```sql
WITH w_number AS (
	SELECT 
		week_number
	FROM
		clean_weekly_sales
	WHERE
		week_date = '2020-06-15'
    GROUP BY week_number),
total_sales_before AS (
	SELECT 
		calendar_year,
		sum(sales) as sum_before
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number) -4  AND (SELECT week_number FROM w_number) -1
    GROUP BY 1),
total_sales_after AS (
	SELECT
		calendar_year,
		sum(sales) as sum_after
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number)   AND (SELECT week_number FROM w_number) +3
    GROUP BY 1)
SELECT 
	s1.calendar_year,
	s1.sum_before,
	s2.sum_after,
	(s2.sum_after-s1.sum_before) as total_change,
	ROUND((s2.sum_after/s1.sum_before -1)*100,1) AS p_change
FROM
	total_sales_before s1 
JOIN
	total_sales_after s2
ON s1.calendar_year = s2.calendar_year;
```

| calendar_year | sum_before | sum_after  | total_change    | p_change  |
|---------------|------------|------------|-----------------|---------- |
| 2018          | 2125140809 | 2129242914 | 4102105         | 0.2       |
| 2019          | 2249989796 | 2252326390 | 2336594         | 0.1       |
| 2020          | 2345878357 | 2318994169 | -26884188       | -1.1      |

**4. Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?**

Guest

```sql
WITH w_number AS (
	SELECT 
		week_number
	FROM
	clean_weekly_sales
	WHERE
		week_date = '2020-06-15'
    GROUP BY week_number),
total_sales_before AS (
	SELECT
		customer_type,
		sum(sales) as sum_before
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number) -12  AND (SELECT week_number FROM w_number) -1 AND calendar_year = 2020
    GROUP BY 1),
total_sales_after AS (
	SELECT
		customer_type,
		sum(sales) as sum_after
	FROM clean_weekly_sales 
	WHERE week_number BETWEEN (SELECT week_number FROM w_number)   AND (SELECT week_number FROM w_number) +11 AND calendar_year = 2020
    GROUP BY 1)
SELECT
	s1.customer_type,
	s1.sum_before,
	s2.sum_after,
	(s2.sum_after - s1.sum_before) as total_change,
	ROUND((s2.sum_after/s1.sum_before - 1)*100,2) as p_change
FROM
	total_sales_before s1
JOIN 
	total_sales_after s2 ON s1.customer_type = s2.customer_type
ORDER BY 5;
```

| customer_type | sum_before | sum_after  | total_change    | p_change  |
|---------------|------------|------------|-----------------|---------- |
| Guest         | 2573436301 | 2496233635 | -77202666       | -3.00     |
| Existing      | 3690116427 | 3606243454 | -83872973       | -2.27     |
| New           | 862720419  | 871470664  | 8750245         | 1.01      |

