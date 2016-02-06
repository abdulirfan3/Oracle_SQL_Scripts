-- | PURPOSE  : Provides summary report on all registered components.           |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999
SET VERIFY   OFF

COLUMN comp_id    FORMAT a9    HEADING 'Component|ID'
COLUMN comp_name  FORMAT a35   HEADING 'Component|Name'
COLUMN version    FORMAT a13   HEADING 'Version'
COLUMN status     FORMAT a11   HEADING 'Status'
COLUMN modified                HEADING 'Modified'
COLUMN Schema     FORMAT a8    HEADING 'Schema'
COLUMN procedure  FORMAT a41   HEADING 'Procedure'

Prompt
prompt +------------------------------------+
prompt |     Registry (DBA_REGISTRY)        |
Prompt +------------------------------------+
prompt

SELECT
    comp_id
  , comp_name
  , version
  , status
  , modified
  , schema
  , procedure
FROM
    dba_registry;
	
Prompt
prompt +------------------------------------+
prompt |       Registry History             |
Prompt +------------------------------------+
prompt

col ACTION_TIME format a35
col comments format a35
	
select substr(action_time,1,30) action_time,
substr(id,1,8) id,
substr(action,1,10) action,
substr(version,1,8) version,
--substr(BUNDLE_SERIES,1,6) BUNDLE_SERIES,
substr(comments,1,20) comments
from sys.registry$history;
	

