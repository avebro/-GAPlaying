

# Are we missing any data assuminig ID is sequential? 
	# Based on the below query it looks like we are missing about 69 entries (have to count id 0) 
Select 
	MAX(id)
    , Min(id) 
    , count(id)
    , (max(id)-count(id))
   
FROM users

# Unique OS 
SELECT 
	DISTINCT os 
FROM users
ORDER BY os


-- users who did not take the survey

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
-- GROUP BY user_id
ORDER BY NumberOfBookmarks DESC





-- How many users are creating bookmarks? 988
SELECT COUNT(DISTINCT(user_id)) as "UsersWhoCreatedBookmark"
FROM events
WHERE event_code in (9) and data1 = 'New Bookmark Added'

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





