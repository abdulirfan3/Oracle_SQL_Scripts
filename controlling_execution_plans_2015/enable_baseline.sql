var ret number
exec :ret := dbms_spm.alter_sql_plan_baseline(-
    sql_handle=>'&sql_handle',-
    plan_name=>'&plan_name',-
    attribute_name=>'ENABLED',-
    attribute_value=>'YES');


