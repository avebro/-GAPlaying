--question 1

SELECT county 
	, sum(total) as "Sales" 
FROM sales 
WHERE category_name LIKE '%VODKA%' or category_name LIKE '%WHISK%' 
GROUP BY county 
ORDER BY "Sales" DESC	


-- question 2
SELECT s.county
    , sum(s.total) as "Sales"
FROM sales s
LEFT OUTER JOIN products p
ON s.item = p.item_no
WHERE Cast(p.proof as numeric) > 80
GROUP BY county
ORDER BY "Sales" DESC

-- Question 3 s.liter_size * s.bottle_qty/ population  by county 

SELECT c.county
	, ("totalML"/c.population) as "PerCapitaML"
FROM counties c
INNER JOIN 
	(
	SELECT county 
		, SUM(pack * liter_size * bottle_qty) as "totalML" 
	FROM sales
	WHERE county is not NULL
	GROUP BY county
	ORDER BY "totalML" DESC) as T1
ON c.county = T1.county
ORDER BY "PerCapitaML" DESC

-- What percentage of sales per county are over $100? What are the top five counties?

SELECT 
	County
-- 	, Count(county)
    , CASE 
    	WHEN total > 100 THEN 'HIGH'
     	ELSE 'LOW'
     END as salecategory
FROM sales
GROUP BY County, sales.total


SELECT 
	County
	, Count(county)
FROM sales
WHERE total > 100
GROUP BY County



-- What were the top five categories of liquor sold (based on number of sales) in the five most populous counties?

