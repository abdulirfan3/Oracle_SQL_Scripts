-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Prompt the user for a query string and look for any object that |
-- |            contains that string.                                           |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999

COLUMN owner           FORMAT A15    HEADING "Owner"
COLUMN object_name     FORMAT A35    HEADING "Object Name"
COLUMN object_type     FORMAT A18    HEADING "Object Type"
COLUMN created                       HEADING "Created"
COLUMN status                        HEADING "Status"


ACCEPT sch prompt 'Enter Search String (i.e. table name or view name) : '
ACCEPT owner prompt 'Enter owner name or hit enter to search all user : '

SELECT
    owner
  , object_name
  , object_type
  , TO_CHAR(created, 'DD-MON-YYYY HH24:MI:SS') created
  , LPAD(status, 7) status
FROM all_objects
WHERE object_name like UPPER('%&sch%')
and
owner like upper(nvl('%&owner%',owner))
ORDER BY owner, object_name, object_type
/