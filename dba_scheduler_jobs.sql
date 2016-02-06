col owner format a6
col job_name format a20
col comments format a20 word_wrap
col program_owner format a6 
col program_name format a15 word_wrap 
col job_type format  a12
col state format a9 
col job_action format a20 word_wrap
col schedule_name format a20 word_wrap
col schedule_type format a14
col repeat_interval format a20 word_wrap 
col last_start_date format a25 word_wrap
col last_run_duration format a25 word_wrap
col next_run_date format a25 word_wrap

select owner, job_name, comments, program_owner, program_name, job_type,  state, 
       job_action, schedule_name, schedule_type, repeat_interval, 
       last_start_date, last_run_duration, next_run_date
       From dba_scheduler_jobs;