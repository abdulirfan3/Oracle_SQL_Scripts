prompt
prompt +------------------------------------------------+
prompt |    Enter start and end times in Below format   |
prompt |             yyyy-mm-dd hh24:mi:ss              |
prompt |     Run rman_info_all to get start/end time    |
prompt +------------------------------------------------+
prompt  
prompt


set pages 35;
col buffer_count format 999 heading BUF_CNT
--col TOTAL_GB format 9999 heading TOT_GB
col open_time format a20
col close_time format a20
col filename format a100


SELECT SID, TYPE, buffer_size, buffer_count, total_bytes/1024/1024/1024 "TOTAL_GB",
       TO_CHAR (open_time, 'DD-MON-YY hh24:mi:ss') open_time,
       TO_CHAR (close_time, 'DD-MON-YY hh24:mi:ss') close_time,
       ROUND (elapsed_time * 0.000166666667, 2) elapsed_min,
       ROUND (effective_bytes_per_second / 1024 / 1024, 2) mb_per_sec,
               set_count, SHORT_WAITS,LONG_WAITS,IO_COUNT ,LONG_WAITS/IO_COUNT, filename, MAXOPENFILES
  FROM v$backup_async_io
 WHERE open_time BETWEEN TO_DATE ('&start_date_time',
                                  'yyyy-mm-dd hh24:mi:ss'
                                 )
                     AND TO_DATE ('&end_date_time',
                                  'yyyy-mm-dd hh24:mi:ss'
                                 ) 					
order by open_time;																 
--get backup set to zoom in on specific datafile backup(as fileperset=1 in our script)																 
--and set_count = nvl('&set_count', set_count)
--and filename = nvl('&filename', filename)
--and type = nvl('&type', type)



