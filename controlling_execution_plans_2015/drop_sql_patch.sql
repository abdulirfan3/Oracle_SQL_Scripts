BEGIN
  DBMS_SQLDIAG.drop_sql_patch (
    name   => '&patch_name',
    ignore => TRUE);
END;
/
