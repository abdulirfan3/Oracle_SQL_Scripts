prompt
accept sid prompt "Enter SID of the session in question :" 
prompt 

prompt basic breakdown of mem out of V$PROCESS_MEMORY

SELECT
    s.sid,pm.*
FROM 
    v$session s
  , v$process p
  , v$process_memory pm
WHERE
    s.paddr = p.addr
AND p.pid = pm.pid
AND s.sid='&sid'
ORDER BY
    sid
  , category
/	
COL wrka_operation_type HEAD OPERATION_TYPE FOR A30

prompt #################################################################
prompt
prompt breakdown of mem that are currently in-use in cursor workareas 
prompt from v$sql_workarea_active 
prompt
prompt #################################################################
SELECT 
    inst_id
  , sid
  , qcinst_id
  , qcsid
  , sql_id
--  , sql_exec_start -- 11g+
  , operation_type wrka_operation_type
  , operation_id plan_line
  , policy
  , ROUND(active_time/1000000,1) active_sec
  , actual_mem_used
  , max_mem_used
  , work_area_size
  , number_passes
  , tempseg_size
  , tablespace
FROM 
    gv$sql_workarea_active 
WHERE 
    sid='&sid'
ORDER BY
    sid
  , sql_hash_value
  , operation_id
/