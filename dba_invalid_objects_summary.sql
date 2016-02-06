-- | PURPOSE  : Provides a summary report of all invalid objects in the         |
-- |            database.                                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE  9999

clear columns
clear breaks
clear computes

column owner           format a25         heading 'Owner'
column object_name     format a30         heading 'Object Name'
column object_type     format a20         heading 'Object Type'
column count           format 999,999     heading 'Count'

break on owner skip 2 on report
compute sum   label "Count: "        of count on owner
compute sum   label "Grand Total: "  of count on report

SELECT
    owner
  , object_type
  , count(*) Count
FROM dba_objects
WHERE status <> 'VALID'
GROUP BY owner, object_type
/


