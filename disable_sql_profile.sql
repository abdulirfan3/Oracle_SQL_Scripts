Prompt Profile name
prompt
@DBA_SQL_PROFILE
set verify off
prompt 
EXEC DBMS_SQLTUNE.ALTER_SQL_PROFILE (name =>  '&profile_name',   attribute_name => 'STATUS', value =>  'DISABLED');
