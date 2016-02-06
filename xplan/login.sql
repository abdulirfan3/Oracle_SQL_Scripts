def _editor = "C:\Program Files\Notepad++\notepad++.exe"
set pages 100 lines 1500
set termout on
--set time on
set timi on
--Sets the column separator character printed between columns in output.
SET COLSEP '|'
SET verify OFF
-- to remove spaces (white spaces)
SET tab off
set arraysize 50;
prompt Setting NLS_DATE_FORMAT to DD-MON-YY HH24:MI:SS
alter session set NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS';
select sysdate from dual;
select instance_name, host_name, status, STARTUP_TIME from v$instance;
@sess_active.sql