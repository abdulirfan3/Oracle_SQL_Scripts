var ret number
exec :ret := dbms_spm.drop_sql_plan_baseline(-
    sql_handle=>'&sql_handle',-
    plan_name=>'&plan_name');


