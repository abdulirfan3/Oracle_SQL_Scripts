set verify off
--set lines 150
set pages 9999
	column child_wait  format a30
	column parent_wait format a30
	column inst_id format 9999  heading 'Node'
	column server_name format a4  heading 'Name'
	column x_status    format a10 heading 'Status'
	column schemaname  format a10 heading 'Schema'
	column x_sid format 9990 heading 'Sid'
	column x_pid format 9990 heading 'Pid'
	column p_sid format 9990 heading 'Parent'

	break on p_sid skip 1

	select distinct v.inst_id 
             , x.server_name
	     , x.status as x_status
	     , x.pid as x_pid
	     , x.sid as x_sid
	     , w2.sid as p_sid
	     , v.osuser
	     , v.schemaname
	     , w1.event as child_wait
	     , w2.event as parent_wait
	from  v$px_process x
	    , v$lock l
	    , gv$session v
	    , v$session_wait w1
	    , v$session_wait w2
	where x.sid <> l.sid(+)
	and   to_number (substr(x.server_name,2)) = l.id2(+)
	and   x.sid = w1.sid(+)
	and   l.sid = w2.sid(+)
	and   x.sid = v.sid(+)
	and   nvl(l.type,'PS') = 'PS'
        and   x.status like nvl('&status',x.status)
        and substr(x.server_name,2,1) != 'Z'
	order by p_sid, 1,2
/