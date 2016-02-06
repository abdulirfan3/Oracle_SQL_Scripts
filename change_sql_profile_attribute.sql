@dba_sql_profile

prompt
prompt Enter profile name, what attribute to change(name, category, description, force_matching)
prompt 

BEGIN
  DBMS_SQLTUNE.alter_sql_profile (
    name            => '&profile_name',
    attribute_name  => '&what_to_change',
    value           => '&new_value');
END;
/