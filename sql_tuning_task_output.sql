prompt
prompt ########################################
prompt #  SQL TUNE Task Name execludes ADDM   #
prompt ########################################
prompt
SELECT owner,task_name, status,execution_end,RECOMMENDATION_COUNT FROM dba_advisor_log where task_name not like 'ADDM:%' order by 4;


SET LONG 1000000000;
SET LONGCHUNKSIZE 1000;
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('&task_name') from dual;