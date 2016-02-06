--------------------------------------------------------------------------------
-- xplan_awr - run automatically xplan.sql on all SQL statements recorded in the AWR view 
--             dba_hist_sqlstat whose run-time execution statistic values exceed configurable thresholds,
--             and that are still present in gv$sql.
--             See xplan.sql header for required privileges.
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

set null "" trimspool on define on escape off lines 250 pages 50000 tab off arraysize 100 
set echo off verify off feedback off termout on timing off head off

spool xplan_awr.lst

with params as (
  select 1  as num_days,
         08 as hour_start,
         12 as hour_end,
         01 as inst_id_min,
         01 as inst_id_max,
         3.0 as thresh_perc_elapsed,
         10.0 as thresh_perc_cpu,
         10.0 as thresh_perc_buffer_gets,
         7 as thresh_rank_elapsed,
         5 as thresh_rank_cpu,
         5 as thresh_rank_buffer_gets
    from dual
), base as (
  select s.instance_number as inst_id, s.snap_id, s.sql_id, 
         s.elapsed_time_delta,
         s.cpu_time_delta, 
         s.buffer_gets_delta, 
         s.disk_reads_delta, 
         s.executions_delta,
         sn.end_interval_time
    from dba_hist_sqlstat s, dba_hist_snapshot sn
   where s.dbid = (select dbid from v$database)
     and s.dbid            = sn.dbid
     and s.instance_number = sn.instance_number
     and s.snap_id         = sn.snap_id
     and sn.end_interval_time >= trunc(systimestamp) - (select num_days from params)
     and extract (hour from sn.end_interval_time) 
         between (select hour_start from params)
             and (select hour_end   from params) - 1
     and s.instance_number between (select inst_id_min from params) and (select inst_id_max from params)
     and s.executions_delta > 0
     and s.parsing_schema_name not in ('SYS', 'SYSTEM')
), classif as (
  select base.*,
         100 * ratio_to_report (elapsed_time_delta) over(partition by inst_id, snap_id) as elapsed_time_delta_perc,
         100 * ratio_to_report (cpu_time_delta    ) over(partition by inst_id, snap_id) as cpu_time_delta_perc,
         100 * ratio_to_report (buffer_gets_delta ) over(partition by inst_id, snap_id) as buffer_gets_delta_perc,
         100 * ratio_to_report (disk_reads_delta  ) over(partition by inst_id, snap_id) as disk_reads_delta_perc,
         100 * ratio_to_report (executions_delta  ) over(partition by inst_id, snap_id) as executions_delta_perc,
         rank() over (partition by inst_id, snap_id order by elapsed_time_delta desc) as elapsed_time_delta_rank,
         rank() over (partition by inst_id, snap_id order by cpu_time_delta     desc) as cpu_time_delta_rank,
         rank() over (partition by inst_id, snap_id order by buffer_gets_delta  desc) as buffer_gets_delta_rank,
         rank() over (partition by inst_id, snap_id order by disk_reads_delta   desc) as disk_reads_delta_rank,
         rank() over (partition by inst_id, snap_id order by executions_delta   desc) as executions_delta_rank
    from base
), selection as (
  select classif.*
    from classif
   where elapsed_time_delta_perc >= (select thresh_perc_elapsed     from params)
      or cpu_time_delta_perc     >= (select thresh_perc_cpu         from params)
      or buffer_gets_delta_perc  >= (select thresh_perc_buffer_gets from params)
      or elapsed_time_delta_rank <= (select thresh_rank_elapsed     from params)
      or cpu_time_delta_rank     <= (select thresh_rank_cpu         from params)
      or buffer_gets_delta_rank  <= (select thresh_rank_buffer_gets from params)
), still_there as (
  select selection.*
    from selection
   where (sql_id, inst_id) in (select sql_id, inst_id from gv$sql where executions > 0 and parse_calls > 0)
), pre_display as ( 
  select still_there.*, rank() over (partition by sql_id, inst_id order by elapsed_time_delta_perc) as display_row  
    from still_there
), display as (
  select '-- ' || sql_id
     || ' sn: ' || to_char (end_interval_time, 'yyyymmdd_hh24miss')
     || ' time:'  || to_char(elapsed_time_delta, '999999999990') || to_char (round (elapsed_time_delta_perc, 0),'90.0') || '% ' || to_char (round (elapsed_time_delta_rank, 0),'90') || '#'
     || ' cpu:'   || to_char(cpu_time_delta    , '999999999990') || to_char (round (cpu_time_delta_perc    , 0),'90.0') || '% ' || to_char (round (cpu_time_delta_rank    , 0),'90') || '#'
     || ' gets:'  || to_char(buffer_gets_delta , '999999990'   ) || to_char (round (buffer_gets_delta_perc , 0),'90.0') || '% ' || to_char (round (buffer_gets_delta_rank , 0),'90') || '#'
     || ' disk:'  || to_char(disk_reads_delta  , '999999990'   ) || to_char (round (disk_reads_delta_perc  , 0),'90.0') || '% ' || to_char (round (disk_reads_delta_rank  , 0),'90') || '#'
     as header
        , sql_id, inst_id, display_row
   from pre_display
  union all 
  select '@xplan "" "sql_id=' || sql_id || ',inst_id='||inst_id||',tabinfos=bottom"'
        , sql_id, inst_id, 1e6 as display_row
   from pre_display 
  where display_row = 1
)
select header from display
order by sql_id, inst_id, display_row;

spool off

@xplan_awr.lst
