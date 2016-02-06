@@header

/*
*
*  Author     : Vishal Gupta
*  Purpose    : Display MRP (Managed Recovery Process) Status
*  Version    : 
*  Parameters :                
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  09-MAY-14  Vishal Gupta  Modified to display foreground MRP process as well
*  12-Feb-13  Vishal Gupta  Created
*
*/

Prompt
Prompt   *******************
Prompt   *    MRP Status
Prompt   *******************

COLUMN inst_id                 HEADING "I#"                             FORMAT 99
COLUMN SID                     HEADING "SID"                            FORMAT 99999
COLUMN process                 HEADING "Process"                        FORMAT a7
COLUMN pid                     HEADING "PID"                            FORMAT 999999
COLUMN status                  HEADING "Status"                         FORMAT a15
COLUMN delay_mins              HEADING "Delay|Mins"                     FORMAT 9999
COLUMN client_process          HEADING "Client|Process"                 FORMAT a10
COLUMN client_pid              HEADING "Client|PID"                     FORMAT a10
COLUMN machine                 HEADING "Client|Machine"                 FORMAT a10 TRUNCATE
COLUMN thread#                 HEADING "Th#"                            FORMAT 99
COLUMN sequence#               HEADING "Seq#"                           FORMAT 999999
COLUMN block#                  HEADING "Block#"                         FORMAT 99999999
COLUMN blocks                  HEADING "Blocks"                         FORMAT 99999999
COLUMN applied_log             HEADING "Current|Log|Applied|(MB)"       FORMAT 99,999
COLUMN log_size                HEADING "Log|Size|(MB)"                  FORMAT 99,999
COLUMN received_log            HEADING "Current|Logs|Received|(MB)"     FORMAT 9,999,999
COLUMN received_total          HEADING "Total|Logs|Received|(MB)"       FORMAT 9,999,999
COLUMN speed                   HEADING "Avg|Speed|(KB/s)"               FORMAT 9,999,999
COLUMN known_agents            HEADING "Known|Agents"                   FORMAT 999999
COLUMN active_agents           HEADING "Active|Agents"                  FORMAT 999999
COLUMN archlog_first_Time      HEADING "ArchLog|FirstTime"              FORMAT a18
COLUMN last_applied_redo_time  HEADING "Last Applied|Redo Time"         FORMAT a18
COLUMN active_apply_rate       HEADING "Active|Apply|Rate"              FORMAT a15

SELECT m.process
     , s.sid
     , m.inst_id
     , m.status
     , m.delay_mins
     , s.machine
     , m.thread#
     , m.sequence#
     , m.block#
     , m.blocks
     , ((m.block# - 1) * 512)/power(1024,2)    applied_log
     , (SELECT MAX((l.blocks * l.block_size)/power(1024,2) ) 
          from v$archived_log l 
        WHERE m.thread# = l.thread# AND m.sequence# = l.sequence#
        ) log_size
     , m.known_agents
     , m.active_agents
     , rp.last_applied_redo_time
     --, rp.active_apply_rate
  FROM gv$managed_standby m
       JOIN gv$process p ON m.inst_id = p.inst_id AND m.pid = p.spid
       JOIN gv$session s ON s.inst_id = p.inst_id AND s.paddr = p.addr
       JOIN (SELECT MAX(DECODE(r.item,'Last Applied Redo',TO_CHAR(r.timestamp,'DD-MON-YY HH24:MI:SS'),'')) last_applied_redo_time
                  --, MAX(DECODE(r.item,'Active Apply Rate',TRIM(TO_CHAR(r.sofar,'999,999,999,999')) || ' ' || r.units ,'')) active_apply_rate
               FROM gv$recovery_progress r
              WHERE r.start_time = (SELECT MAX(start_time) from gv$recovery_progress)
             GROUP BY r.start_Time
            ) rp ON 1=1
       --JOIN v$statname sn ON sn.name = 'bytes received via SQL*Net from client'
       --JOIN gv$sesstat ss ON ss.inst_id = s.inst_id AND ss.sid = s.sid AND sn.statistic# = ss.statistic# 
 WHERE 1=1
   AND m.process IN ('MRP0','MR(fg)')
UNION ALL
/* Sometimes MRP0 process does not move, while slave recovery process are reading older archived redo logs
   so show their process as well
 */
SELECT p.pname
     , s.sid
     , s.inst_id
	    , 'Reading'
	    , NULL
    	, s.machine
     , l2.thread#
     , l2.sequence#
--     , l2.first_Time archlog_first_Time
     , DECODE(sw.p1text, 'log#',sw.p2 ,'') block#
     , DECODE(sw.p1text, 'log#',sw.p3 ,'') blocks
    	, (sw.p2 * 512)/power(1024,2) Read_MB
	    , (l2.block_size * l2.blocks)/power(1024,2) log_size_MB
	    , NULL
	    , NULL
     , TO_CHAR(l2.first_Time,'DD-MON-YY HH24:MI:SS') archlog_first_Time
  FROM gv$session_wait sw
  JOIN gv$session s  ON s.inst_id = sw.inst_id and sw.sid = s.sid and s.program like '%'
	 JOIN gv$process p ON s.inst_id = p.inst_id and s.paddr = p.addr
	 JOIN v$archived_log l2 ON l2.sequence# = sw.p1
  	                       AND l2.first_time = (select max(first_Time) 
	                                          from v$archived_log l 
						                  where l.sequence# = sw.p1 )
where 1=1
and sw.wait_class <> 'Idle'
and sw.event = 'log file sequential read'
and s.program like '%(PR%'
;

BREAK ON REPORT    

COMPUTE SUM LABEL 'Total' OF speed           FORMAT 99,999,999   ON REPORT 
COMPUTE SUM LABEL 'Total' OF received_log    FORMAT 99,999,999   ON REPORT 
COMPUTE SUM LABEL 'Total' OF received_total  FORMAT 99,999,999   ON REPORT 

--Prompt
--Prompt   *************************
--Prompt   *  Standby Redo Logs
--Prompt   *************************

SELECT m.process
     , s.sid
     , m.inst_id
     --, m.pid
     , m.status
     --, m.client_process
     --, m.client_pid
     , s.machine
     , m.thread#
     , m.sequence#
     , m.block#
     , m.blocks
     , ((m.block# - 1) * 512)/power(1024,2)    received_log
     , (ss.value/power(1024,2))                received_total
  FROM gv$managed_standby m
       JOIN gv$process p ON m.inst_id = p.inst_id AND m.pid = p.spid
       JOIN gv$session s ON s.inst_id = p.inst_id AND s.paddr = p.addr
       JOIN v$statname sn ON sn.name = 'bytes received via SQL*Net from client'
       JOIN gv$sesstat ss ON ss.inst_id = s.inst_id AND ss.sid = s.sid AND sn.statistic# = ss.statistic# 
 WHERE 1=1
   AND m.process NOT IN ('MRP0','ARCH')
   AND m.status IN ('IDLE')
   AND m.thread# <> 0
ORDER BY m.process
       , inst_id
       , m.thread#
       , m.sequence#
;

PROMPT 
@@dg_recovery_progress

Prompt
Prompt   *******************
Prompt   *    MRP processes
Prompt   *******************
select process,status,client_process,sequence#,THREAD#,block#,active_agents,known_agents from v$managed_standby; 

@@footer