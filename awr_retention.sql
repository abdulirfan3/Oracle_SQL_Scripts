col snap_interval format a20
col retention format a20
col topnsql format a20
Prompt snap interval and retention info
select dbid, snap_interval,retention from dba_hist_wr_control;

prompt
prompt Min/Max Snapshot
col min format a30
col max format a30
select min(begin_INTERVAL_TIME) MIN,max(END_INTERVAL_TIME) MAX from dba_hist_snapshot;

prompt
prompt To create a manual AWR snapshot, run below
prompt select dbms_workload_repository.create_snapshot('ALL') from dual;
prompt