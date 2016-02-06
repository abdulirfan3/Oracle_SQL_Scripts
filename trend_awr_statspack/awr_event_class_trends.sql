/**********************************************************************
 * File:        awr_evclasstrends.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        23-Mar 2011
 *
 * Description:
 *      Query to display "trends" for event-classes captured in
 *      the AWR repository, and display summarized totals daily and
 *      hourly as a ratio using the RATIO_FOR_REPORT analytic function.
 *
 *      The intent is to find the readings with the greatest deviation
 *      from the average value, as these are likely to be "periods of
 *      interest" for further, more detailed research...
 *
 * Modifications:
 *********************************************************************/
set echo off feedback off timing off pagesize 500 linesize 160
set trimout on trimspool on verify off
col sort0 noprint
col day format a6 heading "Day"
col hr format a6 heading "Hour"
col tm format a6 heading "Time"
col wait_class format a20 heading "Wait Class Name"
col event_name format a25 truncate heading "Event Name"
col total_waits format 999,990 heading "Total|Waits (m)"
col time_waited format 999,990.00 heading "Secs|Waited"
col tot_wts format 990.00 heading "% Total|Waits"
col tot_pct format 990.00 heading "% Secs|Waited"
col avg_wait format 990.00 heading "Avg|hSecs|Per|Wait"
col avg_pct format 990.00 heading "% Avg|hSecs|Per|Wait"
col wt_graph format a20 heading "Graphical view|of % total|waits overall"
col tot_graph format a20 heading "Graphical view|of % total|secs waited overall"
col avg_graph format a20 heading "Graphical view|of % avg hSecs|per wait overall"
ttitle off
clear breaks computes

col instance_name new_value V_INST_NAME noprint
col instance_number new_value V_INST_NBR noprint
col dbid new_value V_DBID noprint
select  i.instance_name,
	i.instance_number,
	d.dbid
from    v$instance i,
	v$database d;

accept V_NBR_DAYS prompt "How many days of AWR information should we use? "
ttitle center 'Wait Class totals over the past &&V_NBR_DAYS days' skip line
col total_waits format 999,999,990.00 heading "Waits (m)"
col time_waited format 999,999,990.00 heading "Secs|Waited"
prompt
select  wait_class,
        total_waits/1000000 total_waits,
        (ratio_to_report(total_waits) over ()*100) tot_wts,
        rpad('*', round((ratio_to_report(total_waits) over ()*100)/6, 0), '*') wt_graph,
        time_waited,
        (ratio_to_report(time_waited) over ()*100) tot_pct,
        rpad('*', round((ratio_to_report(time_waited) over ()*100)/6, 0), '*') tot_graph,
        avg_wait*100 avg_wait,
        (ratio_to_report(avg_wait) over ()*100) avg_pct,
        rpad('*', round((ratio_to_report(avg_wait) over ()*100)/6, 0), '*') avg_graph
from    (select wait_class,
                sum(total_waits) total_waits,
                sum(time_waited)/1000000 time_waited,
                decode(sum(total_waits),0,0,(sum(time_waited)/sum(total_waits))/1000000) avg_wait
         from   (select s.snap_id,
			s.wait_class,
                        nvl(decode(greatest(s.time_waited_micro,
                                            lag(s.time_waited_micro,1,0)
                                                    over (partition by  s.dbid,
                                                                        s.instance_number
                                                          order by s.snap_id)),
                                   s.time_waited_micro,
                                   s.time_waited_micro - lag(s.time_waited_micro)
                                                             over (partition by s.dbid,
                                                                                s.instance_number
                                                                   order by s.snap_id),
                                          s.time_waited_micro), 0) time_waited,
                        nvl(decode(greatest(s.total_waits,
                                            lag(s.total_waits,1,0)
                                                    over (partition by  s.dbid,
                                                                        s.instance_number
                                                          order by s.snap_id)),
                                   s.total_waits,
                                   s.total_waits - lag(s.total_waits)
                                                             over (partition by s.dbid,
                                                                                s.instance_number
                                                                   order by s.snap_id),
                                          s.total_waits), 0) total_waits
                 from   dba_hist_system_event                   s,
                        dba_hist_snapshot                       ss
		 where	s.dbid = &&V_DBID
		 and	s.instance_number = &&V_INST_NBR
                 and    ss.snap_id = s.snap_id
                 and    ss.dbid = s.dbid
                 and    ss.instance_number = s.instance_number
		 and	ss.begin_interval_time >= trunc(sysdate) - &&V_NBR_DAYS)
         group by wait_class)
order by time_waited desc;
prompt 
accept V_INPUT_CLASSNAME prompt "What wait-event class do you want to analyze? "

ttitle off
clear breaks computes
col classname new_value V_CLASSNAME noprint
col spoolname new_value V_SPOOLNAME noprint
select	initcap('&&V_INPUT_CLASSNAME') classname,
	replace(replace(replace(replace(lower('&&V_INPUT_CLASSNAME'),' ','_'),'(',''),')',''),'/','') spoolname
from	dual;

--spool awr_evclasstrends_&&V_INST_NAME._&&V_SPOOLNAME
clear breaks computes
break on day on report
ttitle center 'Trends for waits on class "&&V_CLASSNAME" over the past &&V_NBR_DAYS days' skip line
col total_waits format 999,990.00 heading "Waits (m)"
col time_waited format 999,990.00 heading "Secs|Waited"
prompt
select  event_name,
        total_waits/1000000 total_waits,
        (ratio_to_report(total_waits) over ()*100) tot_wts,
        rpad('*', round((ratio_to_report(total_waits) over ()*100)/6, 0), '*') wt_graph,
        time_waited,
        (ratio_to_report(time_waited) over ()*100) tot_pct,
        rpad('*', round((ratio_to_report(time_waited) over ()*100)/6, 0), '*') tot_graph,
        avg_wait*100 avg_wait,
        (ratio_to_report(avg_wait) over ()*100) avg_pct,
        rpad('*', round((ratio_to_report(avg_wait) over ()*100)/6, 0), '*') avg_graph
from    (select event_name,
                sum(total_waits) total_waits,
                sum(time_waited)/1000000 time_waited,
                decode(sum(total_waits),0,0,(sum(time_waited)/sum(total_waits))/1000000) avg_wait
         from   (select s.snap_id,
			s.event_name,
                        nvl(decode(greatest(s.time_waited_micro,
                                            lag(s.time_waited_micro,1,0)
                                                    over (partition by  s.dbid,
                                                                        s.instance_number
                                                          order by s.snap_id)),
                                   s.time_waited_micro,
                                   s.time_waited_micro - lag(s.time_waited_micro)
                                                             over (partition by s.dbid,
                                                                                s.instance_number
                                                                   order by s.snap_id),
                                          s.time_waited_micro), 0) time_waited,
                        nvl(decode(greatest(s.total_waits,
                                            lag(s.total_waits,1,0)
                                                    over (partition by  s.dbid,
                                                                        s.instance_number
                                                          order by s.snap_id)),
                                   s.total_waits,
                                   s.total_waits - lag(s.total_waits)
                                                             over (partition by s.dbid,
                                                                                s.instance_number
                                                                   order by s.snap_id),
                                          s.total_waits), 0) total_waits
                 from   dba_hist_system_event                   s,
                        dba_hist_snapshot                       ss
                 where  s.wait_class = '&&V_CLASSNAME'
		 and	s.dbid = &&V_DBID
		 and	s.instance_number = &&V_INST_NBR
                 and    ss.snap_id = s.snap_id
                 and    ss.dbid = s.dbid
                 and    ss.instance_number = s.instance_number
		 and	ss.begin_interval_time >= trunc(sysdate) - &&V_NBR_DAYS)
         group by event_name)
order by time_waited desc;

clear breaks computes
break on day on report
ttitle center 'Daily trends for waits on class "&&V_CLASSNAME" over the past &&V_NBR_DAYS days' skip line
col total_waits format 999,990.00 heading "Waits (m)"
prompt
select  sort_day || trim(to_char(999999999999999-time_waited,'000000000000000')) sort0,
        day,
	event_name,
        total_waits/1000000 total_waits,
        (ratio_to_report(total_waits) over ()*100) tot_wts,
        rpad('*', round((ratio_to_report(total_waits) over ()*100)/6, 0), '*') wt_graph,
        time_waited,
        (ratio_to_report(time_waited) over ()*100) tot_pct,
        rpad('*', round((ratio_to_report(time_waited) over ()*100)/6, 0), '*') tot_graph,
        avg_wait*100 avg_wait,
        (ratio_to_report(avg_wait) over ()*100) avg_pct,
        rpad('*', round((ratio_to_report(avg_wait) over ()*100)/6, 0), '*') avg_graph
from    (select sort_day,
                day,
		event_name,
                sum(total_waits) total_waits,
                sum(time_waited)/1000000 time_waited,
                decode(sum(total_waits),0,0,(sum(time_waited)/sum(total_waits))/1000000) avg_wait
         from   (select to_char(ss.begin_interval_time, 'YYYYMMDD') sort_day,
                        to_char(ss.begin_interval_time, 'DD-MON') day,
                        s.snap_id,
			s.event_name,
                        nvl(decode(greatest(s.time_waited_micro,
                                            lag(s.time_waited_micro,1,0)
                                                    over (partition by  s.dbid,
                                                                        s.instance_number
                                                          order by s.snap_id)),
                                   s.time_waited_micro,
                                   s.time_waited_micro - lag(s.time_waited_micro)
                                                             over (partition by s.dbid,
                                                                                s.instance_number
                                                                   order by s.snap_id),
                                          s.time_waited_micro), 0) time_waited,
                        nvl(decode(greatest(s.total_waits,
                                            lag(s.total_waits,1,0)
                                                    over (partition by  s.dbid,
                                                                        s.instance_number
                                                          order by s.snap_id)),
                                   s.total_waits,
                                   s.total_waits - lag(s.total_waits)
                                                             over (partition by s.dbid,
                                                                                s.instance_number
                                                                   order by s.snap_id),
                                          s.total_waits), 0) total_waits
                 from   dba_hist_system_event                   s,
                        dba_hist_snapshot                       ss
                 where  s.wait_class = '&&V_CLASSNAME'
		 and	s.dbid = &&V_DBID
		 and	s.instance_number = &&V_INST_NBR
                 and    ss.snap_id = s.snap_id
                 and    ss.dbid = s.dbid
                 and    ss.instance_number = s.instance_number
		 and	ss.begin_interval_time >= trunc(sysdate) - &&V_NBR_DAYS)
         group by sort_day,
                  day,
		  event_name)
order by sort0;

clear breaks computes
ttitle center 'Hourly trends for waits on class "&&V_CLASSNAME" over the past &&V_NBR_DAYS days' skip line
col total_waits format 9,990.00 heading "Waits (m)"
break on day skip 1 on hr on report
prompt
select  sort_hr || trim(to_char(999999999999999-time_waited,'000000000000000')) sort0,
        day,
        hr,
	event_name,
        total_waits/1000000 total_waits,
        (ratio_to_report(total_waits) over (partition by day)*100) tot_wts,
        rpad('*', round((ratio_to_report(total_waits) over (partition by day)*100)/4, 0), '*') wt_graph,
        time_waited,
        (ratio_to_report(time_waited) over (partition by day)*100) tot_pct,
        rpad('*', round((ratio_to_report(time_waited) over (partition by day)*100)/4, 0), '*') tot_graph,
        avg_wait*100 avg_wait,
        (ratio_to_report(avg_wait) over (partition by day)*100) avg_pct,
        rpad('*', round((ratio_to_report(avg_wait) over (partition by day)*100)/4, 0), '*') avg_graph
from    (select sort_hr,
                day,
                hr,
		event_name,
                sum(total_waits) total_waits,
                sum(time_waited)/1000000 time_waited,
                decode(sum(total_waits),0,0,(sum(time_waited)/sum(total_waits))/1000000) avg_wait
         from   (select to_char(ss.begin_interval_time, 'YYYYMMDDHH24') sort_hr,
                        to_char(ss.begin_interval_time, 'DD-MON') day,
                        to_char(ss.begin_interval_time, 'HH24')||':00' hr,
                        s.snap_id,
			event_name,
                        nvl(decode(greatest(s.time_waited_micro,
                                   lag(s.time_waited_micro,1,0)
                                           over (partition by   s.dbid,
                                                                s.instance_number
                                                 order by s.snap_id)),
                                   s.time_waited_micro,
                                   s.time_waited_micro - lag(s.time_waited_micro)
                                                             over (partition by s.dbid,
                                                                                s.instance_number
                                                                   order by s.snap_id),
                                          s.time_waited_micro), 0) time_waited,
                        nvl(decode(greatest(s.total_waits,
                                   lag(s.total_waits,1,0)
                                           over (partition by   s.dbid,
                                                                s.instance_number
                                                 order by s.snap_id)),
                                   s.total_waits,
                                   s.total_waits - lag(s.total_waits)
                                                             over (partition by s.dbid,
                                                                                s.instance_number
                                                                   order by s.snap_id),
                                          s.total_waits), 0) total_waits
                 from   dba_hist_system_event                   s,
                        dba_hist_snapshot                       ss
                 where  s.wait_class = '&&V_CLASSNAME'
		 and	s.dbid = &&V_DBID
		 and	s.instance_number = &&V_INST_NBR
                 and    ss.snap_id = s.snap_id
                 and    ss.dbid = s.dbid
                 and    ss.instance_number = s.instance_number
		 and	ss.begin_interval_time >= trunc(sysdate) - &&V_NBR_DAYS)
         group by sort_hr,
                  day,
                  hr,
		  event_name)
order by sort0;

ttitle off
clear breaks computes
col avg_snap_frequency new_value V_AVG_SNAP_FREQUENCY noprint
select  decode(greatest(count(*), &&V_NBR_DAYS * 4), &&V_NBR_DAYS * 4, 'HOURLY', 'MULTIPLE TIMES/HOUR') avg_snap_frequency
from    (select count(*) cnt
         from   dba_hist_snapshot
         where  begin_interval_time >= trunc(sysdate) - &&V_NBR_DAYS
         and    dbid = &&V_DBID
         and    instance_number = &&V_INST_NBR
         group by trunc(begin_interval_time, 'HH24')
         having count(*) > 1);

ttitle center 'Snapshot-by-snapshot trends for waits on class "&&V_CLASSNAME" over the past &&V_NBR_DAYS days' skip line
select  sort_snap || trim(to_char(999999999999999-time_waited,'000000000000000')) sort0,
        day,
        tm,
	event_name,
        total_waits/1000000 total_waits,
        (ratio_to_report(total_waits) over (partition by day)*100) tot_wts,
        rpad('*', round((ratio_to_report(total_waits) over (partition by day)*100)/4, 0), '*') wt_graph,
        time_waited,
        (ratio_to_report(time_waited) over (partition by day)*100) tot_pct,
        rpad('*', round((ratio_to_report(time_waited) over (partition by day)*100)/4, 0), '*') tot_graph,
        avg_wait*100 avg_wait,
        (ratio_to_report(avg_wait) over (partition by day)*100) avg_pct,
        rpad('*', round((ratio_to_report(avg_wait) over (partition by day)*100)/4, 0), '*') avg_graph
from    (select sort_snap,
                day,
                tm,
		event_name,
                total_waits total_waits,
                time_waited/1000000 time_waited,
                decode(total_waits,0,0,((time_waited/total_waits)/1000000)) avg_wait
         from   (select to_char(ss.begin_interval_time, 'YYYYMMDDHH24MI') sort_snap,
                        to_char(ss.begin_interval_time, 'DD-MON') day,
                        to_char(ss.begin_interval_time, 'HH24:MI') tm,
                        s.snap_id,
			event_name,
                        nvl(decode(greatest(s.time_waited_micro,
                                   lag(s.time_waited_micro,1,0)
                                           over (partition by   s.dbid,
                                                                s.instance_number
                                                 order by s.snap_id)),
                                   s.time_waited_micro,
                                   s.time_waited_micro - lag(s.time_waited_micro)
                                                             over (partition by s.dbid,
                                                                                s.instance_number
                                                                   order by s.snap_id),
                                          s.time_waited_micro), 0) time_waited,
                        nvl(decode(greatest(s.total_waits,
                                   lag(s.total_waits,1,0)
                                           over (partition by   s.dbid,
                                                                s.instance_number
                                                 order by s.snap_id)),
                                   s.total_waits,
                                   s.total_waits - lag(s.total_waits)
                                                             over (partition by s.dbid,
                                                                                s.instance_number
                                                                   order by s.snap_id),
                                          s.total_waits), 0) total_waits
                 from   dba_hist_system_event                   s,
                        dba_hist_snapshot                       ss
                 where  '&&V_AVG_SNAP_FREQUENCY' <> 'HOURLY'
		 and	s.wait_class = '&&V_CLASSNAME'
		 and	s.dbid = &&V_DBID
		 and	s.instance_number = &&V_INST_NBR
                 and    ss.snap_id = s.snap_id
                 and    ss.dbid = s.dbid
                 and    ss.instance_number = s.instance_number
		 and	ss.begin_interval_time >= trunc(sysdate) - &&V_NBR_DAYS))
order by sort0;

--spool off
ttitle off
clear breaks computes
set feedback 6 verify on pagesize 100 echo off linesize 1500
set pages 100 lines 1500
set termout on
--set time on
set timi on
--Sets the column separator character printed between columns in output.
SET COLSEP '|'
SET verify OFF
-- to remove spaces (white spaces)
SET tab off
set arraysize 100;