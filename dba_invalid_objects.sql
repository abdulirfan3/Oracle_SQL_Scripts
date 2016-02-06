-- | PURPOSE  : Provide a detailed report of all invalid objects in the         |
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
column status          format a10         heading 'Status'

break on owner skip 2 on report
compute count label ""               of object_name on owner
compute count label "Grand Total: "  of object_name on report

SELECT
    owner
  , object_name
  , object_type
  , status
FROM dba_objects
WHERE status <> 'VALID'
ORDER BY owner, object_name
/


