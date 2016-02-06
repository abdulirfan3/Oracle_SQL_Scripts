@@header
/*
*
*  Author    : Vishal Gupta
*  Purpose   : Display archivelog gap
*  Parameter : 1 - Thread Number  (Default '%')
*              2 - From Sequence  (Default '%')
*              3 - To Sequence    (Default '%')
*  
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  17-SEP-14  Vishal Gupta  Added logic to display 'FETCHING', when file is being fetched current via RFS.
*  04-FEB-14  Vishal Gupta  Made output changes
*  04-Apr-10  Vishal Gupta  Created
*  
*/


/************************************
*  INPUT PARAMETERS
************************************/
--DEFINE thread="&&1"
--DEFINE from_sequence="&2"
--DEFINE to_sequence="&3"

set term off
COLUMN  _thread               NEW_VALUE  thread                NOPRINT
COLUMN  _from_sequence        NEW_VALUE  from_sequence         NOPRINT
COLUMN  _to_sequence          NEW_VALUE  to_sequence           NOPRINT

SELECT DECODE('&&thread','','%','&&thread')                   "_thread"
     , DECODE('&&from_sequence','','%','&&from_sequence')     "_from_sequence"
     , DECODE('&&to_sequence','','%','&&to_sequence')         "_to_sequence"
FROM DUAL;
set term on


/************************************
*  M A I N   S C R I P T
************************************/

COLUMN thread#           HEADING  "T#"                FORMAT 999
COLUMN sequence#         HEADING  "SEQ#"              FORMAT 99999999
COLUMN applied           HEADING  "APPLIED"           FORMAT a3
COLUMN FIRST_TIME        HEADING  "FIRST_TIME"        FORMAT a20
COLUMN NEXT_TIME         HEADING  "NEXT_TIME"         FORMAT a20
COLUMN COMPLETION_TIME   HEADING  "COMPLETION_TIME"   FORMAT a20
COLUMN size_mb           HEADING  "SIZE_MB"           FORMAT 99,999
COLUMN delay_in_shipping HEADING  "Delay in Shipping" FORMAT a20

/*
* Not using WITH clause (aka CTE aka sub-query refactor'ing
*  , as it does not work on standby database in MOUNT mode and only works in OPEN mode.
*/

select minmax.thread#
     , i.sequence# + minmax.min_sequence# - 1 sequence#
     --, l.thread#
     --, l.sequence# 
     , l.applied
     , l.deleted
     , l.status
     , l.archived
     , NVL(TO_CHAR(l.first_time,'DD-MON-YY HH24:MI:SS'),NVL2(m.sequence#,'   Fetching   ','   Missing    ')) first_time
     , TO_CHAR(l.next_time,'DD-MON-YY HH24:MI:SS')                        next_time
     , ROUND((l.blocks * l.block_size)/power(1024,2))                     size_mb
     , l.fal
     , l.creator
     , l.registrar
     , TO_CHAR(l.completion_time,'DD-MON-YY HH24:MI:SS')                  completion_time
     ,     LPAD(FLOOR(l.completion_time-l.next_time)                             ,2) || 'd ' 
        || LPAD(FLOOR(MOD((l.completion_time-l.next_time)      ,1) * 24 ),2) || 'h ' 
        || LPAD(FLOOR(MOD((l.completion_time-l.next_time)*24   ,1) * 60 ),2) || 'm ' 
        || LPAD(FLOOR(MOD((l.completion_time-l.next_time)*24*60,1) * 60 ),2) || 's' delay_in_shipping
from (select rownum  sequence# 
      from dual 
      connect by level  <= 1500
     )  i
     join (select l2.dest_id
                , l2.thread#
         , DECODE('&&from_sequence','%',max(DECODE(l2.applied, 'YES',l2.sequence#,0)) - 3,'&&from_sequence')   min_sequence#
         , max(l2.sequence#) max_sequence#
         --, min(l2.first_time)
         --, max(l2.first_time) 
      From v$archived_log l2
     where l2.dest_id = 1 
       AND l2.thread# like '&&thread'
     group by l2.dest_id, l2.thread# 
     order by l2.thread#
    ) minmax on 1 = 1 
     LEFT OUTER JOIN v$archived_log l on l.thread# = minmax.thread# and l.sequence# = i.sequence# + minmax.min_sequence# - 1 
     LEFT OUTER JOIN gv$managed_standby m ON m.process in ('RFS') and m.thread# = minmax.thread# AND m.sequence# = i.sequence# + minmax.min_sequence# - 1 
WHERE 1=1
  --AND (l.thread# IS  NULL OR l.sequence# IS  NULL)
  and i.sequence# + minmax.min_sequence# - 1 <=  minmax.max_sequence# 
  and l.status = 'A'
  AND minmax.thread# like '&&thread'
  AND i.sequence# + minmax.min_sequence# - 1 
         BETWEEN DECODE('&&from_sequence','%',minmax.min_sequence#,'&&from_sequence') 
             AND DECODE('&&to_sequence','%',minmax.max_sequence#,'&&to_sequence') 
order by minmax.thread#
        , i.sequence#
--order by l.first_change#
;


SELECT l.thread#
     , TO_CHAR(sysdate,'DD-MON-YY HH24:MI:SS')           current_time
     , TO_CHAR(max(l.next_time) ,'DD-MON-YY HH24:MI:SS') max_next_time
  FROM v$archived_log l
GROUP BY l.thread#
ORDER BY l.thread#
;


@@footer