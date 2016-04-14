
---------------------------------------------------------------------------------------
--
-- File name:   gps.sql
--
-- Purpose:     Creates a SQL Patch on a statement adding the GATHER_PLAN_STATISTICS hint.
-
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for one value.
--
--              sql_id: the sql_id of the statement to attach the patch to 
--                      (must be in the shared pool)
--
--              Note: this version works on both 10g and 11g
--
--
--              See kerryosborne.oracle-guy.com for additional information.
----------------------------------------------------------------------------------------- 

accept sql_id -
       prompt 'Enter value for sql_id: ' -
       default 'X0X0X0X0'

set feedback off
set sqlblanklines on
set serveroutput on format wrapped

declare
  l_patch_name varchar2(30);
  cl_sql_text clob;
  version varchar2(3);
begin

 select regexp_replace(version,'\..*') into version from v$instance;

-- dbms_output.put_line('version: '||version);

select
sql_fulltext
into
cl_sql_text
from
v$sqlarea
where
sql_id = '&&sql_id'
and rownum = 1;

l_patch_name := 'PATCH_'||'&&sql_id'||'_GPS';

if version = '10' then 

dbms_sqldiag_internal.i_create_patch(
sql_text => cl_sql_text,
hint_text => q'[gather_plan_statistics]',
name => l_patch_name,
category => 'DEFAULT'
);

else

dbms_sqldiag_internal.i_create_patch(
sql_text => cl_sql_text,
hint_text => 'gather_plan_statistics',
name => l_patch_name,
category => 'DEFAULT'
);

end if;

dbms_output.put_line(' ');
dbms_output.put_line('Patch '||l_patch_name||' created.');
dbms_output.put_line(' ');

exception
when NO_DATA_FOUND then
  dbms_output.put_line(' ');
  dbms_output.put_line('ERROR: sql_id: '||'&&sql_id'||' not found in v$sqlarea.');
  dbms_output.put_line(' ');

end;
/

undef sql_id

set sqlblanklines off
set feedback on
set serverout off
undef sql_id
undef sql_id

set sqlblanklines off
set feedback on
set serverout off
undef sql_id
