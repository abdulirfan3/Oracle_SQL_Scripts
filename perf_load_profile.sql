col short_name  format a20              heading 'Load Profile'
col per_sec     format 999,999,999.9    heading 'Per Second'
col per_tx      format 999,999,999.9    heading 'Per Transaction'
-- set colsep '   '
Prompt
prompt +-----------------------------------------------------------+
prompt |             Load Profile for last 60 second               |
Prompt +-----------------------------------------------------------+
prompt
select lpad(short_name, 20, ' ') short_name
     , per_sec
     , per_tx from
    (select short_name
          , max(decode(typ, 1, value)) per_sec
          , max(decode(typ, 2, value)) per_tx
          , max(m_rank) m_rank 
       from
        (select /*+ use_hash(s) */ 
                m.short_name
              , s.value * coeff value
              , typ
              , m_rank
           from v$sysmetric s,
               (select 'Database Time Per Sec'                      metric_name, 'DB Time' short_name, .01 coeff, 1 typ, 1 m_rank from dual union all
                select 'CPU Usage Per Sec'                          metric_name, 'DB CPU' short_name, .01 coeff, 1 typ, 2 m_rank from dual union all
                select 'Redo Generated Per Sec'                     metric_name, 'Redo size' short_name, 1 coeff, 1 typ, 3 m_rank from dual union all
                select 'Logical Reads Per Sec'                      metric_name, 'Logical reads' short_name, 1 coeff, 1 typ, 4 m_rank from dual union all
                select 'DB Block Changes Per Sec'                   metric_name, 'Block changes' short_name, 1 coeff, 1 typ, 5 m_rank from dual union all
                select 'Physical Reads Per Sec'                     metric_name, 'Physical reads' short_name, 1 coeff, 1 typ, 6 m_rank from dual union all
                select 'Physical Writes Per Sec'                    metric_name, 'Physical writes' short_name, 1 coeff, 1 typ, 7 m_rank from dual union all
                select 'User Calls Per Sec'                         metric_name, 'User calls' short_name, 1 coeff, 1 typ, 8 m_rank from dual union all
                select 'Total Parse Count Per Sec'                  metric_name, 'Parses' short_name, 1 coeff, 1 typ, 9 m_rank from dual union all
                select 'Hard Parse Count Per Sec'                   metric_name, 'Hard Parses' short_name, 1 coeff, 1 typ, 10 m_rank from dual union all
                select 'Logons Per Sec'                             metric_name, 'Logons' short_name, 1 coeff, 1 typ, 11 m_rank from dual union all
                select 'Executions Per Sec'                         metric_name, 'Executes' short_name, 1 coeff, 1 typ, 12 m_rank from dual union all
                select 'User Rollbacks Per Sec'                     metric_name, 'Rollbacks' short_name, 1 coeff, 1 typ, 13 m_rank from dual union all
                select 'User Transaction Per Sec'                   metric_name, 'Transactions' short_name, 1 coeff, 1 typ, 14 m_rank from dual union all
                select 'User Rollback UndoRec Applied Per Sec'      metric_name, 'Applied urec' short_name, 1 coeff, 1 typ, 15 m_rank from dual union all
                select 'Redo Generated Per Txn'                     metric_name, 'Redo size' short_name, 1 coeff, 2 typ, 3 m_rank from dual union all
                select 'Logical Reads Per Txn'                      metric_name, 'Logical reads' short_name, 1 coeff, 2 typ, 4 m_rank from dual union all
                select 'DB Block Changes Per Txn'                   metric_name, 'Block changes' short_name, 1 coeff, 2 typ, 5 m_rank from dual union all
                select 'Physical Reads Per Txn'                     metric_name, 'Physical reads' short_name, 1 coeff, 2 typ, 6 m_rank from dual union all
                select 'Physical Writes Per Txn'                    metric_name, 'Physical writes' short_name, 1 coeff, 2 typ, 7 m_rank from dual union all
                select 'User Calls Per Txn'                         metric_name, 'User calls' short_name, 1 coeff, 2 typ, 8 m_rank from dual union all
                select 'Total Parse Count Per Txn'                  metric_name, 'Parses' short_name, 1 coeff, 2 typ, 9 m_rank from dual union all
                select 'Hard Parse Count Per Txn'                   metric_name, 'Hard Parses' short_name, 1 coeff, 2 typ, 10 m_rank from dual union all
                select 'Logons Per Txn'                             metric_name, 'Logons' short_name, 1 coeff, 2 typ, 11 m_rank from dual union all
                select 'Executions Per Txn'                         metric_name, 'Executes' short_name, 1 coeff, 2 typ, 12 m_rank from dual union all
                select 'User Rollbacks Per Txn'                     metric_name, 'Rollbacks' short_name, 1 coeff, 2 typ, 13 m_rank from dual union all
                select 'User Transaction Per Txn'                   metric_name, 'Transactions' short_name, 1 coeff, 2 typ, 14 m_rank from dual union all
                select 'User Rollback Undo Records Applied Per Txn' metric_name, 'Applied urec' short_name, 1 coeff, 2 typ, 15 m_rank from dual) m
          where m.metric_name = s.metric_name
            and s.intsize_csec > 5000
            and s.intsize_csec < 7000)
      group by short_name)
 order by m_rank;

Prompt
prompt +-----------------------------------------------------------+
prompt |  Deltas and Rates for 60 second and 15 second intervals   |
prompt |      INTSIZE_CSEC is hundredths of a second               |
Prompt +-----------------------------------------------------------+
prompt
 
select  METRIC_NAME,
        round(VALUE,3) Value, INTSIZE_CSEC
from    SYS.V_$SYSMETRIC
where   METRIC_NAME in ('CPU Usage Per Sec',
                      'CPU Usage Per Txn',
                      'Database CPU Time Ratio',
                      'Database Wait Time Ratio',
                      'Executions Per Sec',
                      'Executions Per Txn',
                      'Response Time Per Txn',
                      'SQL Service Response Time',
                      'User Transaction Per Sec', 'Average Active Sessions'
                       ,'Enqueue Waits Per Sec','Logical Reads Per Sec','Physical Reads Per Sec')
order by 1;
		
Prompt
prompt +---------------------------------------------------+
prompt |             Min/Max/Avg for last hour             |
Prompt +---------------------------------------------------+
prompt		

select  CASE METRIC_NAME
            WHEN 'SQL Service Response Time' then 'SQL Service Response Time (secs)'
            WHEN 'Response Time Per Txn' then 'Response Time Per Txn (secs)'
            ELSE METRIC_NAME
            END METRIC_NAME,
                CASE METRIC_NAME
            WHEN 'SQL Service Response Time' then ROUND((MINVAL / 100),2)
            WHEN 'Response Time Per Txn' then ROUND((MINVAL / 100),2)
            ELSE round(MINVAL,3)
            END MININUM,
                CASE METRIC_NAME
            WHEN 'SQL Service Response Time' then ROUND((MAXVAL / 100),2)
            WHEN 'Response Time Per Txn' then ROUND((MAXVAL / 100),2)
            ELSE round(MAXVAL,3)
            END MAXIMUM,
                CASE METRIC_NAME
            WHEN 'SQL Service Response Time' then ROUND((AVERAGE / 100),2)
            WHEN 'Response Time Per Txn' then ROUND((AVERAGE / 100),2)
            ELSE round(AVERAGE,3)
            END AVERAGE, round(STANDARD_DEVIATION,3) STANDARD_DEVIATION
from    SYS.V_$SYSMETRIC_SUMMARY 
where   METRIC_NAME in ('CPU Usage Per Sec',
                      'CPU Usage Per Txn',
                      'Database CPU Time Ratio',
                      'Database Wait Time Ratio',
                      'Executions Per Sec',
                      'Executions Per Txn',
                      'Response Time Per Txn',
                      'SQL Service Response Time',
                      'User Transaction Per Sec', 'Average Active Sessions'
                       ,'Enqueue Waits Per Sec','Logical Reads Per Sec','Physical Reads Per Sec')
ORDER BY 1;

Prompt
prompt +------------------------------------------------+
prompt |             Time Model Statistics              |
Prompt +------------------------------------------------+
prompt		
select  case db_stat_name
            when 'parse time elapsed' then 
                'soft parse time'
            else db_stat_name
            end db_stat_name,
        case db_stat_name
            when 'sql execute elapsed time' then 
                time_secs - plsql_time 
            when 'parse time elapsed' then 
                time_secs - hard_parse_time
            else time_secs
            end time_secs,
        case db_stat_name
            when 'sql execute elapsed time' then 
                round(100 * (time_secs - plsql_time) / db_time,2)
            when 'parse time elapsed' then 
                round(100 * (time_secs - hard_parse_time) / db_time,2)  
            else round(100 * time_secs / db_time,2)  
            end pct_time
from
(select stat_name db_stat_name,
        round((value / 1000000),3) time_secs
    from sys.v_$sys_time_model
    where stat_name not in('DB time','background elapsed time',
                            'background cpu time','DB CPU')),
(select round((value / 1000000),3) db_time 
    from sys.v_$sys_time_model 
    where stat_name = 'DB time'),
(select round((value / 1000000),3) plsql_time 
    from sys.v_$sys_time_model 
    where stat_name = 'PL/SQL execution elapsed time'),
(select round((value / 1000000),3) hard_parse_time 
    from sys.v_$sys_time_model 
    where stat_name = 'hard parse elapsed time')
order by 2 desc;		
