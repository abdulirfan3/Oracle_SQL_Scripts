ACCEPT script_name_like prompt 'ENTER SCRIPT NAME OR HIT ENTER TO GET ALL SCRIPT NAME OR PUT PART OF THE SCRIPT NAME : ' 
WITH my_scripts AS
(SELECT 'blocking_locks' AS Script_Name,
           'Shows blocking lock info' AS Description,
           'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'datafile' AS Script_Name,
                    'Shows datafile name, size, etc' AS Description,
                    'TS Name or BLANK for all TS' AS INPUT
   FROM dual
   UNION ALL SELECT 'find_sql' AS Script_Name,
                    'Shows SQL text,child#,exec, etc' AS Description,
                    'SQL text LIKE or SQL_ID' AS INPUT
   FROM dual
   UNION ALL SELECT 'find_sql_text_sid' AS Script_Name,
                    'Shows SQL text, sql_id,etc' AS Description,
                    'SID' AS INPUT
   FROM dual
   UNION ALL SELECT 'find_sql_sid_hash' AS Script_Name,
                    'Shows SQL text, sql_id,etc' AS Description,
                    'SID(9i)' AS INPUT
   FROM dual
   UNION ALL SELECT 'find_sql_stats_hash' AS Script_Name,
                    'Shows SQL Stats' AS Description,
                    'HASH VALUE(9i)' AS INPUT
   FROM dual
   UNION ALL SELECT 'latchprof' AS Script_Name,
                    'Monitor Latches for SID' AS Description,
                    'Look at Header of script or latchprof_output.txt' AS INPUT
   FROM dual
   UNION ALL SELECT 'locks_blocking_j' AS Script_Name,
                    'Shows blocking lock info' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'metadata_tablespace' AS Script_Name,
                    'Create TS statement' AS Description,
                    'TS Name' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_active' AS Script_Name,
                    'Shows all ACTIVE session and other info' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_active_tab' AS Script_Name,
                    'Shows all ACTIVE session and what table its going against' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
	 UNION ALL SELECT 'sess_active2' AS Script_Name,
                    'Shows all ACTIVE session and SQL Exec Duration' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
	 UNION ALL SELECT 'sess_all' AS Script_Name,
                    'Shows all ACTIVE/INACTIVE session and other info' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_by_cpu_active' AS Script_Name,
                    'Active session order by CPU' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_by_cpu_all' AS Script_Name,
                    'ALL session order by CPU' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_stats' AS Script_Name,
                    'ALL Session Stats' AS Description,
                    'SID and stat name or ALL' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_session_wait' AS Script_Name,
                    'Current session Wait for SID' AS Description,
                    'SID' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_session_wait_active' AS Script_Name,
                    'Active session Wait' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_session_wait_active_9i' AS Script_Name,
                    'Active session Wait for 9i' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_session_wait_block_10g' AS Script_Name,
                    'Blocking lock info and wait' AS Description,
                    'SID' AS INPUT
   FROM dual
   UNION ALL SELECT 'snapper' AS Script_Name,
                    'Advance Stats info' AS Description,
                    'all sec sample SID or snapper_out.txt' AS INPUT
   FROM dual
   UNION ALL SELECT 'snapperloop' AS Script_Name,
                    'Advance Stats info in a loop' AS Description,
                    'all sec sample SID' AS INPUT
   FROM dual
   UNION ALL SELECT 'tablespace_info' AS Script_Name,
                    'TS INFO' AS Description,
                    'TS Name or all' AS INPUT
   FROM dual
   UNION ALL SELECT 'tempfile' AS Script_Name,
                    'Temp file and size' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'waitprof' AS Script_Name,
                    'sample v$session_wait' AS Description,
                    'waitprof noprint sid e 100000 look waitprof_output.txt' AS INPUT
   FROM dual
   UNION ALL SELECT 'xplan_stats2' AS Script_Name,
                    'explain plan info with stats' AS Description,
                    'GATHER_PLAN_STATISTICS hint' AS INPUT
   FROM dual
   UNION ALL SELECT 'xpln' AS Script_Name,
                    'explain plan' AS Description,
                    'hash value and child #' AS INPUT
   FROM dual
   UNION ALL SELECT 'xpln_stats' AS Script_Name,
                    'explain plan info with stats' AS Description,
                    'GATHER_PLAN_STATISTICS hint' AS INPUT
   FROM dual
   UNION ALL SELECT 'asm_clients' AS Script_Name,
                    'All RDBMS Client using ASM' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'asm_diskgroups' AS Script_Name,
                    'ALL DG name,size, etc' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'asm_disks' AS Script_Name,
                    'All disk being used and then one candidate' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'asm_disks_perf' AS Script_Name,
                    'DG Performance read and write' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'asm_files2' AS Script_Name,
                    'All files in ASM, full path' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'asm_files' AS Script_Name,
                    'All files in ASM, NO path' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'asm' AS Script_Name,
                    'All ASM Related info' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'asm_alias' AS Script_Name,
                    'Shows ASM Alias' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'asm_drop_files' AS Script_Name,
                    'Create Drop files cmd' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'asm_files_10g' AS Script_Name,
                    'same as asm file but for 10g' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'asm_templates' AS Script_Name,
                    'ASM Templates being used ' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'background_process' AS Script_Name,
                    'Shows all BG Process info' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'datafile_like' AS Script_Name,
                    'uses like to get datafile name' AS Description,
                    'TS or file name or empty' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_user_transactions' AS Script_Name,
                    'tabe locking info and current Transactions' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_query_sql_sid' AS Script_Name,
                    'Shows SQL and Disk/buffer reads' AS Description,
                    'SID' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_uncommited_trans_undo' AS Script_Name,
                    'Shows all uncommited trans' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_user_sessions_group' AS Script_Name,
                    'session group by username and max session allowed' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_user_stats' AS Script_Name,
                    'ALL session stat-cpu,reads,tnx etc' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_user_stats_active' AS Script_Name,
                    'Active session stat-cpu,reads,tnx etc' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_user_trace_file_loc' AS Script_Name,
                    'shows trace file location on Server' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_users_by_cursors' AS Script_Name,
                    'count of all open cursors by session' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_users_by_io' AS Script_Name,
                    'All "SESSION" IO stats' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_users_by_memory' AS Script_Name,
                    'session user PGA allocation' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_users_by_transactions' AS Script_Name,
                    'Number of Tnx by user' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_users_sql_active' AS Script_Name,
                    'All SQL text of active session' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_users_sql_all' AS Script_Name,
                    'All SQL text of all session' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'kellogg_prd_tbs' AS Script_Name,
                    'specific to prd kellogg less than 1.5%' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'kellogg_ts' AS Script_Name,
                    'specific to kellogg' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'kellogg_prd_tbs_2' AS Script_Name,
                    'specific to prd kellogg less than 2%' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'find_ospid_with_sid' AS Script_Name,
                    'OS PID from oracle SID' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'find_sid_with_ospid' AS Script_Name,
                    'Oracle SID from OS PID' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_active_sql_io_logical' AS Script_Name,
                    'SQL IO stats of Active session ord by logical' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_active_sql_io_physical' AS Script_Name,
                    'SQL IO stats of Active session ord by physical' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_awr_snapshots_dbtime' AS Script_Name,
                    'DB Time from AWR, to look at high activity time' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'asmm_components_memory' AS Script_Name,
                    'Shows ASSM components size' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_controlfile_records' AS Script_Name,
                    'Control file records and size' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_controlfiles' AS Script_Name,
                    'Control File location' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'parameter' AS Script_Name,
                    'Shows Parameter name and value' AS Description,
                    'Parameter Name like or blank for all' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_directories' AS Script_Name,
                    'Oracle Directories name and path' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_invalid_objects' AS Script_Name,
                    'Objects that are invalid by user' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_invalid_objects_summary' AS Script_Name,
                    'Count of Invalid Objects by user' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'datafile_like_round' AS Script_Name,
                    'datafile name, location, size, etc' AS Description,
                    'TS Name or File name or empty for all' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_jobs' AS Script_Name,
                    'Dba Jobs info, name, what, when(dba_jobs)' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_object_search' AS Script_Name,
                    'Object name and type' AS Description,
                    'user name and object name or empty for all' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_object_summary' AS Script_Name,
                    'Object count by type' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_options_installed' AS Script_Name,
                    'Options Installed on DB' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_owner_to_tablespace_segment' AS Script_Name,
                    'Segment size group by type/user' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'all_hidden_parameters' AS Script_Name,
                    'Shows hidden parameters( _ underscore)' AS Description,
                    'Run as SYSDBA/ Name like or blank for all' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_registry' AS Script_Name,
                    'Registry info and History' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_segment_summary' AS Script_Name,
                    'Segment size group by type' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_table_info' AS Script_Name,
                    'Shows table,segment,index,const etc info' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'segment_file_mapper' AS Script_Name,
                    'Shows object type/size in specific datafile' AS Description,
                    'TS Name and File Number' AS INPUT
   FROM dual
   UNION ALL SELECT 'extent_block_mapper' AS Script_Name,
                    'Shows Block ID, segment name' AS Description,
                    'TS Name and File Number, MIGHT TAKE LONG TIME' AS INPUT
   FROM dual
   UNION ALL SELECT 'fra_alerts' AS Script_Name,
                    'ALL Alerts for FRA(dba_outstanding_alerts)' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'fra_files' AS Script_Name,
                    'Files in FRA' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'fra_status' AS Script_Name,
                    'FRA size' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'fra_db_log_files' AS Script_Name,
                    'FRA DB log files (FLASHBACK)' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'fra_db_redo_time_matrix' AS Script_Name,
                    'Amount of Redo for FRA/DB Flashback' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'fra_db_status' AS Script_Name,
                    'FRA Status/DB FlashBack' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'locks_dml_ddl_10g' AS Script_Name,
                    'Shows all DML/DDL Locks and wait time' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'locks_dml_lock_time' AS Script_Name,
                    'Shows DML Locks' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_event_names' AS Script_Name,
                    'Event name,number and p1,p2,p3 desc' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_top_segments' AS Script_Name,
                    'Top 100 segment by size' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_file_io_efficiency' AS Script_Name,
                    'Datafile read, writes, etc' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_file_io_physical' AS Script_Name,
                    'Datafile Physical read, writes' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_log_switch_history_mb_daily_all' AS Script_Name,
                    'Shows redo log switch size in MB' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_log_switch_history_gb_daily_all' AS Script_Name,
                    'Shows redo log switch size in GB' AS Description,
                    'day start and day end' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_log_switch_history_count_daily_all' AS Script_Name,
                    'Shows log switch count' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_hit_ratio_by_session' AS Script_Name,
                    'Hit Ration for each session' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_redo_log_contention' AS Script_Name,
                    'Redo Log stats since inst startup' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_sga_free_pool_memory' AS Script_Name,
                    'Reports on free shared/java/large pool' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_sga_usage_memory' AS Script_Name,
                    'Report on ALL SGA components' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_shared_pool_memory' AS Script_Name,
                    'Total Memory and free Memory in SHARED POOL' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_objects_wo_statistics' AS Script_Name,
                    'Objects without STATS' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rac_waiting_sessions' AS Script_Name,
                    'Session Wait info > 0 sec' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rac_sess_users_sql' AS Script_Name,
                    'All User SQL across all RAC inst' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rac_sess_users_active' AS Script_Name,
                    'Active user session across all RAC inst' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rac_sess_users' AS Script_Name,
                    'All user session across all RAC inst' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rac_rollback_users' AS Script_Name,
                    'Active Roll Bck seg on RAC and user using it' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rac_rollback_segments' AS Script_Name,
                    'undo/roll back segm infon on RAC' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rac_locks_blocking' AS Script_Name,
                    'Blocking Locks on RAC' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rac_instances' AS Script_Name,
                    'Instance related info on RAC' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_top_sql_by_disk_reads_io' AS Script_Name,
                    'Top SQL by Disk Read' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_top_sql_by_buffer_gets_io' AS Script_Name,
                    'Top SQL by Buffer gets' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_top_10_tables' AS Script_Name,
                    'Top 10 tables with respect to usage' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_top_10_procedures' AS Script_Name,
                    'Top 10 procedures with respect to usage' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rman_configuration' AS Script_Name,
                    'RMAN Config that are not default' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rman_controlfiles' AS Script_Name,
                    'RMAN Control file backup' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rman_progress' AS Script_Name,
                    'RMAN Operation and EST Timings' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rman_spfiles' AS Script_Name,
                    'RMAN Spfile backup' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rman_backup_pieces' AS Script_Name,
                    'RMAN Backup Piece, time, status' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rman_backup_sets' AS Script_Name,
                    'RMAN Backup SET info' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sec_default_passwords' AS Script_Name,
                    'Oracle user with DEFAULT password' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sec_roles' AS Script_Name,
                    'all role name and Grantee' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sec_users' AS Script_Name,
                    'User name, status,TS, profile,etc' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'undo_rollback_contention' AS Script_Name,
                    'undo contention' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'undo_rollback_users' AS Script_Name,
                    'active undo size and session using it' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'temp_sort_users' AS Script_Name,
                    'Temp TS name and user perfoming sort' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sp_list' AS Script_Name,
                    'Statspack SNAP ID number' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'temp_sort_segment' AS Script_Name,
                    'Actual temp sort Seg and size' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'redo' AS Script_Name,
                    'Online redo log file, size, order by SEQ#' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_wait_system' AS Script_Name,
                    'Total wait event since INST startup' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_role_users' AS Script_Name,
                    'Which user have DBA roles' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_link' AS Script_Name,
                    'DB links info' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'seg_near_max_extents' AS Script_Name,
                    'Shows Segment name which are near max extents' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'seg_unable_extend' AS Script_Name,
                    'Segment that cannot extend' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'row_chain' AS Script_Name,
                    'Tables w/row chaining(populated after stats)' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'objects_in_system_ts' AS Script_Name,
                    'Object that are in SYSTEM ts, beside sys/system' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_scheduler_jobs' AS Script_Name,
                    'Jobs from dba_scheduler_jobs' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'long_ops' AS Script_Name,
                    'Old long ops and remaning long ops' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'latch' AS Script_Name,
                    'all latches gets/misses' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'temp_size' AS Script_Name,
                    'Temp size,free and used' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'temp_sort_users2' AS Script_Name,
                    'Temp TS name and user perfoming sort w/obj name' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'temp_sort_users_10' AS Script_Name,
                    'Temp TS,sid,sql text, usage(for 10g)' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'ts_gb' AS Script_Name,
                    'TS info in GB' AS Description,
                    'TS Name or blank for all TS' AS INPUT
   FROM dual
   UNION ALL SELECT 'segment_size' AS Script_Name,
                    'Segment size MB and GB' AS Description,
                    'user/segment_name or Blank for all' AS INPUT
   FROM dual
   UNION ALL SELECT 'schema_size' AS Script_Name,
                    'Schema size from dba_segments' AS Description,
                    'Schema name or blank for all' AS INPUT
   FROM dual
   UNION ALL SELECT 'stats_allSchema' AS Script_Name,
                    'Count of objects/dates group by user' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'long_ops2' AS Script_Name,
                    'operation name/target % done etc' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'db_size' AS Script_Name,
                    'Total size and used size' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'top_ten_segments' AS Script_Name,
                    'Top 10 segment by size' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_mv' AS Script_Name,
                    'MV name and last refresh time' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_partitions' AS Script_Name,
                    'Table name with partition count/type' AS Description,
                    'Username and table name or just username for all' AS INPUT
   FROM dual
   UNION ALL SELECT 'list_all_partition' AS Script_Name,
                    'Partition name and high/low value' AS Description,
                    'Owner and table name' AS INPUT
   FROM dual
   UNION ALL SELECT 'list_all_partition_size' AS Script_Name,
                    'Partition name,num_rows and size' AS Description,
                    'Owner and table name' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_trigger_user' AS Script_Name,
                    'trigger name, type and status' AS Description,
                    'Username' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_trigger_user_table' AS Script_Name,
                    'trigger name, type and status' AS Description,
                    'Username and table_name or just username for all' AS INPUT
   FROM dual
   UNION ALL SELECT 'unusable_index' AS Script_Name,
                    'Index with unusable status' AS Description,
                    'username or blank for all' AS INPUT
   FROM dual
   UNION ALL SELECT 'plan_history' AS Script_Name,
                    'SQL Plan from AWR' AS Description,
                    'SQL_ID' AS INPUT
   FROM dual
   UNION ALL SELECT 'current_plan' AS Script_Name,
                    'SQL Plan from shared pool' AS Description,
                    'SQL_ID' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_active_9i' AS Script_Name,
                    'Active user session #for 9i' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'table_stats' AS Script_Name,
                    'Basic stats, # of rows/blks and last analyzed' AS Description,
                    'username and tablename' AS INPUT
   FROM dual
   UNION ALL SELECT 'index_stats' AS Script_Name,
                    'Stats info for indexes' AS Description,
                    'username and tablename' AS INPUT
   FROM dual
   UNION ALL SELECT 'shared_pool_advice_memory' AS Script_Name,
                    'Shared pool Memory Advisor' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'library_cache_memory' AS Script_Name,
                    'library cache related info(get,pin,reload)' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'db_cache_size_advice_memory' AS Script_Name,
                    'DB Cache Memory Advisor' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_profile' AS Script_Name,
                    'Profile name,resource type and limit' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'ash_cpu' AS Script_Name,
                    'top cpu session in last 5 mins from ASH' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'ash_waiting' AS Script_Name,
                    'Session waiting in last 5 mins from ASH' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'ash_top_sql' AS Script_Name,
                    'Top SQL_ID in last 5 mins from ASH' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'ash_top_session' AS Script_Name,
                    'Top session from ASH last 5 mins' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_load_active' AS Script_Name,
                    'Active session, total session IO, SQL IO etc' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_load_active_9i' AS Script_Name,
                    'Active session, total session IO, SQL IO etc (9i)' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_system_wait' AS Script_Name,
                    'Wait evnt Cumulative grouped and trnd for LAST HR' AS Description,
                    'Wait Class' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_count_session_wait' AS Script_Name,
                    'Sample of CURRENT wait events 10 times' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_whats_changed_plan' AS Script_Name,
                    'SQL that are faster or slower' AS Description,
                    'Days back,st_dev(def twice/slow), look at header' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_awr_plan_change' AS Script_Name,
                    'SQL Stats across AWR' AS Description,
                    'SQL_ID' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_unstable_plans' AS Script_Name,
                    'Plans with instability' AS Description,
                    'Min St_dev and min_etime(have defaults)' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_sql_text_stats' AS Script_Name,
                    'Shows perf info and some sql text' AS Description,
                    'SQL_ID' AS INPUT
   FROM dual
   UNION ALL SELECT 'table_stats2' AS Script_Name,
                    'Detail stats of table/index/col' AS Description,
                    'Username and table name' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_multi_plan' AS Script_Name,
                    'Search shared pool for SQL with multi plans' AS Description,
                    'Number of Distinct plans, start with 2' AS INPUT
   FROM dual
   UNION ALL SELECT 'flush_sql' AS Script_Name,
                    'Flush SINGLE SQL from shared pool' AS Description,
                    'SQL_ID (req - exec on dbms_shared_pool)' AS INPUT
   FROM dual
   UNION ALL SELECT 'build_bind_vars2' AS Script_Name,
                    'Builds Bind Variable set' AS Description,
                    'SQL_ID and Child#' AS INPUT
   FROM dual
   UNION ALL SELECT 'bind_awr' AS Script_Name,
                    'Show all bind var for that SQL from AWR(lng otpt)' AS Description,
                    'SQL_ID' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_top_5_sql' AS Script_Name,
                    'top 5 SQL by physicl/logical/elapsed/cpu time' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sql_text_full' AS Script_Name,
                    'Shows FULL SQL Text' AS Description,
                    'SQL_ID' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_all_9i' AS Script_Name,
                    'ALL User Session #For 9i' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_sqlhistory_trend' AS Script_Name,
                    'SQL Stats History over time from AWR' AS Description,
                    'SQL_ID and # of day to go back' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_time_model_sid' AS Script_Name,
                    'Shows Time Model stats for an SID' AS Description,
                    'SID' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_load_profile' AS Script_Name,
                    'Load prof,metrics for last hr and time model' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_metric_last_hour_trend' AS Script_Name,
                    'Shows Metric histroy for last hr' AS Description,
                    'Metric name(can select from list provided)' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_system_wait_last_60sec' AS Script_Name,
                    'Shows Overall system wait for last 60 Sec ONLY' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_avg_hist_wait_event_trend' AS Script_Name,
                    'Hourly AVG_MS wait for a event' AS Description,
                    'Wait Event Name' AS INPUT
   FROM dual
   UNION ALL SELECT 'sessinfo' AS Script_Name,
                    'Info related to session' AS Description,
                    'sessinfo SID' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_system_wait_real_time' AS Script_Name,
                    'shows evnt,count, Avg actv sess and AV_MS wait' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'grant' AS Script_Name,
                    'Shows obj,col,system and role privileges' AS Description,
                    'Username or Role name' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_child_load_time' AS Script_Name,
                    'Shows When a SQL was loaded in Shared pool' AS Description,
                    'SQL Text(LIKE/EMPTY) and SQL_ID' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_find_sql_child' AS Script_Name,
                    'Find all SQL CHILD and perf stats(11g)' AS Description,
                    'SQL Text(LIKE/EMPTY), SQL_ID, is_bind_aware(blnk)' AS INPUT
   FROM dual
   UNION ALL SELECT 'find_sql_awr' AS Script_Name,
                    'Shows Cumulative perf stats' AS Description,
                    'begin/end snap id(blank),sql text(like), sql_id' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_lobs' AS Script_Name,
                    'Shows tab name,owner,ts name' AS Description,
                    'Segment_name' AS INPUT
   FROM dual
   UNION ALL SELECT 'rman_block_change_bct' AS Script_Name,
                    'Shows BCT file size/name and %read for bkp' AS Description,
                    'No Input Needed(give datafile# to see more info)' AS INPUT
   FROM dual
   UNION ALL SELECT 'rman_backup_time' AS Script_Name,
                    'Shows bkp time,type,status' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rc_rman_all_db_backup' AS Script_Name,
                    'Shows when were all DB/ARCH last bkp time' AS Description,
                    'No Input Needed(req= Connect to Recovery Catalog)' AS INPUT
   FROM dual
   UNION ALL SELECT 'rman_backup_size' AS Script_Name,
                    'Shows bkp type,time,size' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sql_text_full2' AS Script_Name,
                    'Shows FULL SQL Text(no limitation on long string)' AS Description,
                    'SQL_ID' AS INPUT
   FROM dual
   UNION ALL SELECT 'feature_usage' AS Script_Name,
                    'Shows all the DB Features that have been used' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'rman_info_all' AS Script_Name,
                    'Shows ALL RMAN INFO' AS Description,
                    '# of day to go back(more details can retrived)' AS INPUT
   FROM dual
   UNION ALL SELECT 'rc_rman_info_all' AS Script_Name,
                    'ALL RMAN INFO(req= Connect to Recovey Catalog)' AS Description,
                    '# of day and DB name(more details can retrived)' AS INPUT
   FROM dual
   UNION ALL SELECT 'rc_rman_info_L0' AS Script_Name,
                    'RMAN INFO For Level 0(req= Connect to Recovey Catalog)' AS Description,
                    '# of day and DB name' AS INPUT
   FROM dual
   UNION ALL SELECT 'rc_rman_datafile' AS Script_Name,
                    'bkp info for df file(req= Recovey Catalog)' AS Description,
                    'run rc_rman_info_all first and then bs_keys' AS INPUT
   FROM dual
   UNION ALL SELECT 'rc_rman_cont' AS Script_Name,
                    'bkp info for cntl file(req= Recovey Catalog)' AS Description,
                    'run rc_rman_info_all first and then session_recid' AS INPUT
   FROM dual
   UNION ALL SELECT 'rc_rman_arch' AS Script_Name,
                    'bkp info for arch file(req= Recovey Catalog)' AS Description,
                    'run rc_rman_info_all first and then session_recid' AS INPUT
   FROM dual
   UNION ALL SELECT 'sess_single_sid' AS Script_Name,
                    'Shows basic info for ONE session' AS Description,
                    'SID' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_sess_wait_current_and_all' AS Script_Name,
                    'Current and cumulative(since login) wait time' AS Description,
                    'SID' AS INPUT
   FROM dual
   UNION ALL SELECT 'xplan_by_order' AS Script_Name,
                    'Shows explain plan and order of the plan' AS Description,
                    'SQL_ID and Child#' AS INPUT
   FROM dual
   UNION ALL SELECT 'undo_history_size_trend' AS Script_Name,
                    'Shows undo usage from AWR' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'sysdate' AS Script_Name,
                    'Shows Current DB/Server time' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'stat_history' AS Script_Name,
                    'Shows object stats history' AS Description,
                    'username and object name' AS INPUT
   FROM dual
   UNION ALL SELECT 'io_latency' AS Script_Name,
                    'Current IO related Latency' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'ashmon_plan' AS Script_Name,
                    'Shows exe plan but like SQL Monitor from ASH' AS Description,
                    '@asqlmon <sqlid> <child#>' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_sql_id' AS Script_Name,
                    'Shows SQL hash value, perf stat' AS Description,
                    'SQL_ID and Child#' AS INPUT
   FROM dual
   UNION ALL SELECT 'awr_metric_trends' AS Script_Name,
                    'Daily/Hourly trend for given metric' AS Description,
                    'Metric Name(select from display)' AS INPUT
   FROM dual
   UNION ALL SELECT 'awr_event_trends' AS Script_Name,
                    'Daily/Hourly trend for a wait event' AS Description,
                    '# of day to look in AWR and event name(Displayed)' AS INPUT
   FROM dual
   UNION ALL SELECT 'awr_event_class_trends' AS Script_Name,
                    'Daily/Hourly trend for a wait CLASS' AS Description,
                    '#of day to look in AWR and event class(Displayed)' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_system_stat' AS Script_Name,
                    'Cumulative top 10 system stats' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'parallel_query_slaves' AS Script_Name,
                    'Check parallel query slaves' AS Description,
                    'No Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'cbo_session_setting_optimizer' AS Script_Name,
                    'Optimizer setting for a specific session' AS Description,
                    'SID' AS INPUT
   FROM dual
   UNION ALL SELECT 'disable_sql_profile' AS Script_Name,
                    'Disable a paticular SQL Profile in use' AS Description,
                    'Profile Name' AS INPUT
   FROM dual
   UNION ALL SELECT 'accept_sql_profile' AS Script_Name,
                    'accept a paticular profile suggested by STA' AS Description,
                    'STA task name and category(default)' AS INPUT
   FROM dual
   UNION ALL SELECT 'profile_hints' AS Script_Name,
                    'lists all the hints used by a paticular profile' AS Description,
                    'profile name' AS INPUT
   FROM dual
   UNION ALL SELECT 'drop_sql_profile' AS Script_Name,
                    'drop a paticular sql profile' AS Description,
                    'profile name(select from list)' AS INPUT
   FROM dual
   UNION ALL SELECT 'sql_create_tuning_task' AS Script_Name,
                    'Creates SQL Tuning task' AS Description,
                    'task name, SQL_ID, time limit(in seconds)' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_sql_profile' AS Script_Name,
                    'list of all SQL Profile and category name' AS Description,
                    'no Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_top_sql_in_awr' AS Script_Name,
                    'TOP 10 SQL BY elapsed/read/etc in AWR' AS Description,
                    'no Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_system_statistics_keyfigures' AS Script_Name,
                    'system stats aggregated by day from AWR' AS Description,
                    'no Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_system_statistics_keyfigures_last_hour' AS Script_Name,
                    'system stats for last hour' AS Description,
                    'no Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_top_segments_awr' AS Script_Name,
                    'top segment stats by reads/block change/etc' AS Description,
                    'no Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'segment_space_largesttables' AS Script_Name,
                    'top 100 segment, break down by tab/ind/lob size' AS Description,
                    'no Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'io_stat_awr' AS Script_Name,
                    'IO related stats from AWR per hour' AS Description,
                    'no Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'ash' AS Script_Name,
                    'over all wait profile from ASH' AS Description,
                    '# of mins to go back' AS INPUT
   FROM dual
   UNION ALL SELECT 'plan_memory' AS Script_Name,
                    'explain plan from v$sql_plan/memory' AS Description,
                    'hash_value and %' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_table_modification' AS Script_Name,
                    'shows DML activity against a table, see script' AS Description,
                    'owner and table_name' AS INPUT
   FROM dual
   UNION ALL SELECT 'report_sql_plan_monitor' AS Script_Name,
                    'shows Real Time SQL Time Monitoring(11g)' AS Description,
                    'sql_id' AS INPUT
   FROM dual
   UNION ALL SELECT 'drop_tuning_task' AS Script_Name,
                    'Drops SQL Tuning task' AS Description,
                    'task name(select from list)' AS INPUT
   FROM dual
   UNION ALL SELECT 'awr_plan_stats' AS Script_Name,
                    '# of time sql exec with hash_vlue from AWR' AS Description,
                    'sql_id' AS INPUT
   FROM dual
   UNION ALL SELECT 'awr_plan_change_trend' AS Script_Name,
                    'SQL STATS HISTORY OVER TIME FROM AWR' AS Description,
                    'SQLID' AS INPUT
   FROM dual
   UNION ALL SELECT 'row_locking_info' AS Script_Name,
                    'shows specific row that is being blocked' AS Description,
                    'SID of session being blocked and then follow' AS INPUT
   FROM dual
   UNION ALL SELECT 'dba_views_text' AS Script_Name,
                    'shows underlying SQL that makes up the view' AS Description,
                    'owner and view name' AS INPUT
   FROM dual
   UNION ALL SELECT 'xplan_ash' AS Script_Name,
                    'show explan plan and lot more based on ash/hist' AS Description,
                    'sqlid or sid or child number(see output)' AS INPUT
   FROM dual
   UNION ALL SELECT 'sql_hint' AS Script_Name,
                    'shows all the hints used by cbo w/ or w/out otln' AS Description,
                    'SQLID' AS INPUT
   FROM dual
   UNION ALL SELECT 'create_sql_profile' AS Script_Name,
                    'create sql profile on paticular sql' AS Description,
                    'sqlid, childno, catagoery, force_matching' AS INPUT
   FROM dual
   UNION ALL SELECT 'move_sql_profile' AS Script_Name,
                    'Moves a SQL Profile from one statement to another' AS Description,
                    'profile name, sqlid(see output)' AS INPUT
   FROM dual
   UNION ALL SELECT 'fix_sql_profile_hint' AS Script_Name,
                    'replace hint in profile' AS Description,
                    'see header of script' AS INPUT
   FROM dual
   UNION ALL SELECT 'sql_profile_hints11' AS Script_Name,
                    'shows hints used by sql profile ' AS Description,
                    'see header of script' AS INPUT
   FROM dual
   UNION ALL SELECT 'profile_index_fixer_auto' AS Script_Name,
                    'Replaces hints in a sql profile automatically' AS Description,
                    'see header of script' AS INPUT
   FROM dual
   UNION ALL SELECT 'create_1_hint_sql_profile' AS Script_Name,
                    'Prompts for a hint and makes a profile out of it' AS Description,
                    'see header of script' AS INPUT
   FROM dual
   UNION ALL SELECT 'coe_xfr_sql_profile' AS Script_Name,
                    'creates a SQL PROFILE from mem or awr' AS Description,
                    'see header of script' AS INPUT
   FROM dual
   UNION ALL SELECT 'create_sql_profile_awr' AS Script_Name,
                    'creates a SQL PROFILE from awr based on pln hash' AS Description,
                    'see header of script' AS INPUT
   FROM dual
   UNION ALL SELECT 'sql_hints_awr' AS Script_Name,
                    'hints(outline data) used by SQL from AWR' AS Description,
                    'SQLID and plan_hash_value' AS INPUT
   FROM dual
   UNION ALL SELECT 'sql_hint_102' AS Script_Name,
                    'hints(outline data) used by SQL' AS Description,
                    'SQLID and child number' AS INPUT
   FROM dual
   UNION ALL SELECT 'sql_text_full_awr' AS Script_Name,
                    'SQL Text from dba_hist_sql_text' AS Description,
                    'SQLID' AS INPUT
   FROM dual
   UNION ALL SELECT 'segment_stat' AS Script_Name,
                    'segment Stats' AS Description,
                    'first stat name, then to user/object name' AS INPUT
   FROM dual
   UNION ALL SELECT 'awr_retention' AS Script_Name,
                    'Shows retention time and Snap time for AWR' AS Description,
                    'no Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_timedwaits_eventhistogram' AS Script_Name,
                    'Shows histogram of paticular wait event, inst startup' AS Description,
                    'Event Name' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_timedwaits_histogram_AWR_11g_trend' AS Script_Name,
                    'Shows histogram of paticular wait event from AWR' AS Description,
                    'Event Name' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_timedevents_eventmetric_60sec' AS Script_Name,
                    'shows wait profile from last 60 sec' AS Description,
                    'no Input Needed' AS INPUT
   FROM dual
   UNION ALL SELECT 'create_baseline' AS Script_Name,
                    'Create SPM Baseline 11g' AS Description,
                    'SQLID, HASH VALUE, FIXED, ACCEPTED,NAME' AS INPUT
   FROM dual
   UNION ALL SELECT 'baseline_info' AS Script_Name,
                    'Shows basic info from dba_sql_plan_baselines' AS Description,
                    'hit enter to see all baseline info' AS INPUT
   FROM dual
   UNION ALL SELECT 'baseline_hint' AS Script_Name,
                    'Shows hints that are used for a baseline' AS Description,
                    'Baseline plan Name' AS INPUT
   FROM dual
   UNION ALL SELECT 'baseline_info_more_plan' AS Script_Name,
                    'Shows explain plan, sql text for a specific plan' AS Description,
                    'Baseline plan Name' AS INPUT
   FROM dual
   UNION ALL SELECT 'baseline_info_more_handle' AS Script_Name,
                    'Shows explain plan, sql text etc for all plans' AS Description,
                    'Baseline sql handle' AS INPUT
   FROM dual
   UNION ALL SELECT 'drop_baseline' AS Script_Name,
                    'Drops a paticular baseline plan' AS Description,
                    'Baseline plan Name' AS INPUT
   FROM dual
   UNION ALL SELECT 'attach_baseline_one_sql_another' AS Script_Name,
                    'move good plan from one sql to another' AS Description,
                    'bad sqlid,chd#, good sqlid and good plan hash' AS INPUT
   FROM dual
   UNION ALL SELECT 'change_baseline_attribute' AS Script_Name,
                    'change a attribute value of baseline' AS Description,
                    'sql_handle, plan_name,attrb to change, new val' AS INPUT
   FROM dual
   UNION ALL SELECT 'perf_child_mismatch' AS Script_Name,
                    'show reason for multiple child(works good 11g)' AS Description,
                    'SQLID' AS INPUT
   FROM dual
   UNION ALL SELECT 'plan_sid' AS Script_Name,
                    'show explain plan for a paticular SID' AS Description,
                    'SID' AS INPUT
   FROM dual
   UNION ALL SELECT 'sql_tuning_task_output' AS Script_Name,
                    'show output of tuning task created earlier' AS Description,
                    'TASK NAME(SELECT FROM LIST)' AS INPUT
   FROM dual
   UNION ALL SELECT 'sql_color_11g' AS Script_Name,
                    'To track SQL, as not all SQL are captured in awr' AS Description,
                    'SQLID (11g+)' AS INPUT
   FROM dual
   UNION ALL SELECT 'awr_plan_x' AS Script_Name,
                    'SPOOL SQL Stats w/plans across awr and RAC' AS Description,
                    'SQLID' AS INPUT
   FROM dual
   UNION ALL SELECT 'change_sql_profile_attribute' AS Script_Name,
                    'change SQL Profile attributes' AS Description,
                    'profile_name,what_to_change,new_value' AS INPUT
   FROM dual
   UNION ALL SELECT 'baseline_to_sqlid' AS Script_Name,
                    'converts SQL_HANDLE to SQL_ID' AS Description,
                    'SQL_HANDLE(needs to run as sys)' AS INPUT
   FROM dual
   UNION ALL SELECT 'rman_backup_speed' AS Script_Name,
                    'shows backup speed(throughput mb/sec)' AS Description,
                    'no Input Needed' AS INPUT
   FROM dual
	 UNION ALL SELECT 'sql_wait_on_event_ash' AS Script_Name,
                    'Shows SQLID based on wait event for last XX mins' AS Description,
                    '# of mins to go back, Wait Event Name' AS INPUT
   FROM dual
	 UNION ALL SELECT 'perf_awr_wait_specific_seg_obj_tab' AS Script_Name,
                    'Shows Event time and count for specific table from AWR' AS Description,
                    'star/end date and then snapid, username, object_name' AS INPUT
   FROM dual
	 UNION ALL SELECT 'perf_awr_stat_specific_seg_obj_tab' AS Script_Name,
                    'Shows stats for specific table from AWR(reads,writes)' AS Description,
                    'star/end date and then snapid, username, object_name' AS INPUT
   FROM dual	 
	 UNION ALL SELECT 'perf_timewait_histogram_real_time' AS Script_Name,
                    'Shows histogram of paticular wait event, real time' AS Description,
                    '@scrpt_name 15 db%sequential (LOWER CASE)'                     AS INPUT
   FROM dual
	 UNION ALL SELECT 'last_sql_ash_sqlid_null'               AS Script_Name,
                    'shows list of sqlid out of ash for paticular SID' AS Description,
                    'SID, note:useful when SQLID is null for sess=ACTIVE'     AS INPUT
   FROM dual
	 UNION ALL SELECT 'top_seg_tab_obj_ash'                    AS Script_Name,
                    'top segment by tot wait time' AS Description,
                    '# of mins to go back'            AS INPUT
   FROM dual	 
	 UNION ALL SELECT 'v$_tab'                    AS Script_Name,
                    'shows list v$ views' AS Description,
                    'view name like'            AS INPUT
   FROM dual
	 UNION ALL SELECT 'dba_tab'                    AS Script_Name,
                    'shows list dba views' AS Description,
                    'view name like'            AS INPUT
   FROM dual
	 UNION ALL SELECT 'nls_parameter'                    AS Script_Name,
                    'shows list of current NLS setting for DB/INST/SESS' AS Description,
                    'no Input Needed'            AS INPUT
   FROM dual	 
	 UNION ALL SELECT 'table_usedspace_wasted'                    AS Script_Name,
                    'shows actual table size usage and wasted space' AS Description,
                    'table_owner and table_name'            AS INPUT
   FROM dual	 
	 UNION ALL SELECT 'diff_tab_stat_history'                    AS Script_Name,
                    'shows report on current stats and dictionary history(11g+)' AS Description,
                    'table_owner and table_name and timestamp'            AS INPUT
   FROM dual	 	 
	 UNION ALL SELECT 'ash_top'                    AS Script_Name,
                    'Wait class breakdown by diff grouping' AS Description,
                    'see header'            AS INPUT
   FROM dual	 
	 UNION ALL SELECT 'dash_top'                    AS Script_Name,
                    'historical Wait class breakdown by diff grouping' AS Description,
                    'see header'            AS INPUT
   FROM dual	 	 
   	 UNION ALL SELECT 'find_obj_via_file_n_block_id'                    AS Script_Name,
                    'List an Object via a Given File and Block ID' AS Description,
                    'file# and Block#'            AS INPUT
   FROM dual		
    UNION ALL SELECT 'dba_dependencies'                    AS Script_Name,
                    'tracking dependencies of an object' AS Description,
                    'username and object_name'            AS INPUT
   FROM dual		 	
    UNION ALL SELECT 'corrupt_block'                    AS Script_Name,
                    'List corrupt block and associated object name' AS Description,
                    'no Input Needed'            AS INPUT
   FROM dual		
        UNION ALL SELECT 'rman_backup_async_io'                    AS Script_Name,
                    'backup io info from v$BACKUP_ASYNC_IO' AS Description,
                    'start and end time'            AS INPUT
   FROM dual		
	     UNION ALL SELECT 'rman_backup_sync_io'                    AS Script_Name,
                    'backup io info from v$BACKUP_SYNC_IO' AS Description,
                    'start and end time'            AS INPUT
   FROM dual		
	     UNION ALL SELECT 'planx'                    AS Script_Name,
                    'detailed report regards to plan' AS Description,
                    'sqlid(11.2+)'            AS INPUT
   FROM dual		
	     UNION ALL SELECT 'sqlmon'                    AS Script_Name,
                    'detailed report regards to plan from SQL MONITOR' AS Description,
                    'sqlid(11.2+)'            AS INPUT
   FROM dual		
	     UNION ALL SELECT 'sqlash'                    AS Script_Name,
                    'ASH reports for SQL' AS Description,
                    'sqlid(11.2+)'            AS INPUT
   FROM dual		
	     UNION ALL SELECT 'dba_hist_ash_summaries_by_operations'                    AS Script_Name,
                    'summary of operations by event, wait_class, etc' AS Description,
                    'no Input Needed'            AS INPUT
   FROM dual		 
	     UNION ALL SELECT 'top_pga_mem'                    AS Script_Name,
                    'Top consumers of PGA memory' AS Description,
                    'no Input Needed'            AS INPUT
   FROM dual			 
	     UNION ALL SELECT 'wrka_mem'                    AS Script_Name,
                    'breakdown of mem workareas' AS Description,
                    'SID'            AS INPUT
   FROM dual			 
	     UNION ALL SELECT 'pga_mem'                    AS Script_Name,
                    'pga mem info w/ active workarea and histogram' AS Description,
                    'no Input Needed'            AS INPUT
   FROM dual			 	 
	     UNION ALL SELECT 'sample'                    AS Script_Name,
                    'Sample any V$ view and display aggregated results' AS Description,
                    'see header and warning'            AS INPUT
   FROM dual			 	 	 
	     UNION ALL SELECT 'perf_awr_top_sql_groupby_delta'                    AS Script_Name,
                    'top sql in awr group by metric given' AS Description,
                    'group_by, metric_name, start and end time'            AS INPUT
   FROM dual			 	 	 
	     UNION ALL SELECT 'perf_awr_top_sql_groupby_delta_multi_dimension'                    AS Script_Name,
                    'top sql in awr group by multiple metric given' AS Description,
                    'group_by, multiple metric_name, start and end time'            AS INPUT
   FROM dual			 	 	 
	     UNION ALL SELECT 'perf_awr_top_obj_seg_tab_max_event_metric'                    AS Script_Name,
                    'top 25 objects in awr by metric given' AS Description,
                    'metric_name, start and end time'            AS INPUT
   FROM dual			 	 	 	 	 
	 	     UNION ALL SELECT 'top_seg_tab_obj_awr_history'                    AS Script_Name,
                    'top segment by tot wait time' AS Description,
                    'start/end time and event(can be blank)'            AS INPUT
   FROM dual			 	 	 	 	
	 	     UNION ALL SELECT 'sql_wait_on_event_awr_history'                    AS Script_Name,
                    'SHOWS SQLID BASED ON WAIT EVENT for time frame provided' AS Description,
                    'start/end time and event(can be blank)'            AS INPUT
   FROM dual			 	 	 	 		
   UNION ALL SELECT 'dash' AS Script_Name,
                    'over all wait profile from dba hist ASH' AS Description,
                    'start/end time' AS INPUT
   FROM dual	 
	    UNION ALL SELECT 'find_sql_hist_ash_seg_obj_tab' AS Script_Name,
                    'find sqlid in given time frame for a paticular object' AS Description,
                    'start/end time and object name or part of sql text' AS INPUT
   FROM dual
	    UNION ALL SELECT 'find_sql_ash_seg_obj_tab' AS Script_Name,
                    'find sqlid, text in given time frame for a paticular object' AS Description,
                    'start/end time and object name  or part of sql text' AS INPUT
   FROM dual		
	    UNION ALL SELECT 'amm_info_mem' AS Script_Name,
                    'Infomation related to auto mem management' AS Description,
                    'no Input Needed' AS INPUT
   FROM dual		
	    UNION ALL SELECT 'ash_report_html' AS Script_Name,
                    'ASH Report in HTML format' AS Description,
                    'Inst id, start/end time -- if blank gives you last 15 mins' AS INPUT
   FROM dual		
	    UNION ALL SELECT 'asmm_info_mem' AS Script_Name,
                    'Infomation related to auto shared mem management' AS Description,
                    'no input needed' AS INPUT
   FROM dual		
	    UNION ALL SELECT 'osconfig' AS Script_Name,
                    'Give info related to OS stats - like cpu, mem ...' AS Description,
                    'no input needed' AS INPUT
   FROM dual		
	    UNION ALL SELECT 'sqlid_object_stats' AS Script_Name,
                    'Gives stats related info for all objects in a SQLID' AS Description,
                    '@SQLID_OBJECT_STATS SQLID and CHILD #' AS INPUT
   FROM dual			   
	 UNION ALL SELECT 'uptime' AS Script_Name,
                    'show how long instance has been up and history' AS Description,
                    'no input needed' AS INPUT
   FROM dual			    
	 UNION ALL SELECT 'whoami' AS Script_Name,
                    'shows info related to your session' AS Description,
                    'no input needed' AS INPUT
   FROM dual			   
	 UNION ALL SELECT 'transactions' AS Script_Name,
                    'transactions related info like duration, IO...' AS Description,
                    'no input needed' AS INPUT
   FROM dual		 
)
SELECT upper(script_name) AS "MY SCRIPT NAME",
       upper(description) AS description,
       upper(INPUT) AS INPUT
FROM my_scripts
WHERE script_name LIKE nvl('%&script_name_like%', script_name) ;