/* 
 * BigQuery SQL Reference 
 *
 * Delete Specific Rows
 *
 */

-- delete rows where user name is TEST
DELETE
FROM `PROJECT_ID.DATASET_ID.TABLE_ID`
WHERE user_name = 'TEST'