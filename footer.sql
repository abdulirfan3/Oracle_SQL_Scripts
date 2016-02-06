


CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

set trimspool on
set feed on
set arraysize 5000
set lines 80
set pages 80
set verify on
set sqlblankline on
set serveroutput on
set tab off
set term on
--start backupenv

DEFINE 1=""
DEFINE 2=""
DEFINE 3=""
DEFINE 4=""
DEFINE 5=""
DEFINE 6=""
DEFINE 7=""
DEFINE 8=""
DEFINE 9=""
DEFINE 10=""

-- VG_SPOOLFILE is being set in the login.sql
-- spool again to flush the buffer contents to file
-- spool &&VG_SPOOLFILE append 

--set echo on
PROMPT



def _editor = "C:\Program Files\Notepad++\notepad++.exe"
set pages 50 lines 1500
SET FEEDBACK OFF
SET TERMOUT OFF
COLUMN X NEW_VALUE Y
SELECT LOWER(USER || '@' || SYS_CONTEXT('userenv', 'instance_name')) X FROM dual;
SET SQLPROMPT '&Y> '
prompt Setting NLS_DATE_FORMAT to DD-MON-YY HH24:MI:SS

ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'; 
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD-MON-YYYY HH24:MI:SS.FF'; 
set termout on
--Sets the column separator character printed between columns in output.
SET COLSEP '|'
SET verify OFF
-- to remove spaces (white spaces)
SET tab off
set arraysize 5000;
set time on;
set timi on;