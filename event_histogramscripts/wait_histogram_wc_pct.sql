-- File name:   wait_histogram_wc_pct.sql
-- Purpose:     Display current io statistics from v$sysstat
--
-- Author:      Vishal Desai
-- Copyright:   TBD
--      
-- Pre req:     Must run iostat_proc.sql as sysdba.  
-- Run as:	    sysdba    
-- Usage:       @wait_histogram_wc_pct <event> <interval> <sample>
-- Example:		@wait_histogram_wc_pct 'direct path read' 10 10


set feed off
set head off
set echo off
set term off
set linesize 200
set verify off
spool wait_histogram_wc_pct1.sql
set feedback off
set feed off
set serveroutput on
select 'exec sp_event_histogram_wc(' || '''' || '&1' || '''' || ',&2,1);' from dual;
select 'exec sp_event_histogram_wc(' || '''' || '&1' || '''' || ',&2,0);' from dual connect by level < &3;
spool off
set term on
set serveroutput on
@wait_histogram_wc_pct1.sql