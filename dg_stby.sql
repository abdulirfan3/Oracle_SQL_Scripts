--clear screen
set numw 8 lines 300 timing off echo off pages 10000
col name for a40
col dest_name for a20
col value for a18
col status for a12
col stby for a4
col error for a5
col type for a10
col destination for a25
col database_mode for a15
col db_unique_name for a14
col primary_db_unique_name for a22
col dg_broker for a9
col gap_status for a15
col error for a50
col RMAN1 for a60
col RMAN2 for a60
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
pro *** v$database ***
select DB_UNIQUE_NAME,OPEN_MODE,DATABASE_ROLE,REMOTE_ARCHIVE,SWITCHOVER_STATUS,DATAGUARD_BROKER DG_BROKER,PRIMARY_DB_UNIQUE_NAME
from v$database;
pro *** gv$archive_dest ***
SELECT thread#, dest_id, destination, gvad.status, target, schedule, process, mountid mid
FROM gv$archive_dest gvad, gv$instance gvi
WHERE gvad.inst_id = gvi.inst_id
AND schedule='ACTIVE'
AND destination is NOT NULL
ORDER BY thread#, dest_id
;
pro *** gv$archive_dest_status ***
select
s.DEST_ID,s.STATUS,s.DATABASE_MODE,s.RECOVERY_MODE,
s.GAP_STATUS, NVL(s.ERROR,'NONE') error
from gv$archive_dest_status s, gv$archive_dest d
where s.dest_id=d.dest_id
and d.schedule<>'INACTIVE'
and s.database_mode<>'UNKNOWN'
;
pro *** v$thread ***
select thread#,sequence# "CURRENT LOG SEQUENCE",status
from v$thread
;
pro *** gv$archived_log ***
select
dest_id, thread#, applied, max_seq, max_time,
max_seq-lead (max_seq) over (partition by thread# order by thread#) delta_seq,
(max_time-lead (max_time) over (partition by thread# order by thread#))*24*60 deta_min
from
(
select dest_id, thread#, applied, max(sequence#) max_seq, max(next_time) max_time
from gv$archived_log
where resetlogs_change#=(select resetlogs_change# from v$database)
and (inst_id,dest_id) in (select inst_id,dest_id from gv$archive_dest where schedule='ACTIVE' and target=(select decode(database_role,'PRIMARY','STANDBY','LOCAL') from v$database))
group by dest_id, thread#, applied
)
;
pro *** v$archive_gap ***
select * from v$archive_gap
;
pro *** GAP can also be verified using RMAN from STANDBY ***
select
'list archivelog from sequence '||sequence#||' thread '||thread#||';' RMAN1
from v$log_history where (thread#,first_time)
in (select thread#,max(first_time) from v$log_history group by thread#)
;
col name for a25
pro *** v$dataguard_stats ***
select name,value,unit
from v$dataguard_stats
where name like '%lag%'
;
pro *** gv$managed_standby ***
select PID,inst_id,thread#,process,client_process,status,sequence#,block#,DELAY_MINS
from gv$managed_standby
where BLOCK#>1
and status not in ('CLOSING','IDLE')
order by thread#, sequence#
;
