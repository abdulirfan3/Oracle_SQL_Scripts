prompt
prompt ########################################
prompt #  SQL TUNE Task Name execludes ADDM   #
prompt ########################################
prompt
SELECT owner,task_name, status,execution_end,RECOMMENDATION_COUNT FROM dba_advisor_log where task_name not like 'ADDM:%' order by 4;

Prompt
prompt Enter task name to be dropped...
prompt

exec dbms_sqltune.drop_tuning_task('&task_name');