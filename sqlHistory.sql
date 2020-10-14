/* SQL Query History */


/* Exploring courses & lessons */

-- what are the most popular courses
SELECT 
  course_name
  , COUNT(course_name) AS num_lecture_completions
  , ROUND(COUNT(course_name) * 100 / (SELECT COUNT(1) FROM `PROJECT_ID.DATASET_ID.TABLE_ID`),2) AS percent_of_total
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
GROUP BY course_name
ORDER BY num_lecture_completions DESC

-- what are the most popular lectures
SELECT 
  course_name
  , lecture_name
  , COUNT(lecture_name) AS lecture_completions
  , ROUND(COUNT(lecture_name) * 100 / (SELECT COUNT(1) FROM `PROJECT_ID.DATASET_ID.TABLE_ID`),2) AS percent_of_total
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
GROUP BY course_name, lecture_name
ORDER BY course_name,lecture_completions DESC


/* Data Management */

-- change column type in BigQuery
-- More > Query Settings
-- Set destination table for query results
-- Overwrite existing table
-- Be careful! You may be better to create a new table
SELECT 
  * EXCEPT(object_user_confirmed_at),
  CAST(object_user_confirmed_at AS timestamp) AS object_user_confirmed_at
 FROM 
  `PROJECT_ID.DATASET_ID.TABLE_ID`


-- delete duplicate rows
-- Step 1: determine if duplicates exist
SELECT (
  SELECT 
    COUNT(1)
  FROM (
    SELECT DISTINCT 
      *
    FROM
    `PROJECT_ID.DATASET_ID.TABLE_ID`
  )
) AS distinct_rows,
(
  SELECT 
    COUNT(1) 
  FROM
    `PROJECT_ID.DATASET_ID.TABLE_ID`
) AS total_rows

-- Step 2: return unique rows
-- More > Query Settings
-- Set destination table for query results
-- Overwrite existing table
-- Be careful! You may be better to create a new table
SELECT DISTINCT *
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
