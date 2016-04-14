BEGIN
  DBMS_SQLTUNE.drop_sql_profile (
    name   => '&profile_name',
    ignore => TRUE);
END;
/
