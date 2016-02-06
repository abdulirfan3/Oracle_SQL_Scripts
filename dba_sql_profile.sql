prompt ####################
prompt #  Profile Name    #
prompt ####################
prompt
col SIGNATURE format 9999999999999999999999999999999999999
select name, CATEGORY, SQL_TEXT,SIGNATURE, status, LAST_MODIFIED,CREATED,FORCE_MATCHING, Type, DESCRIPTION from dba_sql_profiles;
