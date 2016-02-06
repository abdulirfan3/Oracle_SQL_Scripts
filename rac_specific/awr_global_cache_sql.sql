REM --------------------------------------------------------------------------------------------------
REM Author: Riyaj Shamsudeen @OraInternals, LLC
REM         www.orainternals.com
REM
REM Functionality: This script is to print RAC GCS stats from AWR for historical analysis.
REM **************
REM   Primary advantage is that we access AWR tables from one node and so we reduce global cache traffic.
REM
REM Source  : AWR tables
REM
REM Exectution type: Execute from sqlplus or any other tool.
REM
REM Parameters: No parameters. Uses Last snapshot and the one prior snap
REM No implied or explicit warranty
REM
REM Please send me an email to rshamsud@orainternals.com, if you enhance this script :-)
REM  This is a open Source code and it is free to use and modify.
REM --------------------------------------------------------------------------------------------------
prompt
set colsep '|'
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';
set pages 10000
set lines 220
col instance_number format 999
col begin_interval_time format A30
col startup_time format A30
select instance_number, 
       begin_interval_time, 
       snap_id, 
       startup_time, 
       cr_blks_recv_d, cr_tm_recv_d, 
       trunc(cr_tm_recv_d/decode( cr_blks_recv_d,0,-1,cr_blks_recv_d),4)*10 Avg_cr_rcv_ms,
       cur_blks_recv_d, cur_tm_recv_d, 
       trunc(cur_tm_recv_d/decode( cur_blks_recv_d,0,-1,cur_blks_recv_d),4)*10 Avg_cur_rcv_ms,
       cr_blks_serv_d, cur_blks_serv_d, 
       cr_blks_recv_d + cur_blks_recv_d + cr_blks_serv_d + cur_blks_serv_d total_blks
from (
select instance_number, 
       begin_interval_time, 
       snap_id, 
       startup_time,
       cr_blks_serv - lag(cr_blks_serv , 1, cr_blks_serv ) over ( partition by instance_number, startup_time order by instance_number, startup_time, snap_id)  cr_blks_serv_d,
       cr_blks_recv - lag(cr_blks_recv , 1, cr_blks_recv ) over ( partition by instance_number, startup_time order by instance_number, startup_time, snap_id)  cr_blks_recv_d,
       cr_tm_recv- lag(cr_tm_recv , 1, cr_tm_recv ) over ( partition by instance_number, startup_time order by instance_number, startup_time, snap_id)  cr_tm_recv_d,
       cur_blks_serv - lag(cur_blks_serv , 1, cur_blks_serv ) over ( partition by instance_number, startup_time order by instance_number, startup_time, snap_id)  cur_blks_serv_d,
       cur_blks_recv - lag(cur_blks_recv , 1, cur_blks_recv ) over ( partition by instance_number, startup_time order by instance_number, startup_time, snap_id)  cur_blks_recv_d,
       cur_tm_recv- lag(cur_tm_recv , 1, cur_tm_recv ) over ( partition by instance_number, startup_time order by instance_number, startup_time, snap_id)  cur_tm_recv_d
from        
(
select /* full (evt) full (snap) use_hash (snap) use_hash(evt) */  
   snap.snap_id, snap.begin_interval_time, snap.startup_time,snap.instance_number,
   evt_cr_serv.value cr_blks_serv, 
   evt_cr_recv.value cr_blks_recv, evt_cr_tm.value cr_tm_recv   ,
   evt_cur_serv.value cur_blks_serv, 
   evt_cur_recv.value cur_blks_recv, evt_cur_tm.value cur_tm_recv   
from 
     WRH$_SYSSTAT evt_cr_serv,
     WRH$_SYSSTAT evt_cr_recv,
     WRH$_SYSSTAT evt_cur_serv,
     WRH$_SYSSTAT evt_cur_recv,
     WRH$_SYSSTAT evt_cr_tm,
     WRH$_SYSSTAT evt_cur_tm,
     WRM$_SNAPSHOT snap  
where 
    evt_cr_recv.stat_id = (select stat_id from v$statname where name ='gc cr blocks received' )
and evt_cr_serv.stat_id =(select stat_id from v$statname where name='gc cr blocks served')
and evt_cur_recv.stat_id = (select stat_id from v$statname where name ='gc current blocks received' )
and evt_cur_serv.stat_id = (select stat_id from v$statname where name ='gc current blocks served' )
and evt_cr_tm.stat_id = (select stat_id from v$statname where name ='gc cr block receive time' )
and evt_cur_tm.stat_id = (select stat_id from v$statname where name='gc current block receive time')
and snap.snap_id =evt_cr_serv.snap_id
and snap.snap_id =evt_cr_recv.snap_id
and snap.snap_id =evt_cur_serv.snap_id
and snap.snap_id =evt_cur_recv.snap_id
and snap.snap_id =evt_cr_tm.snap_id
and snap.snap_id =evt_cur_tm.snap_id
and snap.instance_number =evt_cr_serv.instance_number
and snap.instance_number =evt_cr_recv.instance_number
and snap.instance_number =evt_cur_serv.instance_number
and snap.instance_number =evt_cur_recv.instance_number
and snap.instance_number =evt_cr_tm.instance_number
and snap.instance_number =evt_cur_tm.instance_number
and snap.begin_interval_time >= sysdate-60
--and snap.snap_time >= to_date ('10-JAN-2008 10:00','DD-MON-YYYY HH24:MI')
--and snap.snap_time <= to_date ('10-JAN-2008 23:59','DD-MON-YYYY HH24:MI')
--and to_number( to_char (snap_time, 'HH24')) between 08 and 18 
 )
)
order by instance_number,begin_interval_time
/
