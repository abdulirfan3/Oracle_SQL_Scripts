/* 
CATEGORY - DEFAULT, SAVED, OTHER, etc...
STATUS - ENABLED, DISABLED
NAME - 
DESCRIPTION - 
*/
exec dbms_sqltune.alter_sql_profile('&profile_name', '&attribute', '&value');
