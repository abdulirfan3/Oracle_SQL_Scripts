Prompt To track a specific SQL, as not all SQL are captured
prompt Enter SQLID 
prompt
exec dbms_workload_repository.add_colored_sql('&sql_id');

prompt
prompt view dba_hist_colored_sql
prompt to uncolor(unmark) run below
prompt exec dbms_workload_repository.remove_colored_sql('sql_id');