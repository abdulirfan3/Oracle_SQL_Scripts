----------------------------------------------------------------------------------------
--
-- File name:   planx.sql
--
-- Purpose:     Reports Execution Plans for one SQL_ID from RAC and AWR(opt)
--
-- Author:      Carlos Sierra
--
-- Version:     2013/10/15
--
-- Usage:       This script inputs two parameters. Parameter 1 is a flag to specify if
--              your database is licensed to use the Oracle Diagnostics Pack or not.
--              Parameter 2 specifies the SQL_ID for which you want to report all
--              execution plans from all nodes, plus all plans from AWR.
--              If you don't have the Oracle Diagnostics Pack license, or if you want
--              to omit the AWR portion then specify "N" on Parameter 1.
--
-- Example:     @planx.sql Y f995z9antmhxn
--
--  Notes:      Developed and tested on 11.2.0.3 and 12.0.1.0
--              For a more robust tool use SQLHC or SQLTXPLAIN(SQLT) from MOS
--             
---------------------------------------------------------------------------------------
--
SET FEED OFF VER OFF LIN 2000 PAGES 50000 TIMI OFF LONG 40000 LONGC 200 TRIMS ON AUTOT OFF;
PRO
--PRO 1. Enter Oracle Diagnostics Pack License Flag [ Y | N ] (required)
DEF input_license = 'Y';
--PRO
PRO Enter SQL_ID (required)
DEF sql_id = '&2';
-- set license
VAR license CHAR(1);
BEGIN
  SELECT UPPER(SUBSTR(TRIM('&input_license.'), 1, 1)) INTO :license FROM DUAL;
END;
/
-- get dbid
VAR dbid NUMBER;
BEGIN
  SELECT dbid INTO :dbid FROM v$database;
END;
/
-- spool and sql_text
SPO C:\oracle\sql\spool\planx\planx_&&sql_id..txt;
PRO SQL_ID: &&sql_id.
SET PAGES 0;
SELECT sql_fulltext FROM gv$sqlstats WHERE sql_id = '&&sql_id.' AND ROWNUM = 1;
SET PAGES 50000;
-- columns format
COL is_shareable FOR A12;
COL loaded FOR A6;
COL executions FOR A20;
COL rows_processed FOR A20;
COL buffer_gets FOR A20;
COL disk_reads FOR A20;
COL direct_writes FOR A20;
COL elsapsed_secs FOR A18;
COL cpu_secs FOR A18;
COL user_io_wait_secs FOR A18;
COL cluster_wait_secs FOR A18;
COL appl_wait_secs FOR A18;
COL conc_wait_secs FOR A18;
COL plsql_exec_secs FOR A18;
COL java_exec_secs FOR A18;
COL io_cell_offload_eligible_bytes FOR A30;
COL io_interconnect_bytes FOR A30;
COL io_saved FOR A8;
set termout off;
PRO
PRO GV$SQLSTATS (ordered by inst_id)
PRO ~~~~~~~~~~~
SELECT inst_id, 
       LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets,
       LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elsapsed_secs,
       LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs
	  ,
       LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       CASE 
         WHEN io_cell_offload_eligible_bytes > io_interconnect_bytes THEN
           LPAD(TO_CHAR(ROUND(
           (io_cell_offload_eligible_bytes - io_interconnect_bytes) * 100 / io_cell_offload_eligible_bytes
           , 2), '990.00')||' %', 8) END io_saved
  FROM gv$sqlstats
WHERE sql_id = '&&sql_id.'
ORDER BY 1;
PRO
PRO GV$SQLSTATS_PLAN_HASH (ordered by inst_id and plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~~~~~
SELECT inst_id, plan_hash_value,
       LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets,
       LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elsapsed_secs,
       LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs
	   ,
       LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       CASE 
         WHEN io_cell_offload_eligible_bytes > io_interconnect_bytes THEN
           LPAD(TO_CHAR(ROUND(
           (io_cell_offload_eligible_bytes - io_interconnect_bytes) * 100 / io_cell_offload_eligible_bytes
           , 2), '990.00')||' %', 8) END io_saved
		  FROM gv$sqlstats_plan_hash
WHERE sql_id = '&&sql_id.'
ORDER BY 1, 2;
PRO
PRO GV$SQL (ordered by inst_id and child_number)
PRO ~~~~~~
SELECT inst_id, child_number, plan_hash_value, is_shareable, 
       DECODE(loaded_versions, 1, 'Y', 'N') loaded, 
       LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets,
       LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elsapsed_secs,
       LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs
	   ,
       LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       CASE 
         WHEN io_cell_offload_eligible_bytes > io_interconnect_bytes THEN
           LPAD(TO_CHAR(ROUND(
           (io_cell_offload_eligible_bytes - io_interconnect_bytes) * 100 / io_cell_offload_eligible_bytes
           , 2), '990.00')||' %', 8) END io_saved
		     FROM gv$sql
WHERE sql_id = '&&sql_id.'
ORDER BY 1, 2;
PRO       
PRO GV$SQL_PLAN_STATISTICS_ALL LAST (ordered by inst_id and child_number)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
COL inst_child FOR A21;
BREAK ON inst_child SKIP 2;
SET PAGES 0;
WITH v AS (
SELECT /*+ MATERIALIZE */
       sql_id, inst_id, child_number
  FROM gv$sql
WHERE sql_id = '&&sql_id.'
   AND loaded_versions > 0
ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) */
       RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child, 
       t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS LAST', 
       'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t;
set head on;
set pages 60;	   
PRO
PRO DBA_HIST_SQLSTAT TOTAL (ordered by snap_id, instance_number and plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~~~~~~
SELECT s.snap_id, 
       TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD DY HH24:MI:SS') begin_interval_time,
       TO_CHAR(s.end_interval_time, 'YYYY-MM-DD DY HH24:MI:SS') end_interval_time,
       s.instance_number, h.plan_hash_value,
       DECODE(h.loaded_versions, 1, 'Y', 'N') loaded, 
       LPAD(TO_CHAR(h.executions_total, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(ROUND(h.elapsed_time_total/1e6, 3), '999,999,990.000'), 18) elsapsed_secs,
       LPAD(TO_CHAR(h.rows_processed_total, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(h.buffer_gets_total, '999,999,999,999,990'), 20) buffer_gets, 
       LPAD(TO_CHAR(h.disk_reads_total, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(h.direct_writes_total, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(h.cpu_time_total/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(h.iowait_total/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(h.clwait_total/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(h.apwait_total/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(h.ccwait_total/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(h.plsexec_time_total/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(h.javexec_time_total/1e6, 3), '999,999,990.000'), 18) java_exec_secs
	   ,
       LPAD(TO_CHAR(h.io_offload_elig_bytes_total, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       LPAD(TO_CHAR(h.io_interconnect_bytes_total, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       CASE 
         WHEN h.io_offload_elig_bytes_total > h.io_interconnect_bytes_total THEN
           LPAD(TO_CHAR(ROUND(
           (h.io_offload_elig_bytes_total - h.io_interconnect_bytes_total) * 100 / h.io_offload_elig_bytes_total
           , 2), '990.00')||' %', 8) END io_saved
		     FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
WHERE :license = 'Y'
   AND h.dbid = :dbid
   AND h.sql_id = '&&sql_id.'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
ORDER BY 1, 4, 5;	   
SET PAGES 60;
PRO
PRO DBA_HIST_SQLSTAT DELTA (ordered by snap_id, instance_number and plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~~~~~~
SELECT s.snap_id, 
       TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD DY HH24:MI:SS') begin_interval_time,
       TO_CHAR(s.end_interval_time, 'YYYY-MM-DD DY HH24:MI:SS') end_interval_time,
       s.instance_number, h.plan_hash_value,
       DECODE(h.loaded_versions, 1, 'Y', 'N') loaded, 
       LPAD(TO_CHAR(h.executions_delta, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(ROUND(h.elapsed_time_delta/1e6, 3), '999,999,990.000'), 18) elsapsed_secs,
	   LPAD(TO_CHAR(h.rows_processed_delta, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(h.buffer_gets_delta, '999,999,999,999,990'), 20) buffer_gets, 
       LPAD(TO_CHAR(h.disk_reads_delta, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(h.direct_writes_delta, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(h.cpu_time_delta/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(h.iowait_delta/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(h.clwait_delta/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(h.apwait_delta/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(h.ccwait_delta/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(h.plsexec_time_delta/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(h.javexec_time_delta/1e6, 3), '999,999,990.000'), 18) java_exec_secs
	   ,
       LPAD(TO_CHAR(h.io_offload_elig_bytes_delta, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       LPAD(TO_CHAR(h.io_interconnect_bytes_delta, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       CASE 
         WHEN h.io_offload_elig_bytes_delta > h.io_interconnect_bytes_delta THEN
           LPAD(TO_CHAR(ROUND(
           (h.io_offload_elig_bytes_delta - h.io_interconnect_bytes_delta) * 100 / h.io_offload_elig_bytes_delta
           , 2), '990.00')||' %', 8) END io_saved
		     FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
WHERE :license = 'Y'
   AND h.dbid = :dbid
   AND h.sql_id = '&&sql_id.'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
ORDER BY 1, 4, 5;
PRO
PRO DBA_HIST_SQL_PLAN (ordered by plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~
SET PAGES 0;
WITH v AS (
SELECT /*+ MATERIALIZE */ DISTINCT 
       sql_id, plan_hash_value, dbid
  FROM dba_hist_sql_plan 
WHERE :license = 'Y'
   AND dbid = :dbid 
   AND sql_id = '&&sql_id.'
ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) */ t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY_AWR(v.sql_id, v.plan_hash_value, v.dbid, 'ADVANCED')) t;
-- spool off and cleanup
set termout on;
PRO C:\oracle\sql\spool\planx\planx_&&sql_id..txt is the text report
SET FEED ON VER ON LIN 80 PAGES 14 LONG 80 LONGC 80 TRIMS OFF;
SPO OFF;
-- end
undef sql_id