-- | PURPOSE  : Reports on all hidden "undocumented" database parameters. You   |
-- |            must be connected as the SYS user to run this script.           |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

Prompt
prompt +--------------------------------------+
prompt |    Should be ran by sysdba user      |
Prompt +--------------------------------------+
prompt

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN ksppinm   FORMAT A42   HEAD 'Parameter Name'
COLUMN ksppstvl  FORMAT A39   HEAD 'Value'
COLUMN ksppdesc  FORMAT A60   HEAD 'Description'    TRUNC


SELECT
    ksppinm
  , ksppstvl
  , ksppdesc
FROM
    x$ksppi x
  , x$ksppcv y
WHERE
      x.indx = y.indx 
  AND TRANSLATE(ksppinm,'_','#') like '#%'
  and ksppinm LIKE NVL('%&parameter_name%', ksppinm);
