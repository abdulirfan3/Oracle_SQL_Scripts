/**********************************************************************
 * File:        awr_evtrends.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        15-Jul-2003
 *
 * Description:
 *      Query to display "trends" for specific wait-events captured in
 *      the AWR repository, and display summarized totals daily and
 *      hourly as a ratio using the RATIO_FOR_REPORT analytic function.
 *
 *      The intent is to find the readings with the greatest deviation
 *      from the average value, as these are likely to be "periods of
 *      interest" for further, more detailed research...
 *
 * Modifications:
 *      TGorman 25aug08 adapted from similar script for STATSPACK
 *      TGorman 22apr10 added average wait times
 *	TGorman 23mar11	added top-level rollup level as well snap-by-snap
 *			detailed level (if snaps taken more frequently
 *			than hourly)
 *********************************************************************/
set echo off feedback off timing off pagesize 500 linesize 160
set trimout on trimspool on verify off
col sort0 noprint
col day format a6 heading "Day"
col hr format a6 heading "Hour"
col event_name format a30 heading "Event Name"
col total_waits format 999,990 heading "Total|Waits (m)"
col time_waited format 999,990.00 heading "Secs|Waited"
col tot_wts format 990.00 heading "% Total|Waits"
col tot_pct format 990.00 heading "% Secs|Waited"
col avg_wait format 990.00 heading "Avg|hSecs|Per|Wait"
col avg_pct format 990.00 heading "% Avg|hSecs|Per|Wait"
col wt_graph format a18 heading "Graphical view|of % total|waits overall"
col tot_graph format a18 heading "Graphical view|of % total|secs waited overall"
col avg_graph format a18 heading "Graphical view|of % avg hSecs|per wait overall"

ttitle off
clear breaks computes
accept V_NBR_DAYS prompt "How many days of AWR information should we use? "

break on wait_class on report
prompt
prompt Some useful database wait-events upon which to search:
col wait_class format a20 heading "Wait Class"
col name format a60 heading "Name"
select  chr(9)||wait_class, name name
from    v$event_name
order by wait_class, name;
accept V_EVENTNAME prompt "Which wait-event from this list do you wish to analyze? "

col spoolname new_value V_SPOOLNAME noprint
col instance_name new_value V_INST_NAME noprint
col instance_number new_value V_INST_NBR noprint
col dbid new_value V_DBID noprint
select  replace(replace(replace(lower('&&V_EVENTNAME'),' ','_'),'(',''),')','') spoolname,
        i.instance_name,
	i.instance_number,
	d.dbid
from    v$instance i,
	v$database d;

--spool awr_evtrends_&&V_INST_NAME._&&V_SPOOLNAME

clear breaks computes
ttitle center 'Trends for waits on "&&V_EVENTNAME" over the past &&V_NBR_DAYS days' skip line
col total_waits format 999,990.00 heading "Waits (m)"
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
         from   (select s.event_name,
			s.snap_id,
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
                 where  s.event_name like '%'||'&&V_EVENTNAME'||'%'
		 and	s.instance_number = &&V_INST_NBR
		 and	s.dbid = &&V_DBID
                 and    ss.snap_id = s.snap_id
                 and    ss.dbid = s.dbid
                 and    ss.instance_number = s.instance_number
		 and	ss.begin_interval_time >= trunc(sysdate) - &&V_NBR_DAYS)
         group by event_name)
order by time_waited desc;

clear breaks computes
break on report
compute avg of total_waits on report
compute avg of time_waited on report
compute avg of avg_wait on report
ttitle center 'Daily trends for waits on "&&V_EVENTNAME" over the past &&V_NBR_DAYS days' skip line
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
			s.event_name,
                        s.snap_id,
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
                 where  s.event_name like '%'||'&&V_EVENTNAME'||'%'
		 and	s.instance_number = &&V_INST_NBR
		 and	s.dbid = &&V_DBID
                 and    ss.snap_id = s.snap_id
                 and    ss.dbid = s.dbid
                 and    ss.instance_number = s.instance_number
		 and	ss.begin_interval_time >= trunc(sysdate) - &&V_NBR_DAYS)
         group by sort_day,
                  day,
		  event_name)
order by sort0;

clear breaks computes
ttitle center 'Hourly trends for waits on "&&V_EVENTNAME" over the past &&V_NBR_DAYS days' skip line
col total_waits format 9,990.00 heading "Waits (m)"
break on day skip 1 on hr on report
compute avg of total_waits on report
compute avg of time_waited on report
compute avg of avg_wait on report
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
			s.event_name,
                        s.snap_id,
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
                 where  s.event_name like '%'||'&&V_EVENTNAME'||'%'
		 and	s.instance_number = &&V_INST_NBR
		 and	s.dbid = &&V_DBID
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
col avg_snap_frequency new_value V_AVG_SNAP_FREQUENCY noprint
select	decode(greatest(count(*), &&V_NBR_DAYS * 4), &&V_NBR_DAYS * 4, 'HOURLY', 'MULTIPLE TIMES/HOUR') avg_snap_frequency
from	(select count(*) cnt
	 from   dba_hist_snapshot
	 where  begin_interval_time >= trunc(sysdate) - &&V_NBR_DAYS
	 and    dbid = &&V_DBID
	 and    instance_number = &&V_INST_NBR
	 group by trunc(begin_interval_time, 'HH24')
	 having count(*) > 1);

clear breaks computes
ttitle center 'Snapshot-by-snapshot trends for waits on "&&V_EVENTNAME" over the past &&V_NBR_DAYS days' skip line
col total_waits format 9,990.00 heading "Waits (m)"
REM break on day skip 1 on hr on report
REM compute avg of total_waits on report
REM compute avg of time_waited on report
REM compute avg of avg_wait on report
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
			s.event_name,
                        s.snap_id,
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
		 and	s.event_name like '%'||'&&V_EVENTNAME'||'%'
		 and	s.instance_number = &&V_INST_NBR
		 and	s.dbid = &&V_DBID
                 and    ss.snap_id = s.snap_id
                 and    ss.dbid = s.dbid
                 and    ss.instance_number = s.instance_number
		 and	ss.begin_interval_time >= trunc(sysdate) - &&V_NBR_DAYS))
order by sort0;

--spool off
ttitle off
clear breaks computes