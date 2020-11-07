/* 
 * Teachable Data Analysis Project in BigQuery
 * Ben Collins, 2020
 *
 * Remember to switch all IDs to your own in:
 * PROJECT_ID.DATASET_ID.TABLE_ID
 *
 */

/* BASE QUERIES FOR ID REFERENCE */
SELECT * FROM `PROJECT_ID.DATASET_ID.TABLE_ID` LIMIT 10;
SELECT * FROM `PROJECT_ID.DATASET_ID.TABLE_ID` LIMIT 10;
SELECT * FROM `PROJECT_ID.DATASET_ID.TABLE_ID` LIMIT 10;

/* COURSE ANALYSIS */

-- course enrollments, all time, with %
SELECT 
  course_name
  , COUNT(course_name) AS completions
  , ROUND(COUNT(course_name) * 100 / (SELECT COUNT(1) FROM `PROJECT_ID.DATASET_ID.TABLE_ID`),2) AS percent_of_total
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
GROUP BY course_name
ORDER BY completions DESC;


-- course lecture completions count
SELECT course_name, COUNT(course_name) AS lecture_completions
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
GROUP BY course_name
ORDER BY lecture_completions DESC;

-- course lecture completions as a % of total, all time
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


-- how many courses has a student signed up for
SELECT 
  user_email
  , COUNT(course_name) AS signups
FROM 
  `PROJECT_ID.DATASET_ID.TABLE_ID`
GROUP BY
  user_email
ORDER BY
  signups DESC;


-- How many students sign up but don't take a lecture?
-- Identify this group to send a bump email

-- query 1: student enrollments
SELECT 
  user_email
  , course_name 
FROM 
  `PROJECT_ID.DATASET_ID.TABLE_ID`;

-- query 2: student lecture completions
SELECT
  user_email
  , user_name
  , course_name
  , COUNT(lecture_name) AS completions
FROM 
  `PROJECT_ID.DATASET_ID.TABLE_ID`
GROUP BY
  user_email
  , user_name
  , course_name
ORDER BY 
  user_email
  , completions DESC;

-- query 3: join
-- students from query 1 who do not appear in query 2 
-- this is a list of students who enrolled but haven't taken a lecture yet
SELECT
  t1.user_email
  , t1.course_name
FROM
  `PROJECT_ID.DATASET_ID.TABLE_ID_1` AS t1
LEFT JOIN 
  `PROJECT_ID.DATASET_ID.TABLE_ID_2` AS t2
ON
  t1.user_email = t2.user_email
WHERE t2.user_email IS NULL;

-- next question
-- how long would be a reasonable window to wait?
-- if no engagement within 10 days, send a bump email
-- filter out people with signup date < 10 days ago
SELECT
  t1.user_email
  , t1.course_name
  , t1.enrollment_enrolled_at
FROM
  `PROJECT_ID.DATASET_ID.TABLE_ID_1` AS t1
LEFT JOIN 
  `PROJECT_ID.DATASET_ID.TABLE_ID_2` AS t2
ON
  t1.user_email = t2.user_email
WHERE 
  t2.user_email IS NULL
  AND CAST(t1.enrollment_created_at AS DATE) < DATE_SUB(current_date(),INTERVAL 10 DAY);


/* TRANSACTIONS DATA */

-- What are the most popular times to Purchase courses?



/* MailChimp List Growth versus Teachable Enrollments */
-- how do these two numbers compare?
SELECT
  mc.weekday,
  mc.date AS mc_date,
  DATE(te.enrollment_enrolled_at) AS te_date,
  mc.growth AS list_growth,
  COUNT(user_email) AS enrollments
FROM
  `PROJECT_ID.DATASET_ID.TABLE_ID_1` AS mc
JOIN
  `PROJECT_ID.DATASET_ID.TABLE_ID_2` AS te
ON
  mc.date = DATE(te.enrollment_enrolled_at)
GROUP BY
  mc.weekday,
  mc.date,
  te_date,
  mc.growth
ORDER BY
  mc.date DESC;
