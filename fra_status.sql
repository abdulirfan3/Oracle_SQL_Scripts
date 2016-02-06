-- | PURPOSE  : Provide an overview of the Oracle Flash Recovery Area.          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999

COLUMN name               FORMAT a30                  HEADING 'Name'
COLUMN space_limit        FORMAT 99,999,999,999,999   HEADING 'Space Limit'
COLUMN space_used         FORMAT 99,999,999,999,999   HEADING 'Space Used'
COLUMN space_used_pct     FORMAT 999.99               HEADING '% Used'
COLUMN space_reclaimable  FORMAT 99,999,999,999,999   HEADING 'Space Reclaimable'
COLUMN pct_reclaimable    FORMAT 999.99               HEADING '% Reclaimable'
COLUMN number_of_files    FORMAT 999,999              HEADING 'Number of Files'


prompt 
prompt Current location, disk quota, space in use, space reclaimable by deleting files,
prompt and number of files in the Flash Recovery Area.
prompt 

SELECT
    name
  , space_limit/1024/1024 "space_limit"
  , space_used/1024/1024  "space_used"
  , ROUND((space_used / space_limit)*100, 2) space_used_pct
  , space_reclaimable/1024/1024 "space_reclaimable"
  , ROUND((space_reclaimable / space_limit)*100, 2) pct_reclaimable
  , number_of_files
FROM
    v$recovery_file_dest
ORDER BY
    name
/


COLUMN file_type                  FORMAT a30     HEADING 'File Type'
COLUMN percent_space_used                        HEADING 'Percent Space Used'
COLUMN percent_space_reclaimable                 HEADING 'Percent Space Reclaimable'
COLUMN number_of_files            FORMAT 999,999 HEADING 'Number of Files'

SELECT
    file_type
  , percent_space_used
  , percent_space_reclaimable
  , number_of_files
FROM
    v$flash_recovery_area_usage
/

