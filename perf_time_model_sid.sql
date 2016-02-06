select  
        a.sid,
        b.username,
        a.stat_name,
        round((a.value / 1000000),3) time_secs
from    
        sys.v_$sess_time_model a,
        sys.v_$session b
where   
        a.sid = b.sid and
        b.sid = '&SID'
order by 
        4 desc;