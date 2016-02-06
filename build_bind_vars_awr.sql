-------------------------------------------------------------------------------------------------------
--
-- File name:   build_bind_vars_awr.sql
--
-- Purpose:     Build SQL*Plus test script with variable definitions
--
-- Author:      Kerry Osborne
--
-- Description: This script creates a file which can be executed in SQL*Plus. It creates bind variables, 
--              sets the bind variables to the values stored in DBA_HIST_SQLSTAT.BIND_DATA, and then executes 
--              the statement. The sql_id is used for the file name and is also placed in the statement
--              as a comment. Note that numeric bind variable names are not permited in SQL*Plus, so if
--              the statement has numberic bind variable names, they have an 'N' prepended to them. Also
--              note that CHAR variables are converted to VARCHAR2. You should also watch out for dates
--              as SQL*Plus doesn't have a date datatype.
--
-- Usage:       This scripts prompts for two values.
--
--              sql_id:   this is the sql_id of the statement you want to duplicate
--
--              snap_id: this is the snapshot to pull the data from (if you want a specific one)
--
-- See kerryosborne.oracle-guy.com for more info.
-------------------------------------------------------------------------------------------------------
set sqlblanklines on
set trimspool on
set trimout on
set feedback off;
set linesize 255;
set pagesize 50000;
set timing off;
set head off
--
accept sql_id char prompt "Enter SQL ID ==> " -
default '8p1yd8wtg86vs'
accept snap_id char prompt "Enter Snap_Id ==> "
var isdigits number
col sql_text for a140 word_wrap
--
--
spool &&sql_id\.sql
--
--Check for numeric bind variable names
--
begin
select case regexp_substr(replace(name,':',''),'[[:digit:]]') when replace(name,':','') then 1 end into :isdigits
from DBA_HIST_SQL_BIND_METADATA b
where b.sql_id = '&&sql_id'
and rownum < 2
order by position;
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
DBA_HIST_SQL_BIND_METADATA
where sql_id='&&sql_id';

--
-- Set variable values from DBA_HIST_SQLSTAT 
--

select 'begin' txt from dual;

SELECT  
   case :isdigits when 1 then replace(b.name,':',':N') else b.name end ||
' := ' ||
case when b.datatype = 1 then '''' else null end ||
a.value_string ||
case when b.datatype = 1 then '''' else null end ||
';' txt
from table(
  select dbms_sqltune.extract_binds(bind_data) from DBA_HIST_SQLSTAT
  where sql_id like nvl('&&sql_id',sql_id)
  and snap_id like nvl('&&snap_id',snap_id)
and rownum < 2
and bind_data is not null) a, DBA_HIST_SQL_BIND_METADATA b
where b.sql_id = '&&sql_id'
and a.position = b.position
order by b.position;

select 'end;' txt from dual;
select '/' txt from dual;
--
-- Generate statement
--
select regexp_replace(sql_text,'(select |SELECT )','select /* test &&sql_id */ ',1,1) sql_text from (
select case :isdigits when 1 then replace(sql_text,':',':N') else sql_text end ||';' sql_text
from dba_hist_sqltext
where sql_id = '&&sql_id');
spool off;
-- ed &&sql_id\.sql
undef sql_id
undef snap_id
set feedback on;
set head on
