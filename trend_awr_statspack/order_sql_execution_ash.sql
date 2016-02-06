Prompt This will list the SQL details of a session in the order that they executed(desc)
prompt if a query happens to be running when a sample is taken then its details get recorded, 
prompt if not then it will not appear and you may not even be aware that it has been run

/*
So, with Active Session History (often abbreviated to ASH), Oracle samples the database every second and stores details of every session
 that is considered “active”, meaning that it is waiting on a non-idle wait event or is executing on a CPU. These details are exposed 
 via the data dictionary view v$active_session_history (or gv$active_session_history if you’re operating a RAC environment).

A key detail to note is that the underlying data store for Active Session History is a circular memory buffer. Once the buffer is full 
then older entries are overwritten by new ones. The question that then arises is “how long will an entry remain in the buffer before 
being overwritten?”. Unfortunately there is no simple answer to that question as it depends on how many active sessions there have 
been in the database. You may find that it takes a day or more before details are overwritten or it could be a few hours or less. 
You can easily find out how much ASH history you have available by running the following query:

SELECT MIN(sample_time) AS min_sample_time
FROM   v$active_session_history

If you find that your process has aged out of Active Session History buffer then all is not quite lost. 
Every 10th sample from v$active_session_history is saved into the Active Workload Repository (AWR) and exposed
 via the view dba_hist_active_sess_history. From within v$active_session_history, you can tell 
 which samples have been saved from the flag stored in the IS_AWR_SAMPLE column. Unfortunately, 
 10 second samples are rather too infrequent to obtain a good idea of what a process did.

 So, what are the drawbacks to Active Session History? From a process monitoring perspective 
 it is important to realise that Oracle records details of what a session is doing as at 
 the point it takes the sample, as illustrated in the previous example. So, if in the one 
 second since the previous sample your process has run half a dozen SQL statements then only 
 the one that was being executed at the moment the sample was taken will be picked up. 
 This means that for fast OLTP-type processes it is unlikely that you will obtain details 
 of every statement issued by your process. If you require an in-depth analysis of what your 
 process is doing then obtaining an SQL Trace might be the way to go… but this will have to 
 be set-up prior to the execution of your process.
*/


SELECT ash.sql_id
,      ash.sql_child_number
,      ash.sql_exec_start
,      ash.sql_exec_id
,      TO_CHAR(MIN(ash.sample_time),'hh24:mi:ss') AS min_sample_time
,      TO_CHAR(MAX(ash.sample_time),'hh24:mi:ss') AS max_sample_time
,      s.sql_text
FROM   v$active_session_history ash
,      v$sql s
WHERE  ash.sql_id           = s.sql_id (+)
AND    ash.sql_child_number = s.child_number (+)
AND    ash.session_id       = '&SID'
AND    ash.session_serial#  = '&SERIAL#'
GROUP  BY
       ash.sql_id
,      ash.sql_child_number
,      s.sql_text
,      ash.sql_exec_start
,      ash.sql_exec_id
ORDER  BY
       MIN(ash.sample_time) desc
;