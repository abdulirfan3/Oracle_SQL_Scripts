SET LONG 10000;
SET PAGESIZE 9999
--SET LINESIZE 155
set verify off
prompt # Enter Time Limit in Seconds
Prompt
col recommendations for a150
accept task_name -
       prompt 'Task_Name: '
 DECLARE
 ret_val VARCHAR2(4000);

BEGIN

ret_val := dbms_sqltune.create_tuning_task(task_name=>'&&Task_name', sql_id=>'&sql_id', time_limit=>&time_limit);


dbms_sqltune.execute_tuning_task('&&Task_name');

END;
/
SELECT DBMS_SQLTUNE.report_tuning_task('&&task_name') AS recommendations FROM dual;
undef task_name
