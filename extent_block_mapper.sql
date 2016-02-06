-- | PURPOSE  : Report on all USED and FREE SPACE within a tablespace. This is  |
-- |            a good script to report on tablespace fragmentation.            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999
SET VER      off

COLUMN owner       FORMAT a15         HEADING "Owner"
COLUMN object      FORMAT a20         HEADING "Object"
COLUMN file_id                        HEADING "File ID"
COLUMN block_id                       HEADING "Block ID"
COLUMN bytes       FORMAT 999,999,999 HEADING "Bytes"

PROMPT
PROMPT ****************************************************
PROMPT ****** RUNNING THIS SCRIPT CAN TAKE LONG TIME AS ***
PROMPT ******       IT QUERY DBA_EXTENTS                ***
PROMPT ****************************************************
PROMPT

ACCEPT tbs prompt 'Enter Tablespace Name : '
SELECT
    SUBSTR(owner, 1, 20)  "Owner"
  , SUBSTR(segment_name, 1, 32) "Segment_name"
  , segment_type    "Segment_type"
  , file_id
  , block_id
  , bytes/1024/1024  "Mbytes"
FROM
  dba_extents
WHERE
  tablespace_name = UPPER('&tbs') and
  file_id = '&file_id'
ORDER BY 5
/