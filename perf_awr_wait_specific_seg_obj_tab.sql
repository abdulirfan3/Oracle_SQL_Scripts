prompt
prompt enter start and end times in format DD-MON-YYYY [HH24:MI]
Prompt Get the SNAP_ID first before getting to object wait
prompt
select SNAP_ID,BEGIN_INTERVAL_TIME,END_INTERVAL_TIME from dba_hist_snapshot sn
where sn.begin_interval_time between to_date(trim('&start_time.'),'dd-mon-yyyy hh24:mi')
and to_date(trim('&end_time.'),'dd-mon-yyyy hh24:mi') order by 1;


Prompt
Prompt Enter start_snap_id, end_snap_id, username, object_name
prompt
col Object_Name format a32
col Object_Type format a10
col Event_Name  format a40
select
  /*+ all_rows */
   ds.Instance        as Instance_Number
  ,ao.Object_Name     as Object_Name
  ,ao.Object_Type     as Object_Type
  ,ds.Event           as Event_Name
  ,sum(ds.Cnt)        as Event_Wait_Cnt
  ,sum(Time_Waited)   as Time_Waited
from
  (
   select    /*+ all_rows */
             au.Username
            ,e.Name          as Event
            ,count(*)        as Cnt
            ,sum(Wait_Time)  as Time_Waited
            ,da.Current_Obj# as Object_ID
            ,Instance_Number as Instance
   from
             dba_hist_active_sess_history da
            ,v$Event_Name e
            ,all_users   au
   where     da.Event_ID = e.Event_ID
   and       da.User_ID  = au.User_ID
   and       da.Snap_ID  between '&start_snap_id' and '&end_snap_id'
   and       au.Username = upper('&USER_NAME')
   group by  au.Username
            ,e.Name
            ,da.Current_Obj#
            ,da.Instance_Number
   order by 3 desc
  )                     ds
  ,dba_Objects          ao
where
          ao.Object_ID          = ds.Object_ID
and       ao.Object_name        like  upper('&OBJECT_NAME%')
--and       ao.Object_Type        in ('TABLE','INDEX')
-- Exclude SQL Client type of waits
and       ds.Event              not like 'SQL*Net%'
group by  ao.Object_Name
         ,ao.Object_Type
         ,ds.Event
         ,ds.Instance
order by 5 desc, 4
/