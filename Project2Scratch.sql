

# Are we missing any data assuminig ID is sequential? 
	# Based on the below query it looks like we are missing about 69 entries (have to count id 0) 
Select 
	MAX(id)
    , Min(id) 
    , count(id)
    , (max(id)-count(id))
   
FROM users

-- Unique OS 
SELECT 
	DISTINCT os 
FROM users
ORDER BY os


-- users who did not take the survey - 2,3186

SELECT 
	Count(u.id) as "users who did not take survey"
FROM users u
LEFT OUTER JOIN survey s
ON u.id = s.user_id
WHERE s.user_id is NULL 


-- No user were in the survey table that were not in the users table
SELECT 
	Count(s.user_id) as "users who wer not in the users table"
FROM users u
RIGHT OUTER JOIN survey s
ON u.id = s.user_id
WHERE u.id is NULL 



-- unique events (total of 21 different events) 
SELECT DISTINCT event_code
FROM events
ORDER BY 1


-- event code count by user and event
SELECT user_id
	, event_code
    , count(event_code) as "EventFrequency"
FROM events
GROUP BY user_id, event_code
ORDER BY user_id, event_code

-- how many unique users are in the events table?  14718
SELECT COUNT(DISTINCT(user_id))
FROM EVENTS

-- how many unique users are in the survey table?  4081
SELECT COUNT(DISTINCT(user_id))
FROM Survey


-- how many unique users are in the users table?  27267
SELECT COUNT(DISTINCT(id))
FROM users


-- No user were in the events table that were not in the users table
SELECT 
	Count(e.user_id) as "users who were not in the users table"
FROM users u
RIGHT OUTER JOIN events e
ON u.id = e.user_id
WHERE u.id is NULL 


-- No user were in the events table that were not in the users table
SELECT 
	Count(s.user_id) as "users who were not in the survey table"
FROM survey s
RIGHT OUTER JOIN events e
ON s.user_id = e.user_id
WHERE e.user_id is NULL 

-- Bookmarks
-- Median number of bookmarks? 28 
-- Average number of bookmarks? 106.7

SELECT 
 	MEDIAN(CAST(REPLACE(data1, ' total bookmarks','') as numeric)) as NumberOfBookmarks
--    AVG(CAST(REPLACE(data1, ' total bookmarks','') as numeric)) as NumberOfBookmarks
FROM events
WHERE event_code in (8) 
ORDER BY NumberOfBookmarks DESC

-- What fraction of users launched at least one bookmakr during the sample week? 6534/14718 (from other queries) 44.39% of users whose events were recorded launched a bookmark

SELECT COUNT(DISTINCT(user_id)) as "UsersWhoCreatedBookmark"
FROM events
WHERE event_code in (10) 


-- How many users are creating bookmarks? 988
SELECT COUNT(DISTINCT(user_id)) as "UsersWhoCreatedBookmark"
FROM events
WHERE event_code in (9) and data1 = 'New Bookmark Added'

-- What fraction of users created new bookmarks? 988/ 14718(from other query) 6.71% of users whose events were recorded launched a bookmark

-- What's the distribution of how often bookmarks are used?
SELECT *
 	, to_timestamp(timestamp)
FROM events e
LIMIT 100


SELECT *
FROM survey
LIMIT 100


-- How does number of bookmarks correlate with how long the user has been using Firefox?


-- How  many bookmarks are they creating? 2076
SELECT COUNT(user_id)
FROM events
WHERE event_code in (9) and data1 = 'New Bookmark Added'

-- Bookmarks created per user who creates bookmarks -- 2076/988 = 2.1

-- Bookmark interaction - (event codes 9,10,11) - 65,020 bookmark interactions
SELECT COUNT(user_id) as "BookmarkInteraction"
FROM events
WHERE event_code in (9, 10, 11) 

-- Number of users who interacted with Bookmarks - (event codes 9,10,11) - 6,871 users interacted with bookmarks
SELECT COUNT(DISTINCT(user_id)) as "BookmarkInteraction"
FROM events
WHERE event_code in (9, 10, 11) 

-- Number of bookmark interactions per user who uses bookmarks - 65020/6871 = 9.46 rounds to 10 

-- Tabs
-- Average number of tabs open at any given time. 
SELECT user_id
-- 	, (CAST(data1 as numeric) * CAST(data2 as numeric)) as "TotalTabs"
	, data1
    , data2
    , fx_version
FROM events e
JOIN users u
ON u.id = e.user_id
WHERE event_code in (26) and data2 in ('0 tabs', '1 tabs') and data1 not in ('0 windows','1 windows')
LIMIT 100

-- michael's code
Select distinct Cast(replace(data1, ' windows', '') as numeric) as windows, cast(replace(data2, ' tabs', '') as numeric) as tabs 
	, count(*)  as counter
-- 	, windows as diff
from events
where event_code = '26' 
group by windows, tabs
Order by tabs asc, windows asc

-- Average number of tabs open upon restore. (20) - Throw out 0s due to no restore
SELECT *
FROM events
WHERE 


-- Average number of tabs per user based on most recent session

-- Max number of tabs by user? 
-- absolute max? 1103

SELECT user_id
	, MAX(cast(replace(data2, ' tabs', '') as numeric)) as "tabs"
FROM events
where event_code = '26'
GROUP BY user_id
ORDER BY tabs DESC

-- Max tabs by percentile 

SELECT user_id
      , tabs
      , ntile(4) OVER(ORDER BY tabs) as percentile 
FROM
      ( SELECT user_id
             , MAX(cast(replace(data2, ' tabs', '') as numeric)) as "tabs"
        FROM events
        WHERE event_code = '26'
        GROUP BY user_id
        ORDER BY tabs DESC) a
                                
-- Average number of max bookmarks by quartile 
-- Average number of max bookmarks for the middle 50% of users recorded.   3rd quartile (43.894 ~ 44 tabs) 2nd quartile (21.003 ~ 21) 
SELECT AVG(bookmarks)
    , percentile
FROM 
	(Select user_id
      , bookmarks
      , ntile(4) OVER(ORDER BY bookmarks) as percentile 
	FROM
      ( SELECT user_id
             , MAX(cast(replace(data1, ' total bookmarks', '') as numeric)) as "bookmarks"
        FROM events
        WHERE event_code = '8'
        GROUP BY user_id
        ORDER BY bookmarks DESC) a) a
-- WHERE a.percentile in (2,3)
GROUP BY percentile 


-- Average number of max tabs by quartile 
-- Average number of max tabs for the middle 50% of users recorded.   3rd quartile (4.967 ~ 5 tabs) 2nd quartile (2.922 ~ 3) 
SELECT AVG(tabs)
    , percentile
FROM 
	(Select user_id
      , tabs
      , ntile(4) OVER(ORDER BY tabs) as percentile 
	FROM
      ( SELECT user_id
             , MAX(cast(replace(data2, ' tabs', '') as numeric)) as "tabs"
        FROM events
        WHERE event_code = '26'
        GROUP BY user_id
        ORDER BY tabs DESC) a) a
-- WHERE a.percentile in (2,3)
GROUP BY percentile 


-- Average bookmark uses by quartile

SELECT AVG(bookmarkuses)
    , percentile
FROM 
	(Select user_id
      , bookmarkuses
      , ntile(4) OVER(ORDER BY bookmarkuses) as percentile 
	FROM
      ( SELECT user_id
            , Count(user_id) as "bookmarkuses"
        FROM events
        WHERE event_code = '10'
        GROUP BY user_id
        ORDER BY bookmarkuses DESC) a) a
GROUP BY percentile 
ORDER BY percentile ASC

-- Average bookmark uses by 10 percentiles

SELECT AVG(bookmarkuses)
    , percentile
FROM 
	(Select user_id
      , bookmarkuses
      , ntile(10) OVER(ORDER BY bookmarkuses) as percentile 
	FROM
      ( SELECT user_id
            , Count(user_id) as "bookmarkuses"
        FROM events
        WHERE event_code = '10'
        GROUP BY user_id
        ORDER BY bookmarkuses DESC) a) a
GROUP BY percentile 
ORDER BY percentile DESC


-- Average tabs uses by 10 percentiles

SELECT AVG(tabs)
    , percentile
    , Count(user_id)
FROM 
	(Select user_id
      , tabs
      , ntile(10) OVER(ORDER BY tabs) as percentile 
	FROM
      ( SELECT user_id
             , MAX(cast(replace(data2, ' tabs', '') as numeric)) as "tabs"
        FROM events
        WHERE event_code = '26'
        GROUP BY user_id
        ORDER BY tabs DESC) a) a
-- WHERE a.percentile in (2,3)
GROUP BY percentile 
ORDER BY percentile ASC



-- what do newer people use more?

-- Categorizing users 

SELECT user_id
	, q1
    ,CASE 
    	WHEN q1 in ('0','1', '2') THEN 'New_User' 
        WHEN q1 in ('3','4') THEN 'User'
        ELSE 'Old_User'
     END as "UserAge"
     , q7
     ,CASE 
    	WHEN q7 in ('0','1') THEN 'Low_Usage' 
        WHEN q7 in ('2','3','4') THEN 'Moderate_Usage'
        ELSE 'High_usage'
     END as "UsageRate"
FROM survey


-- Type of usage user are by user experience

SELECT a.UserExperience
	, a.UsageRate
 	, Count(a.UsageRate)  
From
	(
    SELECT user_id
        , q1
        ,CASE 
            WHEN q1 in ('0','1', '2') THEN '1 New_User' 
            WHEN q1 in ('3','4') THEN '2 User'
            ELSE '3 Old_User'
         END as UserExperience
         , q7
         ,CASE 
            WHEN q7 in ('0','1') THEN '1 Low_Usage' 
            WHEN q7 in ('2','3','4') THEN '2 Moderate_Usage'
            ELSE '3 High_Usage'
         END as UsageRate
    FROM survey) a 
GROUP BY a.UserExperience, a.UsageRate
ORDER BY a.UserExperience 
		, a.UsageRate 


-- Above table with average Bookmark and tab usage layered in

SELECT a.UserExperience
	, a.UsageRate
 	, Count(DISTINCT(e.user_id) ) as NumUsers
    ,SUM(CASE
    	WHEN e.event_code = 10 THEN 1
        ELSE 0
      END) as BookmarkUse
    ,(SUM(CASE
    	WHEN e.event_code = 10 THEN 1
        ELSE 0
      END)/(Count(DISTINCT(e.user_id) ))) as AvgBookmark
   ,AVG(CASE
     	WHEN e.event_code = 26 THEN cast(replace(data2, ' tabs', '') as numeric)
        ELSE 0 
      END) as AvgTabUse
    ,MAX(CASE
    	WHEN e.event_code = 26 THEN cast(replace(data2, ' tabs', '') as numeric)
       	ELSE 0 
    END) as MaxTabUse
FROM events e
INNER JOIN 
	(
    SELECT user_id
        , q1
        ,CASE 
            WHEN q1 in ('0','1', '2') THEN '1 New_User' 
            WHEN q1 in ('3','4') THEN '2 User'
            ELSE '3 Old_User'
         END as UserExperience
         , q7
         ,CASE 
            WHEN q7 in ('0','1') THEN '1 Low_Usage' 
            WHEN q7 in ('2','3','4') THEN '2 Moderate_Usage'
            ELSE '3 High_Usage'
         END as UsageRate
    FROM survey) a 
ON e.user_id = a.user_id
GROUP BY a.UserExperience, a.UsageRate
ORDER BY a.UserExperience 
		, a.UsageRate 


-- Valdiation Check to make sure above query makes sense (max is user id 10589)
SElECT MAX(cast(replace(data2, ' tabs', '') as numeric))
	, user_id
FROM events
WHERE event_code = 26
Group BY user_id
ORDER BY max DESC

-- Validation Check to make sure above query makes sense (user id is not in survey)

SELECT *
FROM survey 
Where user_id = 10589


-- Tabs affect on Crashes

SELECT CAST(REPLACE(data2,'Tabs ','') as numeric) as TabCount
	, Count(user_id) as crashcount
FROM events
WHERE event_code = 20 and data1 != 'Windows 0' and data2 != 'Tabs 0'
GROUP BY data2
Order BY crashcount DESC

-- Average Tab Use for New Users - 6


SELECT AVG(cast(replace(data2, ' tabs', '') as numeric))
FROM events e
INNER JOIN 
	(
    SELECT user_id
        , q1
        ,CASE 
            WHEN q1 in ('0','1', '2') THEN '1 New_User' 
            WHEN q1 in ('3','4') THEN '2 User'
            WHEN q1 in ('5','6') THEN '3 Old_User'
        	ELSE 'N/A'
         END as UserExperience
/**         , q7
         ,CASE 
            WHEN q7 in ('0','1') THEN '1 Low_Usage' 
            WHEN q7 in ('2','3','4') THEN '2 Moderate_Usage'
            ELSE '3 High_Usage'
         END as UsageRate **/
    FROM survey) a 
ON e.user_id = a.user_id
WHERE a.UserExperience = '1 New_User' and event_code = 26
-- GROUP BY a.UserExperience
-- ORDER BY a.UserExperience 



-- Average Bookmark use Use for New Users - 8


SELECT (SUM(CASE
    	WHEN e.event_code = 10 THEN 1
        ELSE 0
      END)/(Count(DISTINCT(e.user_id) ))) as AvgBookmark
FROM events e
INNER JOIN 
	(
    SELECT user_id
        , q1
        ,CASE 
            WHEN q1 in ('0','1', '2') THEN '1 New_User' 
            WHEN q1 in ('3','4') THEN '2 User'
            WHEN q1 in ('5','6') THEN '3 Old_User'
        	ELSE 'N/A'
         END as UserExperience
/**         , q7
         ,CASE 
            WHEN q7 in ('0','1') THEN '1 Low_Usage' 
            WHEN q7 in ('2','3','4') THEN '2 Moderate_Usage'
            ELSE '3 High_Usage'
         END as UsageRate **/
    FROM survey) a 
ON e.user_id = a.user_id
WHERE a.UserExperience = '1 New_User' and event_code = 10
-- GROUP BY a.UserExperience
-- ORDER BY a.UserExperience 

-- average folder depth for new users

SELECT (SUM(CASE
    	WHEN e.event_code = 8 THEN CAST(REPLACE(data3, 'folder depth ','') as numeric)
        ELSE 0
      END)/(Count(DISTINCT(e.user_id) ))) as AvgBookmarkFolderDepth
      , a.UserExperience
FROM events e
INNER JOIN 
	(
    SELECT user_id
        , q1
        ,CASE 
            WHEN q1 in ('0','1', '2') THEN '1 New_User' 
            WHEN q1 in ('3','4') THEN '2 User'
            WHEN q1 in ('5','6') THEN '3 Old_User'
        	ELSE 'N/A'
         END as UserExperience
/**         , q7
         ,CASE 
            WHEN q7 in ('0','1') THEN '1 Low_Usage' 
            WHEN q7 in ('2','3','4') THEN '2 Moderate_Usage'
            ELSE '3 High_Usage'
         END as UsageRate **/
    FROM survey) a 
ON e.user_id = a.user_id
WHERE /**a.UserExperience = '1 New_User' and **/event_code = 8
GROUP BY a.UserExperience




-- events population stats

SELECT 
	Count(DISTINCT(user_id) ) as NumUsers
    ,SUM(CASE
    	WHEN event_code = 10 THEN 1
        ELSE 0
      END) as BookmarkUse
    ,(SUM(CASE
    	WHEN event_code = 10 THEN 1
        ELSE 0
      END)/(Count(DISTINCT(user_id) ))) as AvgBookmark
   ,AVG(CASE
     	WHEN event_code = 26 THEN cast(replace(data2, ' tabs', '') as numeric)
        ELSE 0 
      END) as AvgTabUse
    ,MAX(CASE
    	WHEN event_code = 26 THEN cast(replace(data2, ' tabs', '') as numeric)
       	ELSE 0 
    END) as MaxTabUse
FROM events 
-- e
/** INNER JOIN 
	(
    SELECT user_id
        , q1
        ,CASE 
            WHEN q1 in ('0','1', '2') THEN '1 New_User' 
            WHEN q1 in ('3','4') THEN '2 User'
            ELSE '3 Old_User'
         END as UserExperience
         , q7
         ,CASE 
            WHEN q7 in ('0','1') THEN '1 Low_Usage' 
            WHEN q7 in ('2','3','4') THEN '2 Moderate_Usage'
            ELSE '3 High_Usage'
         END as UsageRate
    FROM survey) a 
-- ON e.user_id = a.user_id
-- GROUP BY a.UserExperience, a.UsageRate
-- ORDER BY a.UserExperience 
		, a.UsageRate 
**/


