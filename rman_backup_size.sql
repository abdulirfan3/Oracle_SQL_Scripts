column status format a10
column COMMAND_ID for a20
column time_taken_display format a10;
column input_bytes_display format a12;
column output_bytes_display format a12;
column output_bytes_per_sec_display format a10;
column ses_key format 9999999
column ses_recid format 9999999
column device_type format a10
column OutBytesPerSec for a13


SELECT b.session_key ses_key,
b.session_recid ses_recid,
b.session_stamp,
b.command_id,
b.input_type,
b.status,
to_char(b.start_time,'DD-MM-YY HH24:MI') "Start Time",
b.time_taken_display,
b.output_device_type device_type,
b.input_bytes_display,
b.output_bytes_display,
b.output_bytes_per_sec_display "OutBytesPerSec"
FROM v$rman_backup_job_details b
ORDER BY b.start_time asc;