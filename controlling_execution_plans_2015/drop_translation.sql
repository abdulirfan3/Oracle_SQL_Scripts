----------------------------------------------------------------------------------------
--
-- File name:   drop_translation.sql
--
-- Purpose:     Drop (actually Deregister) SQL Translation.
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for three values.
--
--              translation_profile: the name for the SQL Translation Profile to drop the translation from
--
--              sql_id: the sql_id of the statement to drop from the profile
--
--              sql_text: if the sql_id is null, the sql_text may be manually specified
--
--
-- Description: 
--
--              This script deregisters a SQL statement from a translation profile.
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
       prompt 'Enter value for sql_id to be dropped from profile (null): ' -
       default 'X0X0X0X0'
accept sql_text -
       prompt 'Enter value for sql_text_to_replace (null): ' -
       default 'X0X0X0X0'




declare
cl_sql_text clob;
begin

begin
if ('&&sql_id' != 'X0X0X0X0') then
select
sql_text
into
cl_sql_text
from
DBA_SQL_TRANSLATIONS
where
sql_id = '&&sql_id';
end if;

exception
when NO_DATA_FOUND then
  dbms_output.put_line(' ');
  dbms_output.put_line('ERROR: sql_id: '||'&&sql_id'||' not found in DBA_SQL_TRANSLATIONS.');
  dbms_output.put_line(' ');

end;

if (cl_sql_text is not null) then
  dbms_sql_translator.deregister_sql_translation('&&trans_profile',cl_sql_text);
else
  dbms_sql_translator.deregister_sql_translation('&&trans_profile',q'[&&sql_text]');
end if;

  dbms_output.put_line(' ');
  dbms_output.put_line('Translation dropped.');
  dbms_output.put_line(' ');

end;
/


undef trans_profile
undef sql_id
undef sql_text

set sqlblanklines off
set feedback on
set serverout off
