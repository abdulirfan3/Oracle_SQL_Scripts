prompt ############################################################################
prompt Group by options can be from below
prompt SQL_ID, MODULE, ACTION, SQL_PROFILE, FORCE_MATCHING_SIGNATURE
prompt Can also group by above and comma seperated, eg. sql_id, module
prompt 
prompt **********************************************************************
prompt Metric name can be from below
prompt EXECUTIONS_DELTA,DISK_READS_DELTA, BUFFER_GETS_DELTA, ROWS_PROCESSED_DELTA
prompt CPU_TIME_DELTA, ELAPSED_TIME_DELTA,IOWAIT_DELTA, APWAIT_DELTA, CCWAIT_DELTA
prompt DIRECT_WRITES_DELTA, PARSE_CALLS_DELTA, CLWAIT_DELTA, SORTS_DELTA
prompt FETCHES_DELTA, PX_SERVERS_EXECS_DELTA, LOADS_DELTA, INVALIDATIONS_DELTA
prompt
prompt For 11g+
prompt PHYSICAL_READ_REQUESTS_DELTA,PHYSICAL_READ_BYTES_DELTA
prompt PHYSICAL_WRITE_REQUESTS_DELTA,PHYSICAL_WRITE_BYTES_DELTA
prompt ############################################################################


prompt 
prompt
prompt 
accept group_by prompt "what to group by? "
accept metric1 prompt "Metric# 1 to look for? "
accept metric2 prompt "Metric# 2 to look for? "
accept metric3 prompt "Metric# 3 to look for? "
accept start_time prompt "Enter start time in format DD-MON-YYYY [HH24:MI]: "
accept end_time prompt "Enter end time in format DD-MON-YYYY [HH24:MI]: "


-- HEADING AND FORMAT FOR ONLY SOME COMMAN METRICS ONLY
COL sum(EXECUTIONS_DELTA) heading EXECUTION format 999,999,999,999
COL sum(DISK_READS_DELTA) heading DISK_READS format 999,999,999,999
COL sum(BUFFER_GETS_DELTA) Heading LOGICAL_READS format 999,999,999,999
COL sum(ROWS_PROCESSED_DELTA) HEADING ROWS_PROCESSED format 999,999,999,999
COL sum(CPU_TIME_DELTA) HEADING CPU_TIME(Micro-Sec) format 999,999,999,999
COL SUM(ELAPSED_TIME_DELTA) heading ELAPSED_TIME(Micro-Sec) format 999,999,999,999
COL sum(IOWAIT_DELTA) HEADING IO_WAIT(Micro-Sec) format 999,999,999,999
COL sum(APWAIT_DELTA) HEADING APPLICATION_WAIT format 999,999,999,999
COL sum(CCWAIT_DELTA) HEADING CLUSTER_WAIT format 999,999,999,999


col PCT_TOTAL_EXECUTIONS_DELTA heading %_TOT_EXEC
col PCT_TOTAL_ROWS_PROCESSED_DELTA heading %_TOT_ROWS
col PCT_TOTAL_ELAPSED_TIME_DELTA heading %_TOT_ELP_TIM
col PCT_TOTAL_DISK_READS_DELTA heading %_TOT_DSK_RD
col PCT_TOTAL_BUFFER_GETS_DELTA heading %_TOT_BUF_RD
col PCT_TOTAL_CPU_TIME_DELTA heading %_TOT_CPU_TIM
col PCT_TOTAL_IOWAIT_DELTA heading %_TOT_IOWAIT
col PCT_TOTAL_APWAIT_DELTA heading %_TOT_APWAIT
col PCT_TOTAL_CCWAIT_DELTA heading %_TOT_CCWAIT



prompt
Prompt Top 25 &group_by(grouped by) causing &metric1,&metric2,&metric3 between &start_time - &end_time
prompt

select * from (
select 
     &group_by, 
     sum(&metric1), 
		 sum(&metric2),
		 sum(&metric3),
     round(100*sum(&metric1)/sum(sum(&metric1))over(),3) pct_total_&metric1,
     round(100*sum(&metric2)/sum(sum(&metric2))over(),3) pct_total_&metric2,
     round(100*sum(&metric3)/sum(sum(&metric3))over(),3) pct_total_&metric3 		 
from dba_hist_sqlstat ss, 
    dba_hist_snapshot sn 
where ss.snap_id = sn.snap_id 
and sn.begin_interval_time between to_date(trim('&start_time.'),'dd-mon-yyyy hh24:mi')
and to_date(trim('&end_time.'),'dd-mon-yyyy hh24:mi')
group by &group_by 
order by sum(&metric1) desc
) where rownum < 26
/	

