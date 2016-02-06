WITH   my_scripts   AS
(
           SELECT 'blocking_locks.sql'	            AS script_name, 'Shows blocking lock info' as description	FROM dual
UNION ALL  SELECT 'datafile.sql_io'	            AS script_name, 'Shows datafile info' as description 	FROM dual
UNION ALL  SELECT 'find_sql2_10g_io.sql'	            AS script_name, 'shows sql text, need to give sql_text like or/and sql_id' as description 	FROM dual
UNION ALL  SELECT 'find_sql_sid_i.sql'	            AS script_name, 'Shows sql based on SID' as description 	FROM dual
--UNION ALL  SELECT 'find_sql_sid_hash.sql'           AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'find_sql_stats_i.sql'	            AS script_name, 'Shows stats on paticular sql, Need to provide hash_value' as description 	FROM dual
UNION ALL  SELECT 'latchprof_i.sql'	            AS script_name, 'Shows latch info, look at latchprof_output.txt' as description 	FROM dual
UNION ALL  SELECT 'locks_blocking.sql'	    AS script_name, 'Shows blocking lock info' as description 	FROM dual
UNION ALL  SELECT 'metadata_tablespace_i.sql'         AS script_name, 'Shows metadata info for a specific tablespace' as description 	FROM dual
UNION ALL  SELECT 'sess_active.sql'	            AS script_name, 'Shows Active User Sessions' as description 	FROM dual
UNION ALL  SELECT 'sess_all.sql'	            AS script_name, 'Shows Active/Inactive User Sessions' as description 	FROM dual
UNION ALL  SELECT 'sess_by_cpu_active.sql'	    AS script_name, 'Shows Active User Sessions Ordered by CPU' as description 	FROM dual
UNION ALL  SELECT 'sess_by_cpu_all.sql'	            AS script_name, 'Shows ALL User Sessions Ordered by CPU' as description 	FROM dual
UNION ALL  SELECT 'sess_stats_i.sql'	            AS script_name, 'Shows sessions stats info based on input given like cpu, logical read etc' as description 	FROM dual
UNION ALL  SELECT 'session_wait_i.sql'	            AS script_name, 'Shows wait info for session(s)' as description 	FROM dual
UNION ALL  SELECT 'session_wait_active.sql'	    AS script_name, 'Shows all active session and there waits' as description 	FROM dual
UNION ALL  SELECT 'session_wait_block_10g_i.sql'	    AS script_name, 'Shows all active session and there waits and blocking locks if any' as description 	FROM dual
UNION ALL  SELECT 'snapper_i.sql'	                    AS script_name, 'See snapper_output.txt' as description 	FROM dual
UNION ALL  SELECT 'snapperloop_i.sql'	            AS script_name, 'See snapper_output.txt' as description 	FROM dual
UNION ALL  SELECT 'tablespace_info_io.sql'  	    AS script_name, 'Shows free/used tablespace info' as description 	FROM dual
UNION ALL  SELECT 'tempfile.sql'	            AS script_name, 'Shows temp file info free/used' as description 	FROM dual
UNION ALL  SELECT 'waitprof_i.sql'	            AS script_name, 'Shows detail info for waits for a session, see waitprof_output.txt' as description 	FROM dual
--UNION ALL  SELECT 'xplan_stats2.sql'	            AS script_name, 'datafile info' as description 	FROM dual
--UNION ALL  SELECT 'xpln.sql'	                    AS script_name, 'datafile info' as description 	FROM dual
--UNION ALL  SELECT 'xpln_stats.sql'	            AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'asm_clients.sql'                 AS script_name, 'Shows all the Clients/DB being used by ASM' as description 	FROM dual
UNION ALL  SELECT 'asm_diskgroups.sql'              AS script_name, 'Shows free/used space in all DG' as description 	FROM dual
UNION ALL  SELECT 'asm_disks.sql'                   AS script_name, 'Shows report of all disks contained within all DG' as description 	FROM dual
UNION ALL  SELECT 'asm_disks_perf.sql'              AS script_name, 'Shows al disks in all DG and there performance metrics' as description 	FROM dual
UNION ALL  SELECT 'asm_files2.sql'                  AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'asm_files.sql'                   AS script_name, 'Shows all files in all disk groups' as description 	FROM dual
UNION ALL  SELECT 'asm_alias.sql'                   AS script_name, 'Shows all files in all disk groups' as description 	FROM dual
UNION ALL  SELECT 'asm_drop_files.sql'              AS script_name, 'Used to create script that removes all ASM FILES ' as description 	FROM dual
UNION ALL  SELECT 'asm_files_10g.sql'               AS script_name, 'Shows all files in all disk groups' as description 	FROM dual
UNION ALL  SELECT 'asm_templates.sql'               AS script_name, 'Shows template information for all DG' as description 	FROM dual
UNION ALL  SELECT 'background_process.sql'          AS script_name, 'Shows info about background process' as description 	FROM dual
UNION ALL  SELECT 'datafile_like_io.sql'            AS script_name, 'Shows Datafile info by providing filename or path' as description 	FROM dual
UNION ALL  SELECT 'sess_user_transactions.sql'      AS script_name, 'Shows Table locking info and User Transactions info' as description 	FROM dual
UNION ALL  SELECT 'sess_query_sql_i.sql'            AS script_name, 'Shows sql_text, disk_reads, buffer_gets ' as description 	FROM dual
UNION ALL  SELECT 'sess_uncommited_trans_undo.sql'  AS script_name, 'Shows uncommited transaction info with # of undo redords/size' as description 	FROM dual
UNION ALL  SELECT 'sess_user_sessions.sql'          AS script_name, 'Shows info on # of sessions and # of active/inactive users' as description 	FROM dual
UNION ALL  SELECT 'sess_user_stats.sql'             AS script_name, 'Shows User Sessions and Statistics Ordered by Logical I/O -- Slow' as description 	FROM dual
UNION ALL  SELECT 'sess_user_stats_active.sql'      AS script_name, 'Shows User Sessions and Statistics Ordered by Logical I/O of Active users -- Slow' as description 	FROM dual
UNION ALL  SELECT 'sess_user_trace_file_loc.sql'    AS script_name, 'Shows Trace file location if tracing is turend on' as description 	FROM dual
UNION ALL  SELECT 'sess_users_by_cursors.sql'       AS script_name, 'Shows # of open cursors for a user' as description 	FROM dual
UNION ALL  SELECT 'sess_users_by_reads.sql'         AS script_name, 'Shows top user by IO/Reads' as description 	FROM dual
UNION ALL  SELECT 'sess_users_by_memory.sql'        AS script_name, 'Shows session by memory usage --slow' as description 	FROM dual
UNION ALL  SELECT 'sess_users_by_transactions.sql'  AS script_name, 'Shows  User Sessions Ordered by Number of Transactions' as description 	FROM dual
-- change in name UNION ALL  SELECT 'sess_users_query_active.sql'       AS script_name, 'Shows All Active User Sessions and Current SQL' as description 	FROM dual
-- chane in name UNION ALL  SELECT 'sess_users_query_all.sql'          AS script_name, 'Shows All User Sessions and Current SQL(active/inactive)' as description 	FROM dual
UNION ALL SELECT  'kellogg_prd_tbs.sql'             AS script_name, 'Kellogs prd tablespace info(<1.5)' as description      FROM dual
UNION ALL SELECT  'kellogg_ts.sql'                  AS script_name, 'Kellogs TS (<20)' as description      FROM dual
UNION ALL SELECT  'kellogg_prd_tbs_2.sql'           AS script_name, 'Kellogs prd tablespace info(<2)' as description      FROM dual
UNION ALL SELECT  'find_ospid_with_sid_i.sql'       AS script_name, 'Finds OS PID by giving in SID' as description      FROM dual
UNION ALL SELECT  'find_sid_with_ospid_i.sql'       AS script_name, 'Finds SID by giving in OSPOD' as description      FROM dual
UNION ALL SELECT  'sess_by_logical_read.sql'        AS script_name, 'Shows session by logical read' as description      FROM dual
UNION ALL SELECT  'sess_by_physical_read.sql'       AS script_name, 'Shows session by physical read' as description      FROM dual
UNION ALL SELECT  'awr_snapshots_dbtime.sql'        AS script_name, 'Shows snap ID and interval Time' as description      FROM dual
UNION ALL SELECT  'asmm_components.sql'             AS script_name, 'Shows info with regards to ASMM' as description      FROM dual
UNION ALL SELECT  'dba_controlfile_records.sql'     AS script_name, 'Shows Controlfile records info' as description      FROM dual
UNION ALL SELECT  'dba_controlfiles.sql'            AS script_name, 'Shows controlfile location and status' as description      FROM dual
UNION ALL SELECT  'parameter_i.sql'                 AS script_name, 'Shows DB Parameter info and current value' as description      FROM dual
UNION ALL SELECT  'dba_directories.sql'             AS script_name, 'Shows Directories created and there location' as description      FROM dual
UNION ALL SELECT  'dba_invalid_objects.sql'         AS script_name, 'Shows Invalid objects, object type, object name' as description      FROM dual
UNION ALL SELECT  'dba_invalid_objects_summary.sql' AS script_name, 'Shows Invalid objects, object type, object name in a summary' as description      FROM dual
UNION ALL SELECT  'datafile_like_round_io.sql'      AS script_name, 'Shows datafile info with free/used/max in datafile' as description      FROM dual
UNION ALL SELECT  'dba_jobs.sql'                    AS script_name, 'Shows jobs info schedule through dbms_jobs package' as description      FROM dual
UNION ALL SELECT  'dba_object_search_i.sql'         AS script_name, 'Searchs for object by providing object name and object owner info' as description      FROM dual
UNION ALL SELECT  'dba_object_summary.sql'          AS script_name, 'Shows a summary on how many objects/schema' as description      FROM dual
UNION ALL SELECT  'dba_options_installed.sql'       AS script_name, 'Shows a list of options installed in DB' as description      FROM dual
UNION ALL SELECT  'dba_owner_to_tablespace_segment.sql' AS script_name, 'Shows segment type, segment name, size, count and tablespace mapping' as description      FROM dual
UNION ALL SELECT  'all_hidden_parameters.sql'       AS script_name, 'Shows all hidden parameters and there value' as description      FROM dual
UNION ALL SELECT  'dba_registry.sql'                AS script_name, 'Shows Registry info and status' as description      FROM dual
UNION ALL SELECT  'dba_segment_summary.sql'         AS script_name, 'Shows segment type, size, count' as description      FROM dual
UNION ALL SELECT  'dba_table_info_i.sql'            AS script_name, 'Shows table info like colums, index, constraints, triggers etc' as description      FROM dual
UNION ALL SELECT  'segment_file_mapper_i.sql'       AS script_name, 'Shows all the object/size in a paticular file' as description      FROM dual
UNION ALL SELECT  'extent_block_mapper.sql'         AS script_name, 'Shows all the object/size in a paticular file and there block ID' as description      FROM dual
UNION ALL SELECT  'fra_alerts.sql'                  AS script_name, 'Shows any alerts with regards to FRA' as description      FROM dual
UNION ALL SELECT  'fra_files.sql'                   AS script_name, 'Shows all the files that are in FRA' as description      FROM dual
UNION ALL SELECT  'fra_status.sql'                  AS script_name, 'Shows status of FRA, size/free/used' as description      FROM dual
UNION ALL SELECT  'fra_db_log_files.sql'            AS script_name, 'Shows logs for FRA when using Flashback DB' as description      FROM dual
UNION ALL SELECT  'fra_db_redo_time_matrix.sql'     AS script_name, 'Shows redo log info when using Flashback DB' as description      FROM dual
UNION ALL SELECT  'fra_db_status.sql'               AS script_name, 'Shows Status when using Flashback DB' as description      FROM dual
UNION ALL SELECT  'locks_dml_ddl_10g.sql'           AS script_name, 'Shows lock type, object, wait_time etc for locks' as description      FROM dual
UNION ALL SELECT  'locks_dml_lock_time.sql'         AS script_name, 'Shows lock type, object, wait_time etc for locks' as description      FROM dual
UNION ALL SELECT  'perf_event_names.sql'            AS script_name, 'Shows event name and number' as description      FROM dual
UNION ALL SELECT  'dba_top_segments.sql'            AS script_name, 'Shows top segment by size' as description      FROM dual
UNION ALL SELECT  'perf_file_io_efficiency.sql'     AS script_name, 'Shows files IO stats, with reads/writes' as description      FROM dual
UNION ALL SELECT  'perf_file_io.sql'                AS script_name, 'Shows % of read/writes' as description      FROM dual
UNION ALL SELECT  'perf_log_switch_history_bytes_daily_all.sql'         AS script_name, 'Shows log switch info with regards to bytes' as description      FROM dual
UNION ALL SELECT  'perf_log_switch_history_count_daily_i.sql'       AS script_name, 'Shows log switch info with regards to count' as description      FROM dual
UNION ALL SELECT  'perf_log_switch_history_count_daily_all.sql'         AS script_name, 'Shows log switch info with regards to count' as description      FROM dual
UNION ALL SELECT  'perf_hit_ratio_by_session.sql'   AS script_name, 'Shows hit ration for all session' as description      FROM dual
UNION ALL SELECT  'perf_redo_log_contention.sql'    AS script_name, 'Shows redo log info with regards to contention' as description      FROM dual
UNION ALL SELECT  'perf_sga_free_pool.sql'          AS script_name, 'Shows free stats for each pool' as description      FROM dual
UNION ALL SELECT  'perf_sga_usage.sql'              AS script_name, 'Shows all components within the SGA' as description      FROM dual
--UNION ALL SELECT  'perf_shared_pool_memory.sql'     AS script_name, 'Shows free/used memory in shared pool' as description      FROM dual
UNION ALL SELECT  'perf_objects_wo_statistics_i.sql'  AS script_name, 'Show objects that do not have statistics collected on them' as description      FROM dual
UNION ALL  SELECT 'rac_waiting_sessions.sql'	    AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rac_sess_users_sql.sql'	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rac_sess_users_active.sql'	    AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rac_sess_users.sql'              AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rac_rollback_users.sql'	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rac_rollback_segments.sql'	    AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rac_locks_blocking.sql'	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rac_instances.sql'               AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'perf_top_sql_by_disk_reads.sql'	AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'perf_top_sql_by_buffer_gets.sql'	AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'perf_top_10_tables.sql'	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'perf_top_10_procedures.sql'	    AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rman_configuration.sql'  	    AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rman_controlfiles.sql'	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rman_progress.sql'        	    AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rman_spfiles.sql'                AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rman_rc_databases.sql'	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rman_backup_pieces.sql'  	    AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rman_backup_sets.sql'	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'sec_default_passwords.sql'  	    AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'sec_roles.sql'                   AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'sec_users.sql'        	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rollback_contention.sql'  	    AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'rollback_users.sql'   	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'temp_sort_users.sql'             AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'temp_status.sql'        	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'sp_list.sql'  	                AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'temp_sort_segment.sql' 	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'redo.sql'            	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'perf_wait_system.sql'   	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'dba_role_users.sql'     	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'dba_link.sql'         	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'near_max_extents.sql'   	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'unable_extend.sql'      	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'row_chain.sql'       	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'system_ts_objects.sql'  	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'dba_jobs_sys.sql'     	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'kellogg_ts_symphony.sql'	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'long_ops.sql'        	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'latch.sql'            	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'temp_size.sql'         	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'temp_sort_users2.sql'   	        AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'temp_sort_users_10.sql'   	    AS script_name, 'datafile info' as description 	FROM dual
UNION ALL  SELECT 'tablespace_info_gb.sql'   	    AS script_name, 'datafile info' as description 	FROM dual
)
SELECT	    script_name, description
FROM	    my_scripts
WHERE       script_name	LIKE nvl('%&script_name_like%', script_name )
order by    script_name
;