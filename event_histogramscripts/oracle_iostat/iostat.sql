-- File name:   iostat.sql
-- Purpose:     Display current io statistics from v$sysstat
--
-- Author:      Vishal Desai
-- Copyright:   TBD
--      
-- Pre req:     Must run iostat_proc.sql as sysdba.  
-- Run as:	    sysdba    
-- Usage:       @iostat <interval> <sample>


set feed off
set head off
set echo off
set term off
set linesize 120
set verify off
spool iostat1.sql
set feedback off
set feed off
set serveroutput on
select 'exec iostat(&1,1);' from dual;
select 'exec iostat(&1,0);' from dual connect by level < &2;
spool off
set term on
set serveroutput on
@iostat1.sql