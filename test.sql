SELECT x.*, (SELECT sql_text from dba_hist_sqltext t where t.sql_id = x.sql_id and rownum = 1) txt
FROM (
SELECT sn.snap_id
,      TO_CHAR(sn.end_interval_time,'DD-MON-YYYY HH24:MI') dt
,      st.sql_id
,      st.instance_number
,      st.parsing_schema_name
,      st.plan_hash_value
,      SUM(st.fetches_delta) fch
,      SUM(rows_processed_delta) rws
,      SUM(executions_delta)     execs
,      ROUND(SUM(elapsed_time_delta)/1000/1000)   elp
,      ROUND(SUM(elapsed_time_delta)/1000/1000/NVL(NULLIF(SUM(executions_delta),0),1),2)   elpe
,      ROUND(SUM(cpu_time_delta)/1000/1000)       cpu
,      SUM(buffer_gets_delta)    gets
,      ROUND(SUM(iowait_delta)/1000/1000)         io
,      ROUND(SUM(clwait_delta)/1000/1000)         cl
,      ROUND(SUM(ccwait_delta)/1000/1000)         cc
,      ROUND(SUM(apwait_delta)/1000/1000)         ap
,      ROUND(SUM(plsexec_time_delta)/1000/1000)   pl
,      ROUND(SUM(disk_reads_delta))         disk_reads
,      ROUND(SUM(direct_writes_delta))        direct_writes
,      ROW_NUMBER() over (PARTITION BY sn.dbid, sn.snap_id, st.instance_number
                          ORDER BY SUM(elapsed_time_delta) desc) rn
FROM   dba_hist_snapshot sn
,      dba_hist_sqlstat  st
WHERE  st.dbid            = sn.dbid
AND    st.snap_id         = sn.snap_id
AND    sn.instance_number = st.instance_number
GROUP BY 
       sn.dbid
,      sn.snap_id
,      sn.end_interval_time
,      st.sql_id
,      st.instance_number
,      st.parsing_schema_name
,      st.plan_hash_value
) x
WHERE rn <= 5
ORDER by snap_id DESC, instance_number, rn;