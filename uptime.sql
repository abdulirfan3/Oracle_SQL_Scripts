@@header

/*
*
*  Author     : Vishal Gupta
*  Purpose    : Display startup time for all instances
*  Parameters : NONE
*               
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  11-May-12  Vishal Gupta  Intial version
*
*/

PROMPT
PROMPT
PROMPT ***********************************************************************
PROMPT *  I N S T A N C E    U P T I M E    H I S T O R Y
PROMPT ***********************************************************************

COLUMN startup_time                HEADING "Startup Time"               FORMAT a18
COLUMN db_name                     HEADING "DB Name"                    FORMAT a8
COLUMN instance_number             HEADING "I#"                         FORMAT 99
COLUMN instance_name               HEADING "Instance|Name"              FORMAT a10
COLUMN host_name                   HEADING "Host Name"                  FORMAT a40
COLUMN platform_name               HEADING "Platform Name"              FORMAT a25


SELECT to_char(i.startup_time ,'DD-MON-YY HH24:MI:SS') startup_time
     , i.db_name
     , i.instance_number
     , i.instance_name
     , i.host_name
  &&_IF_ORA_11gR1_OR_HIGHER   , i.platform_name
  FROM dba_hist_database_instance i
     , v$database d
 WHERE d.dbid = i.dbid
ORDER BY i.startup_time desc  
;

PROMPT
PROMPT
PROMPT ***********************************************************************
PROMPT *  I N S T A N C E    U P T I M E
PROMPT ***********************************************************************

COLUMN Inst_id                      HEADING "I#"                FORMAT 99
COLUMN instance_name                HEADING "Instance|Name"     FORMAT a10 
COLUMN status                       HEADING "Instance|Status"   FORMAT a10 
COLUMN host_name                    HEADING "Hostname"          FORMAT a15 TRUNCATE
COLUMN startup_time                 HEADING "StartupTime"       FORMAT a18 
COLUMN uptime1                      HEADING "Uptime|(Days)"     FORMAT 9999 JUSTIFY RIGHT
COLUMN uptime2                      HEADING "Uptime"            FORMAT a18 JUSTIFY RIGHT

select inst_id
     , instance_name
     , SUBSTR(host_name,1,DECODE(instr(host_name,'.'),0,LENGTH(host_name),instr(host_name,'.')-1)) host_name
     , to_char(startup_time,'DD-MON-YY HH24:MI:SS') startup_time 
     --, ROUND(sysdate - startup_time, 2) uptime1
     ,    LPAD(FLOOR(sysdate - startup_time) || 'd '
       || LPAD(FLOOR(MOD((sysdate - startup_time) , 1) * 24 ) ,2) || 'h '
       || LPAD(FLOOR(MOD((sysdate - startup_time) * 24 , 1) * 60 ) ,2) || 'm '
       || LPAD(FLOOR(MOD((sysdate - startup_time) * 24 * 60 , 1) * 60 ) ,2) || 's'
       , 18) uptime2
from gv$instance order by 1;


@@footer
