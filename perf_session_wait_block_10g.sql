-- Usage:       @sw <sid>
--              @sw 52,110,225
-- 	        @sw "select sid from v$session where username = 'XYZ'"
--              @sw &mysid
--
-- Version - Coskan Gundogar : 
--  add extra columns by joining with v$session like  sql_id child number blocking session username
--  buffer busy and read by another session events related info 
--  
--------------------------------------------------------------------------------


col sw_event 	head EVENT for a40 truncate
col sw_p1transl head P1TRANSL for a42
col sw_sid		head SID for 999999
col sw_p1       head P1 for a25 justify right word_wrap
col sw_p2       head P2 for a25 justify right word_wrap
col sw_p3       head P3 for a25 justify right word_wrap
col chn format 999
col blckng_sid format 9999999
col blckng_inst format a12
col blckng_sid_status format a12
col username format a5


WITH W as(
 select rownum class#, class from v$waitstat)
select 
	sw.sid sw_sid,substr(username,1,5) username, 
	CASE WHEN sw.state != 'WAITING' THEN 'WORKING'
	     ELSE 'WAITING'
	END AS state, 
	CASE WHEN sw.state != 'WAITING' THEN 'On CPU / runqueue'
	     ELSE sw.event
	END AS sw_event, 
	sw.seq#, 
	sw.seconds_in_wait sec_in_state, s.sql_id,s.sql_child_number chn,
	NVL2(sw.p1text,sw.p1text||'= ',null)||CASE WHEN sw.P1 < 536870912 THEN to_char(sw.P1) ELSE '0x'||rawtohex(sw.P1RAW) END SW_P1,
	NVL2(sw.p2text,sw.p2text||'= ',null)||CASE WHEN sw.P2 < 536870912 THEN to_char(sw.P2) ELSE '0x'||rawtohex(sw.P2RAW) END SW_P2,
	NVL2(sw.p3text,sw.p3text||'= ',null)||CASE WHEN sw.P3 < 536870912 THEN to_char(sw.P3) ELSE '0x'||rawtohex(sw.P3RAW) END SW_P3,
	CASE 
		WHEN sw.event like 'cursor:%' THEN
		    '0x'||trim(to_char(sw.p1, 'XXXXXXXXXXXXXXXX'))
		WHEN sw.event like 'enq%' AND sw.state = 'WAITING' THEN 
		    '0x'||trim(to_char(sw.p1, 'XXXXXXXXXXXXXXXX'))||': '||
		    chr(bitand(sw.p1, -16777216)/16777215)||
		    chr(bitand(sw.p1,16711680)/65535)||
		    ' mode '||bitand(sw.p1, power(2,14)-1)
		WHEN sw.event like 'enq%' AND sw.state = 'WAITING' THEN 
			'0x'||trim(to_char(sw.p1, 'XXXXXXXXXXXXXXXX'))||': '||
			chr(bitand(sw.p1, -16777216)/16777215)||
			chr(bitand(sw.p1,16711680)/65535)||
			' mode'||bitand(sw.p1, power(2,14)-1)
		WHEN (sw.event like 'buffer busy%' or sw.event like 'read by %') AND sw.state='WAITING' THEN
		(select w.class from  w where  w.class#(+)=sw.p3)|| (select '  obj='||object_name||' type='||object_type from dba_objects o where o.objecT_id(+)=s.ROW_WAIT_OBJ#)
		WHEN sw.event like 'latch%' AND sw.state = 'WAITING' THEN 
			  '0x'||trim(to_char(sw.p1, 'XXXXXXXXXXXXXXXX'))||': '||(
			  		select name||'[par' 
			  			from v$latch_parent 
			  			where addr = hextoraw(trim(to_char(sw.p1,rpad('0',length(rawtohex(addr)),'X'))))
			   		union all
			   		select name||'[c'||child#||']' 
				   		from v$latch_children 
			  			where addr = hextoraw(trim(to_char(sw.p1,rpad('0',length(rawtohex(addr)),'X'))))
			  )
		WHEN sw.event like 'library cache pin' THEN
                         '0x'||RAWTOHEX(sw.p1raw)
	ELSE NULL END AS sw_p1transl,blocking_session blckng_sid,blocking_session_status blckng_sid_status,blocking_instance blckng_inst
FROM 
	v$session_wait sw,v$session s
WHERE 
	sw.sid IN (&SID)
	and sw.sid=s.sid
ORDER BY
	state,
	sw_event,
	sql_id,
	SW_P1,
        sql_id,
	SW_P2,	
	SW_P3
/

