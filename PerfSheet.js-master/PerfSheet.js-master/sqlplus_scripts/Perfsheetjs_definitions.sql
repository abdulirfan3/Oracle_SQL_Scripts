-- definitions.sql - configuration file for PerfSheetjs
-- 
-- customize these entries before running the SQL to extract data
-- Contains settings for sql*plus to generate csv output
-- Luca Canali, Oct 2012

set termout off
set verify off
set arraysize 1000
set pages 50000
set underline off
set trimspool on
set echo off
set lines 1000
set colsep ','

-- set the date format, edit here if you wish to change it
alter session set nls_date_format='yyyy_mm_dd hh24:mi';

-- this defines the time interval for fetching AWR dat (AWR queries will have this as where condition)
-- CUSTOMIZE HERE: change for the preferred interval length
define delta_time_where_clause="between sysdate-3 and sysdate"

--populate a file suffix variable
column myfilesuffix new_value myfilesuffix 
select sys_context('USERENV','DB_NAME')||to_char(sysdate,'_yyyy-mm-dd_hh24_mi') myfilesuffix from dual;
