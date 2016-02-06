col "Input size" format a14
col "output size" format a14
col "time_taken_display" format a10
col "output/sec" format a14
set pages 1000
col cf for 9,999
col df for 9,999
col elapsed_seconds heading "ELAPSED|SECONDS"
col i0 for 9,999
col i1 for 9,999
col l for 9,999
col output_mbytes for 9,999,999 heading "OUTPUT|MBYTES"
col session_recid for 999999 heading "SESSION|RECID"
col session_stamp for 99999999999 heading "SESSION|STAMP"
col status for a20 trunc
col time_taken_display for a10 heading "TIME|TAKEN"
col output_instance for 9999 heading "OUT|INST"

set pages 35
select * from(
select
  J.DB_NAME,j.session_recid, j.session_stamp, j.session_key,
  j.time_taken_display,
  x.cf, x.df, x.i0, x.i1, x.l,
   j.input_bytes_display as "Input Size", j.output_bytes_display "Output Size", j.output_bytes_per_sec_display as "Output/Sec", j.status, j.input_type,
  decode(to_char(j.start_time, 'd'), 1, 'Sunday', 2, 'Monday',
                                     3, 'Tuesday', 4, 'Wednesday',
                                     5, 'Thursday', 6, 'Friday',
                                     7, 'Saturday') dow,
  j.elapsed_seconds,
 to_char(j.start_time, 'yyyy-mm-dd hh24:mi:ss') start_time,
  to_char(j.end_time, 'yyyy-mm-dd hh24:mi:ss') end_time
 -- x.cf, x.df, x.i0, x.i1, x.l
--  ro.inst_id output_instance
from RMAN.RC_RMAN_BACKUP_JOB_DETAILS j
  left outer join (select
                     d.session_recid, d.session_stamp,
                     sum(case when d.controlfile_included = 'BACKUP' then d.pieces else 0 end) CF,
                     sum(case when d.controlfile_included = 'NO'
                               and d.backup_type||d.incremental_level = 'D' then d.pieces else 0 end) DF,
                     sum(case when d.backup_type||d.incremental_level = 'D0' then d.pieces else 0 end) I0,
                     sum(case when d.backup_type||d.incremental_level = 'I1' then d.pieces else 0 end) I1,
                     sum(case when d.backup_type = 'L' then d.pieces else 0 end) L
                   from
                     RMAN.RC_BACKUP_SET_DETAILS d
                     join RMAN.RC_BACKUP_SET s on s.set_stamp = d.set_stamp and s.set_count = d.set_count
                   where s.input_file_scan_only = 'NO'
                   group by d.session_recid, d.session_stamp) x
    on x.session_recid = j.session_recid and x.session_stamp = j.session_stamp
 /* left outer join (select o.session_recid, o.session_stamp, min(inst_id) inst_id
                   from RC_RMAN_OUTPUT o
                   group by o.session_recid, o.session_stamp)
    ro on ro.session_recid = j.session_recid and ro.session_stamp = j.session_stamp */
where j.start_time > trunc(sysdate)-&NUMBER_OF_DAYS
order by j.start_time )
where db_name=upper('&db_name');

PROMPT ########################
PROMPT Legends for Above Col 
PROMPT ########################
PROMPT CF: Number of controlfile backups included in the backup set
PROMPT DF: Number of datafile full backups included in the backup set
PROMPT I0: Number of datafile incremental level-0 backups included in the backup set
PROMPT I1: Number of datafile incremental level-1 backups included in the backup set
PROMPT L: Number of archived log backups included in the backup set



PROMPT
PROMPT
PROMPT
PROMPT Enter SESSION_KEY FROM ABOVE TO LOOK AT BACKUP SET DETAILS
PROMPT Each backup job is uniquely identified by session_key listed by query above.
PROMPT 
col backup_type for a4 heading "TYPE"
col controlfile_included heading "CF?"
col incremental_level heading "INCR LVL"
col pieces for 999 heading "PCS"
col elapsed_seconds heading "ELAPSED|SECONDS"
col device_type for a10 trunc heading "DEVICE|TYPE"
col compressed for a4 heading "ZIP?"
col output_mbytes for 9,999,999 heading "OUTPUT|MBYTES"
col input_file_scan_only for a4 heading "SCAN|ONLY"

select
  d.bs_key, d.backup_type, CASE when d.controlfile_included='BACKUP' THEN 'YES' ELSE 'NO' END AS controlfile_included, d.incremental_level, d.pieces,
  to_char(d.start_time, 'yyyy-mm-dd hh24:mi:ss') start_time,
  to_char(d.completion_time, 'yyyy-mm-dd hh24:mi:ss') completion_time,
  d.elapsed_seconds, d.device_type, d.compressed, (d.output_bytes/1024/1024) output_mbytes, s.input_file_scan_only
from RMAN.RC_BACKUP_SET_DETAILS d
  join RMAN.RC_BACKUP_SET s on s.set_stamp = d.set_stamp and s.set_count = d.set_count
where session_key = &SESSION_KEY
order by  d.bs_key,d.start_time;


PROMPT
PROMPT
PROMPT
PROMPT Enter SESSION_KEY FROM ABOVE TO LOOK AT JOB OUTPUT LOG, IF AVAIABLE
PROMPT 
set pages 1000

select output
from RMAN.RC_RMAN_OUTPUT
where SESSION_KEY=&SESSION_KEY
ORDER BY RECID;



