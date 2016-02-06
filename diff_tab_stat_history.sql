set long 99999999;
set longchunksize 99999;
set pages 9999
prompt
Prompt Run STAT_HISTORY first to get timing info
prompt Enter data/time in following format YYYY-MM-DD HH24:MI:SS
prompt
select * from table(dbms_stats.diff_table_stats_in_history(
                    ownname => upper('&owner'),
                    tabname => upper('&tabname'),
                    time1 => systimestamp,
                    time2 => to_timestamp('&time2','yyyy-mm-dd:hh24:mi:ss'),
                    pctthreshold => 0));  
