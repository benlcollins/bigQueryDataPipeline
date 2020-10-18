/* 
 * BigQuery SQL Reference 
 *
 * Find & Delete Duplicate Rows
 *
 */

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
