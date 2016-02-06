prompt ####################
prompt #  Profile Name    #
prompt ####################
prompt
select name, CATEGORY, SQL_TEXT, status, LAST_MODIFIED,CREATED,FORCE_MATCHING from dba_sql_profiles;
prompt
prompt
prompt Enter a profile name to drop
prompt
exec dbms_sqltune.drop_sql_profile('&profie_name');