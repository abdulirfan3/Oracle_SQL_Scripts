def _editor = "C:\Program Files\Notepad++\notepad++.exe"
set pages 50 lines 1500
SET FEEDBACK OFF
SET TERMOUT OFF
COLUMN X NEW_VALUE Y
SELECT LOWER(USER || '@' || SYS_CONTEXT('userenv', 'instance_name')) X FROM dual;
SET SQLPROMPT '&Y> '

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
set feedback on
--set time on
set timi on

