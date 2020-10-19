/* 
 * Teachable Data Analysis Project in BigQuery
 * Ben Collins, 2020
 *
 */

/* COURSE ANALYSIS */

-- course completions count
SELECT course_name, COUNT(course_name) AS completions
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
GROUP BY course_name
ORDER BY completions DESC;

-- course completions as a % of total, all time
SELECT 
  course_name
  , COUNT(course_name) AS num_lecture_completions
  , ROUND(COUNT(course_name) * 100 / (SELECT COUNT(1) FROM `PROJECT_ID.DATASET_ID.TABLE_ID`),2) AS percent_of_total
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
GROUP BY course_name
ORDER BY num_lecture_completions DESC;


/* LECTURE ANALYSIS */

-- lecture completions count
SELECT course_name,lecture_name, COUNT(lecture_name) AS completions
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
GROUP BY course_name,lecture_name
ORDER BY completions DESC;

-- How many lecture completions for each course in a 24 hr window?
SELECT course_name, COUNT(lecture_name) AS completions
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
-- following WHERE doesn't work because cannot compare TIMESTAMP and DATE
-- WHERE created > DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) 
-- need to cast timestamp as a date to do the comparison
WHERE CAST(created AS DATE) > DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY) -- need to use interval 2 day because this table is 1 day behind
GROUP BY course_name
ORDER BY completions DESC;

-- How many lecture completions for each course in a 7-day window? 
SELECT course_name, COUNT(lecture_name) AS completions
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
WHERE CAST(created AS DATE) > DATE_SUB(CURRENT_DATE(), INTERVAL 8 DAY) -- need to use interval 8 day because this table is 1 day behind
GROUP BY course_name
ORDER BY completions DESC;

-- How many lecture completions for each course in a 30-day window?
SELECT course_name, COUNT(lecture_name) AS completions
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
WHERE CAST(created AS DATE) > DATE_SUB(CURRENT_DATE(), INTERVAL 31 DAY) -- need to use interval 31 day because this table is 1 day behind
GROUP BY course_name
ORDER BY completions DESC;

-- lecture completions as a % all time
SELECT 
  course_name
  , lecture_name
  , COUNT(lecture_name) AS lecture_completions
  , ROUND(COUNT(lecture_name) * 100 / (SELECT COUNT(1) FROM `PROJECT_ID.DATASET_ID.TABLE_ID`),2) AS percent_of_total
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
GROUP BY course_name, lecture_name
ORDER BY lecture_completions DESC;

-- lecture completions as a % Last 24 hours
SELECT 
  course_name
  , lecture_name
  , COUNT(lecture_name) AS lecture_completions
  , ROUND(COUNT(lecture_name) * 100 / (SELECT COUNT(1) FROM `PROJECT_ID.DATASET_ID.TABLE_ID`),2) AS percent_of_total
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
WHERE CAST(created AS DATE) > DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)
GROUP BY course_name, lecture_name
ORDER BY lecture_completions DESC;

-- lecture completions as a % Last 7 days
SELECT 
  course_name
  , lecture_name
  , COUNT(lecture_name) AS lecture_completions
  , ROUND(COUNT(lecture_name) * 100 / (SELECT COUNT(1) FROM `PROJECT_ID.DATASET_ID.TABLE_ID`),2) AS percent_of_total
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
WHERE CAST(created AS DATE) > DATE_SUB(CURRENT_DATE(), INTERVAL 8 DAY)
GROUP BY course_name, lecture_name
ORDER BY lecture_completions DESC;

-- lecture completions as a % Last 30 days
SELECT 
  course_name
  , lecture_name
  , COUNT(lecture_name) AS lecture_completions
  , ROUND(COUNT(lecture_name) * 100 / (SELECT COUNT(1) FROM `PROJECT_ID.DATASET_ID.TABLE_ID`),2) AS percent_of_total
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
WHERE CAST(created AS DATE) > DATE_SUB(CURRENT_DATE(), INTERVAL 31 DAY)
GROUP BY course_name, lecture_name
ORDER BY lecture_completions DESC;

-- What are the most popular times to complete lectures?
-- create a histogram of lesson completion times by hour
SELECT
  lecture_hour
  , COUNT(lecture_name) AS lecture_completions
FROM (
  SELECT 
    EXTRACT(HOUR FROM created) AS lecture_hour
    , lecture_name
  FROM 
    `PROJECT_ID.DATASET_ID.TABLE_ID`
)
GROUP BY lecture_hour
ORDER BY lecture_hour ASC;

-- use the REPEAT function to add a chart
SELECT
  lecture_hour
  , COUNT(lecture_name) AS lecture_completions
  , REPEAT('#', COUNT(lecture_name)) AS chart
FROM (
  SELECT 
    EXTRACT(HOUR FROM created) AS lecture_hour
    , lecture_name
  FROM 
    `PROJECT_ID.DATASET_ID.TABLE_ID`
)
GROUP BY lecture_hour
ORDER BY lecture_hour ASC;


-- first approach using the approx_quartiles function
-- not working yet...
SELECT 
  APPROX_QUANTILES(EXTRACT(HOUR FROM created),24) AS lecture_hour
  , COUNT(lecture_name)
FROM 
  `PROJECT_ID.DATASET_ID.TABLE_ID`;
--LIMIT 10;
--WHERE CAST(created AS DATE) > DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY);


/* STUDENT ANALYSIS */

-- student summary
SELECT user_name, user_email, COUNT(lecture_name) AS completions
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
GROUP BY user_name, user_email
ORDER BY completions DESC;
