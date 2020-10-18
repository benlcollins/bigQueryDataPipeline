/* 
 * BigQuery SQL Reference 
 *
 * Change Column Type
 *
 */

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