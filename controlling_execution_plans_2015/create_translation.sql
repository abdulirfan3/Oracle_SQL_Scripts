----------------------------------------------------------------------------------------
--
-- File name:   create_translation.sql
--
-- Purpose:     Create (actually Register) SQL Translation.
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for three values (text input is commented out).
--
--              translation_profile: the name of the translation profile to register with
--
--              sql_id: the sql_id of the statement to replace (must be in the shared pool)
--
--              sql_id2: the sql_id of a statement used to replace the original text 
-- 
-- Description: 
--
--              This script allows a statements text to be replaced on the fly. It's based 
--              on the dbms_sql_translator functionality added in DB 12.1 that was originally
--              written to be part of SQL Developer. The intent of dbms_sql_translate was to 
--              translate SQL generate by aps written for other RDBMS's to Oracle specific 
--              syntax (Sybase to Oracle for example).
--
--              Note that to enable translation you'll need to do the following to things:
--
--                 alter session set sql_translation_profile = &translation_profile_name;
--                 alter session set events = '10601 trace name context forever, level 32';
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
--


set serverout on format wrapped
set feedback off
set sqlblanklines on

accept trans_profile -
       prompt 'Enter value for sql_translation_profile (FOO): ' -
       default 'FOO'
accept sql_id -
       prompt 'Enter value for sql_id_to_replace: ' -
       default 'X0X0X0X0'
accept sql_id2 -
       prompt 'Enter value for sql_id_to_be_executed: ' -
       default 'X0X0X0X0'


declare
cl_sql_text clob;
cl_sql_text2 clob;
begin

begin
if ('&&sql_id' != 'X0X0X0X0') then
select
sql_fulltext
into
cl_sql_text
from
v$sqlarea
where
sql_id = '&&sql_id';
end if;

exception
when NO_DATA_FOUND then
  dbms_output.put_line(' ');
  dbms_output.put_line('ERROR: sql_id: '||'&&sql_id'||' not found in v$sqlarea.');
  dbms_output.put_line(' ');

end;

begin
if ('&&sql_id2' != 'X0X0X0X0') then
select
sql_fulltext
into
cl_sql_text2
from
v$sqlarea
where
sql_id = '&&sql_id2';
end if;

exception
when NO_DATA_FOUND then
  dbms_output.put_line(' ');
  dbms_output.put_line('ERROR: sql_id: '||'&&sql_id2'||' not found in v$sqlarea.');
  dbms_output.put_line(' ');

end;

if (cl_sql_text is not null and cl_sql_text2 is not null) then
dbms_sql_translator.register_sql_translation('&&trans_profile',cl_sql_text,cl_sql_text2);
end if;

  dbms_output.put_line(' ');
  dbms_output.put_line('Translation created.');
  dbms_output.put_line(' ');

end;
/


undef trans_profile
undef sql_id
undef sql_text
undef sql_id2
undef sql_text2

set sqlblanklines off
set feedback on
set serverout off
