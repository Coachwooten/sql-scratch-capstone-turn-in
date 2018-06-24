---1) Get familiar with CoolTShirts
---COUNT of distinct campaigns:

SELECT COUNT(DISTINCT utm_campaign) AS 'Campaign Count'
FROM page_visits;

---COUNT of distinct sources:
SELECT COUNT(DISTINCT utm_source) AS 'Source Count'
FROM page_visits;

---Sources per campaign:
SELECT DISTINCT utm_campaign AS Campaign, utm_source AS Source
FROM page_visits;

---Distinct Page Names:
SELECT DISTINCT page_name AS 'Page Names'
FROM page_visits;

---2.1 COUNT first touches per campaign
---Create temporary table that finds first
---touches by user ID:
WITH first_touch AS (
	SELECT user_id,
	MIN(timestamp) AS first_touch_time
FROM page_visits
GROUP BY user_id),
---Create 2nd temporary table that adds
---source and campaign data from the
---page_visits table, joining on user
---ID and timestamp:
ft_attr AS (
  SELECT ft.user_id,
         ft.first_touch_time,
         pv.utm_source,
         pv.utm_campaign
  FROM first_touch ft
  JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_time = pv.timestamp
)
---The below select statement counts the number
---of records from the above temporary table,
---which has been designed to get a reliable count
---of unique records (by user ID) that represent the
---number of first touches for each campaign (and by definition, source.)
SELECT ft_attr.utm_source AS Source,
       ft_attr.utm_campaign AS Campaign,
       COUNT(*) AS Count
FROM ft_attr
GROUP BY 1, 2
ORDER BY 3 DESC;

---Count last touches per campaign
---Create temporary table that returns last touches
---by user ID:
WITH last_touch AS (
 SELECT user_id,
		MAX(timestamp) AS last_touch_at
 FROM page_visits
 GROUP BY user_id),
---Create 2nd temporary table that adds
---source and campaign data from the
---page_visits table, joining on user
---ID and timestamp:
lt_attr AS (
  SELECT lt.user_id,
         lt.last_touch_at,
         pv.utm_source,
         pv.utm_campaign,
         pv.page_name
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
---The below select statement counts the number
---of records from the above temporary table,
---which has been designed to get a reliable count
---of unique records (by user ID) that represent the
---number of last touches for each campaign (and by definition, source.)
SELECT lt_attr.utm_source AS Source,
       lt_attr.utm_campaign AS Campaign,
       COUNT(*) AS Count
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;

---Count the distinct users who end up making a purchase:
SELECT COUNT(DISTINCT user_id) AS 'Purchasing Customer Count'
FROM page_visits
WHERE page_name = '4 - purchase';


---Count last touches per campaign that led to a purchase
---Create temporary table that returns last touches
---by user ID:
WITH last_touch AS (
 SELECT user_id,
		MAX(timestamp) AS last_touch_at
 FROM page_visits
 ---add WHERE clause to narrow results to purchase page only
 	WHERE page_name = '4 - purchase'
 GROUP BY user_id),
---Create 2nd temporary table that adds
---source and campaign data from the
---page_visits table, joining on user
---ID and timestamp:
lt_attr AS (
  SELECT lt.user_id,
         lt.last_touch_at,
         pv.utm_source,
         pv.utm_campaign,
         pv.page_name
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
---The below select statement counts the number
---of records from the above temporary table,
---which has been designed to get a reliable count
---of unique records (by user ID) that represent the
---number of last touches for each campaign (and by definition, source.)
SELECT lt_attr.utm_source AS Source,
       lt_attr.utm_campaign AS Campaign,
       COUNT(*) AS Count
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;