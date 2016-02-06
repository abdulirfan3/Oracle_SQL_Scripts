-------------------------------------------------------------------------------------------------------
--
-- File name:   build_bind_vars2.sql
--
-- Purpose:     Build SQL*Plus test script with variable definitions
--
-- Author:      Jack Augustin and Kerry Osborne
--
-- Description: This script creates a file which can be executed in SQL*Plus. It creates bind variables,
--              sets the bind variables to the values stored in V$SQL_BIND_CAPTURE, and then executes
--              the statement. The sql_id is used for the file name and is also placed in the statement
--              as a comment. Note that numeric bind variable names are not permited in SQL*Plus, so if
--              the statement has numberic bind variable names, they have an 'N' prepended to them. Also
--              note that CHAR variables are converted to VARCHAR2.
--
-- Usage:       This scripts prompts for two values.
--
--              sql_id:   this is the sql_id of the statement you want to duplicate
--
--              child_no: this is the child cursor number from v$sql 
--                        (the default is 0 second)
-- 
-- http://kerryosborne.oracle-guy.com/2009/07/creating-test-scripts-with-bind-variables/
-------------------------------------------------------------------------------------------------------
--
set sqlblanklines on
set trimspool on
set trimout on
set feedback off;
--set linesize 255;
set pagesize 50000;
set timing off;
set head off
--
accept sql_id char prompt "Enter SQL ID ==> "
accept child_no char prompt "Enter Child Number ==> " default 0
var isdigits number
--
--
col sql_fulltext for a140 word_wrap
--spool &&sql_id\.sql
--
--Check for numeric bind variable names
--
begin
select case regexp_substr(replace(name,':',''),'[[:digit:]]') when replace(name,':','') then 1 end into :isdigits
from
V$SQL_BIND_CAPTURE
where
sql_id='&&sql_id'
and child_number = &&child_no
and rownum < 2;
end;
/
--
-- Create variable statements
--
select
'variable ' ||
   case :isdigits when 1 then replace(name,':','N') else substr(name,2,30) end || ' ' ||
replace(datatype_string,'CHAR(','VARCHAR2(') txt
from
V$SQL_BIND_CAPTURE
where
sql_id='&&sql_id'
and child_number = &&child_no;
--
-- Set variable values from V$SQL_BIND_CAPTURE
--
select 'begin' txt from dual;
select
   case :isdigits when 1 then replace(name,':',':N') else name end ||
   ' := ' ||
   case datatype_string when 'NUMBER' then null else '''' end ||
   value_string ||
   case datatype_string when 'NUMBER' then null else '''' end ||
   ';' txt
from
   V$SQL_BIND_CAPTURE
where
   sql_id='&&sql_id'
   and child_number = &&child_no;
select 'end;' txt from dual;
select '/' txt from dual;
--
-- Generate statement
--
select regexp_replace(sql_fulltext,'(select |SELECT )','select /* test &&sql_id */ /*+ gather_plan_statistics */ ',1,1) sql_fulltext from (
select case :isdigits when 1 then replace(sql_fulltext,':',':N') else sql_fulltext end ||';' sql_fulltext
from v$sqlarea
where sql_id = '&&sql_id');
--
--spool off;
undef sql_id
undef child_no
set feedback on;
set head on