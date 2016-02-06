@@header

set term off
/*
*
*  Author  : Vishal Gupta
*  Purpose : Display Tablespace usage
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  05-Aug-04  Vishal Gupta  First Draft
*/
set term on

COLUMN parameter  HEADING "Parameter" FORMAT a25 ON
COLUMN Database  HEADING "Database" FORMAT a30 ON
COLUMN Instance  HEADING "Instance" FORMAT a30 ON
COLUMN Sesssion  HEADING "Sesssion" FORMAT a30 ON

SELECT ndp.parameter
     , max(ndp.value) Database
     , max(nip.value) Instance
     , max(nsp.value) Sesssion
FROM nls_session_parameters nsp
FULL OUTER JOIN nls_instance_parameters nip ON nip.parameter = nsp.parameter
FULL OUTER JOIN nls_database_parameters ndp ON ndp.parameter = nsp.parameter
group by ndp.parameter  
ORDER BY parameter
;

@@footer
