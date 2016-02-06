SELECT *
FROM   TABLE(DBMS_XPLAN.display_sql_plan_baseline(plan_name=>'&PLAN_NAME'));