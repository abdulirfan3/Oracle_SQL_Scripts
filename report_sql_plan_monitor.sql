set pages 999
set long 999999999
set longchunksize 10000000
select dbms_sqltune.report_sql_monitor(report_level=>'ALL',type=>'TEXT',sql_id=>'&sql_id') monitor_report from dual;
set pages 50

----------------------------------------------------------------------------------------
--
-- File name:   report_sql_plan_monitor.sql
-- Purpose:     Execute DBMS_SQLTUNE.REPORT_SQL_MONITOR function.
--
-- Author:      Kerry Osborne
--              
-- Usage:       This scripts prompts for three values, all of which can be left blank.
--
--              If all three parameters are left blank, the last statement monitored
--              for the current session will be reported on.
--
--              If the SID is specified and the other two parameters are left blank,
--              the last statement executed by the specified SID will be reported.
--
--              If the SQL_ID is specified and the other two parameters are left blank,
--              the last execution of the specified statement by the current session
--              will be reported.
--
--              If the SID and the SQL_ID are specifie and the SQL_EXEC_ID is left 
--              blank, the last execution of the specified statement by the specified
--              session will be reported.
--
--              If all three parameters are specified, the specified execution of the
--              specified statement by the specified session will by reported.
--
--              Note:   If a match is not found - the header is printed with no data.
--                      The most common cause for this is when you enter a SQL_ID and
--                      leave the other parameters blank, but the current session has 
--                      not executed the specifid statement.
--
--              Note 2: The serial# is not prompted for, but is setup by the decode.
--                      The serial# parameter is in here to ensure you don't get data 
--                      for the wrong session, but be aware that you may need to modify 
--                      this script to allow input of a specific serial#.
---------------------------------------------------------------------------------------
/*
set long 999999999
set longchunksize 10000000
set lines 280
col report for a279
accept sid  prompt "Enter value for sid: "
select
DBMS_SQLTUNE.REPORT_SQL_MONITOR(
   session_id=>nvl('&&sid',sys_context('userenv','sid')),
   session_serial=>decode('&&sid',null,null,
sys_context('userenv','sid'),(select serial# from v$session where audsid = sys_context('userenv','sessionid')),
null),
   sql_id=>'&sql_id',
   sql_exec_id=>'&sql_exec_id',
   report_level=>'ALL') 
as report
from dual;
set lines 1000
undef SID
*/