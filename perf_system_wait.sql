Prompt
prompt +---------------------------------------------------------+
prompt |         % Of wait time Group by Wait_Class              |
Prompt +---------------------------------------------------------+
prompt
col wait_class format a15
col event format a30
select  WAIT_CLASS,
        TOTAL_WAITS,
        round(100 * (TOTAL_WAITS / SUM_WAITS),2) PCT_WAITS,
        ROUND((TIME_WAITED / 100),2) TIME_WAITED_SECS,
        round(100 * (TIME_WAITED / SUM_TIME),2) PCT_TIME
from
(select WAIT_CLASS,
        TOTAL_WAITS,
        TIME_WAITED
from    V$SYSTEM_WAIT_CLASS
where   WAIT_CLASS != 'Idle'),
(select  sum(TOTAL_WAITS) SUM_WAITS,
        sum(TIME_WAITED) SUM_TIME
from    V$SYSTEM_WAIT_CLASS
where   WAIT_CLASS != 'Idle')
order by 5 desc;

Prompt
prompt +---------------------------------------------------------+
prompt |         % Of wait time Group by Event                   |
Prompt +---------------------------------------------------------+
prompt

select  wait_class, event,
        TOTAL_WAITS,
        round(100 * (TOTAL_WAITS / SUM_WAITS),2) PCT_WAITS,
        ROUND((TIME_WAITED / 100),2) TIME_WAITED_SECS,
        round(100 * (TIME_WAITED / SUM_TIME),2) PCT_TIME
from
(select wait_class, event,
        TOTAL_WAITS,
        TIME_WAITED
from    v$system_event
where   WAIT_CLASS != 'Idle'),
(select  sum(TOTAL_WAITS) SUM_WAITS,
        sum(TIME_WAITED) SUM_TIME
from    v$system_event
where   WAIT_CLASS != 'Idle')
order by 5 desc;

Prompt
prompt +---------------------------------------------------------+
prompt |  Wait time over last hour for a paticular wait class    |
prompt |          Enter a paticular Wait Class                   |
Prompt +---------------------------------------------------------+
prompt

select  to_char(a.end_time,'DD-MON-YYYY HH24:MI:SS') end_time,
        b.wait_class,
        round((a.time_waited / 100),2) time_waited 
from    sys.v_$waitclassmetric_history a,
        sys.v_$system_wait_class b
where   a.wait_class# = b.wait_class# and
        b.wait_class != 'Idle'
		and b.wait_class ='&Wait_class'
order by 1,2;

undef wait_class;
undef event;