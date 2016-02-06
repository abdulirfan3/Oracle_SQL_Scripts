/**********************************************************************
 * File:        awr_stattrends.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        15-Jul-2003
 *
 * Description:
 *      Query to display "trends" for specific statistics captured in
 *      the AWR repository, and display summarized totals daily and
 *      hourly as a ratio using the RATIO_FOR_REPORT analytic function.
 *
 *      The intent is to find the readings with the greatest deviation
 *      from the average value, as these are likely to be "periods of
 *      interest" for further, more detailed research...
 *
 * Modifications:
 *      TGorman 09oct09 adapted from similar script for STATSPACK
 *********************************************************************/
set echo off feedback off timing off pagesize 200 linesize 200
set trimout on trimspool on verify off
col sort0 noprint
col day format a6 heading "Day"
col hr format a6 heading "Hour"
col value format 999,999,999,990.00 heading "Value"
col rtr format 990.00 heading "Ratio"
 
prompt
prompt Some useful database statistics to search upon:
col name format a60 heading "Name"
select  chr(9)||name name
from    v$statname
order by 1;
accept V_STATNAME prompt "What statistic do you want to analyze? "
 
col spoolname new_value V_SPOOLNAME noprint
select  replace(replace(replace(lower('&&V_STATNAME'),' ','_'),'(',''),')','') spoolname
from    dual;
 
--spool awr_stattrends_&&V_SPOOLNAME
clear breaks computes
break on report
col ratio format a50 heading "Percentage of total over all days"
col name format a30 heading "Statistic Name"
prompt
prompt Daily trends for "&&V_STATNAME"...
select  sort0,
        day,
        name,
        value,
        (ratio_to_report(value) over (partition by name)*100) rtr,
        rpad('*', round((ratio_to_report(value) over (partition by name)*100)/2, 0), '*') ratio
from    (select sort0,
                day,
                name,
                sum(value) value
         from   (select to_char(ss.end_interval_time, 'YYYYMMDD') sort0,
                        to_char(ss.end_interval_time, 'DD-MON') day,
                        s.snap_id,
                        s.stat_name name,
                        nvl(decode(greatest(s.value,
                                            nvl(lag(s.value) over (partition by s.dbid,
                                                                                s.instance_number,
                                                                                s.stat_name order by s.snap_id),0)),
                                   s.value,
                                   s.value - lag(s.value) over (partition by    s.dbid,
                                                                                s.instance_number,
                                                                                s.stat_name order by s.snap_id),
                                          s.value), 0) value
                 from   dba_hist_sysstat                        s,
                        dba_hist_snapshot                       ss
                 where  s.stat_name like '%'||'&&V_STATNAME'||'%'
                 and    ss.snap_id = s.snap_id
                 and    ss.dbid = s.dbid
                 and    ss.instance_number = s.instance_number)
         group by sort0,
                  day,
                  name)
order by sort0, name;
 
clear breaks computes
break on day skip 1 on hr on report
col ratio format a50 heading "Percentage of total over all hours for each day"
prompt
prompt Daily/hourly trends for "&&V_STATNAME"...
select  sort0,
        day,
        hr,
        name,
        value,
        (ratio_to_report(value) over (partition by day, name)*100) rtr,
        rpad('*', round((ratio_to_report(value) over (partition by day, name)*100)/2, 0), '*') ratio
from    (select sort0,
                day,
                hr,
                name,
                sum(value) value
         from   (select to_char(ss.end_interval_time, 'YYYYMMDDHH24') sort0,
                        to_char(ss.end_interval_time, 'DD-MON') day,
                        to_char(ss.end_interval_time, 'HH24')||':00' hr,
                        s.snap_id,
                        s.stat_name name,
                        nvl(decode(greatest(s.value,
                                   nvl(lag(s.value)
                                           over (partition by   s.dbid,
                                                                s.instance_number,
                                                                s.stat_name order by s.snap_id),0)),
                                   s.value,
                                   s.value - lag(s.value) over (partition by    s.dbid,
                                                                                s.instance_number,
                                                                                s.stat_name order by s.snap_id),
                                          s.value), 0) value
                 from   dba_hist_sysstat                        s,
                        dba_hist_snapshot                       ss
                 where  s.stat_name like '%'||'&&V_STATNAME'||'%'
                 and    ss.snap_id = s.snap_id
                 and    ss.dbid = s.dbid
                 and    ss.instance_number = s.instance_number)
         group by sort0,
                  day,
                  hr,
                  name)
order by sort0, name;
--spool off
def _editor = "C:\Program Files\Notepad++\notepad++.exe"
set pages 100 lines 1500
set termout on
--set time on
set timi on
--Sets the column separator character printed between columns in output.
SET COLSEP '|'
SET verify OFF
-- to remove spaces (white spaces)
SET tab off