SET SERVEROUTPUT ON
DECLARE
  l_plans_dropped  PLS_INTEGER;
BEGIN
  l_plans_dropped := DBMS_SPM.drop_sql_plan_baseline (
    sql_handle => NULL,
    plan_name  => '&PLAN_NAME');
    
  DBMS_OUTPUT.put_line(l_plans_dropped);
END;
/