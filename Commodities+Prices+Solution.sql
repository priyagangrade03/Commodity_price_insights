/************************************************************************************************
Question 1: Get the common commodities between the Top 10 costliest commodities of 2019 and 2020.
************************************************************************************************/
   USE commodity_db;
WITH top_2019 AS
(SELECT  commodity_id, AVG(retail_price) AS average_price_2019
FROM price_details
WHERE YEAR(date) = 2019
GROUP BY commodity_id
ORDER BY avg(retail_price) DESC
LIMIT 10),
top_2020 AS
(SELECT commodity_id, AVG(retail_price) AS average_price_2020
FROM price_details
WHERE YEAR(date) = 2020
GROUP BY commodity_id
ORDER BY avg(retail_price) DESC
LIMIT 10)
SELECT DISTINCT commodity
FROM top_2019 t19
INNER JOIN top_2020 t20
ON t19.commodity_id = t20.commodity_id
INNER JOIN commodities_info ci
ON ci.id = t19.commodity_id;



/************************************************************************************************
Question 2: What is the maximum difference between the prices of a commodity at one place vs the other 
for the month of Jun 2020? Which commodity was it for?

Algorithm:
Input: price_details: Id, Region_Id, Commodity_Id, Date and Retail_Price; commodities_info: Id and Commodity
Expected Output: Commodity | price difference;  Retain the info for highest difference
Step 1: Filter Jun 2020 in Date column of price_details
Step 2: Aggregation – MIN(retail_price), MAX(retail_price) group by commodity
Step 3: Compute the difference between the Max and Min retail price
Step 4: Sort in descending order of price difference; Retain the top most row
************************************************************************************************/
SELECT ci.commodity, MAX(pd.retail_price) - MIN(pd.retail_price) AS price_difference
FROM price_details pd
JOIN commodities_info ci
ON ci.Id = pd.commodity_id
WHERE YEAR(pd.date) = 2020 AND MONTH(pd.date) = 6
GROUP BY ci.commodity 
ORDER BY price_difference DESC
LIMIT 1;

/************************************************************************************************
Question 3: Arrange the commodities in order based on the number of varieties in which they are available, 
with the highest one shown at the top. Which is the 3rd commodity in the list?

Algorithm:
Input: commodities_info: Commodity and Variety
Expected Output: Commodity | Variety count;  Sort in descending order of Variety count
Step 1: Aggregation – COUNT(DISTINCT variety), group by Commodity
Step 2: Sort the final table in descending order of Variety count
************************************************************************************************/

SELECT commodity, COUNT(DISTINCT Variety) AS variety_count
FROM commodities_info 
GROUP BY commodity
ORDER BY variety_count DESC
LIMIT 3;


/************************************************************************************************
Question 4: In the state with the least number of data points available. 
Which commodity has the highest number of data points available?

Algorithm:
Input: price_details: Id, region_id, commodity_id region_info: Id and State commodities_info: Id and Commodity
Expected Output: commodity;  Expecting only one value as output
Step 1: Join region info and price details using the Region_Id from price_details with Id from region_info
Step 2: From result of Step 1, perform aggregation – COUNT(Id), group by State; 
Step 3: Sort the result based on the record count computed in Step 2 in ascending order; 
		Filter for the top State
Step 4: Filter for the state identified from Step 3 from the price_details table
Step 5: Aggregation – COUNT(Id), group by commodity_id; Sort in descending order of count 
Step 6: Filter for top 1 value and join with commodities_info to get the commodity name
************************************************************************************************/

SELECT state, commodity, count(pd.id) AS data_count
FROM region_info ri
INNER JOIN price_details pd
ON ri.Id = pd.region_id
INNER JOIN commodities_info ci
ON ci.id = pd.commodity_id
WHERE state = 
(SELECT state
FROM region_info ri
INNER JOIN price_details pd
ON ri.Id = pd.region_id
GROUP BY state
ORDER BY count(pd.id)
LIMIT 1)
GROUP BY state, commodity
ORDER BY data_count DESC 
LIMIT 1;

/*******************************************************************************************************
Question 5: What is the price variation of commodities for each city from Jan 2019 to Dec 2020. 
			Which commodity has seen the highest price variation and in which city?
Algorithm:
Input: price_details: Id, region_id, commodity_id, date, retail_price 
	   region_info: Id and City 
	   commodities_info: Id and Commodity
Expected Output: Commodity | city | Start Price | End Price | Variation absolute | Variation Percentage;  
Sort in descending order of variation %

Step 1: Filter for Jan 2019 from Date column of the price_details table
Step 2: Filter for Dec 2020 from Date column of the price_details table
Step 3: Do an inner join between the results from Step 1 and Step 2 on region_id and commodity id
Step 4: Name the price from Step 1 result as Start Price and Step 2 result as End Price
Step 5: Calculate Variations in absolute and percentage; 
		Sort the final table in descending order of Variation Percentage
Step 6: Filter for 1st record and join with region_info, commodities_info to get city and commodity name
********************************************************************************************************/

CREATE VIEW full_table AS
SELECT 
    ri.state, 
    ri.centre, 
    ci.Commodity, 
    pd.date, 
    pd.retail_price
FROM commodity_db.region_info ri
JOIN commodity_db.price_details pd ON ri.Id = pd.region_id
JOIN commodity_db.commodities_info ci ON ci.Id = pd.commodity_id;

WITH jan_2019 AS (
   SELECT centre, commodity, retail_price AS start_price
   FROM full_table
   WHERE MONTH(date) = 1
   AND YEAR(date) = 2019
),
dec_2020 AS (
   SELECT centre, commodity, retail_price AS end_price
   FROM full_table
   WHERE MONTH(date) = 12
     AND YEAR(date) = 2020
)
  SELECT 
      j.centre, j.Commodity, j.start_price, d.end_price,
      ABS(d.end_price - j.start_price) AS variation_abs
  FROM jan_2019 j
  JOIN dec_2020 d
       ON j.centre = d.centre AND j.Commodity = d.Commodity
  ORDER BY variation_abs DESC
  LIMIT 1;

