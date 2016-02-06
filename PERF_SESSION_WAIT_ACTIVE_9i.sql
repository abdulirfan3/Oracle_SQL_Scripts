col sw_event    head EVENT for a40 truncate
col sw_p1transl head P1TRANSL for a42
col sw_sid      head SID for 999999

col sw_p1       head P1 for a18 justify right
col sw_p2       head P2 for a18 justify right
col sw_p3       head P3 for a18 justify right
select 
    sw.sid sw_sid, 
	s.PROGRAM,
    CASE WHEN sw.state != 'WAITING' THEN 'WORKING'
         ELSE 'WAITING'
    END AS state, 
    CASE WHEN sw.state != 'WAITING' THEN 'On CPU / runqueue'
         ELSE sw.event
    END AS sw_event, 
    sw.seq#, 
    sw.seconds_in_wait sec_in_wait, 
	s.SQL_HASH_VALUE,
--	s.sql_id        /*  for 10g n above */
    lpad(CASE WHEN sw.P1 < 536870912 THEN to_char(sw.P1) ELSE '0x'||rawtohex(sw.P1RAW) END, 18) SW_P1,
    lpad(CASE WHEN sw.P2 < 536870912 THEN to_char(sw.P2) ELSE '0x'||rawtohex(sw.P2RAW) END, 18) SW_P2,
    lpad(CASE WHEN sw.P3 < 536870912 THEN to_char(sw.P3) ELSE '0x'||rawtohex(sw.P3RAW) END, 18) SW_P3,
    CASE 
        WHEN sw.event like 'cursor:%' THEN
            '0x'||trim(to_char(sw.p1, 'XXXXXXXXXXXXXXXX'))
                WHEN sw.event like 'enq%' AND sw.state = 'WAITING' THEN 
            '0x'||trim(to_char(sw.p1, 'XXXXXXXXXXXXXXXX'))||': '||
            chr(bitand(sw.p1, -16777216)/16777215)||
            chr(bitand(sw.p1,16711680)/65535)||
            ' mode '||bitand(sw.p1, power(2,14)-1)
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
    ELSE NULL END AS sw_p1transl
   ,s.sql_hash_value /* for 9i n 10g */
 --  ,s.sql_id        /*  for 10g n above */
  --  ,s.blocking_session_status  /*  for 10g n above */
 --  ,s.blocking_session     /*  for 10g n above */
  FROM 
    v$session_wait sw
    ,v$session s
WHERE 
   sw.sid = s.sid 
   and
    sw.sid IN (select sid from v$session where status ='ACTIVE' and type <> 'BACKGROUND')
ORDER BY
    sw.state,
    sw_event,
    sw.p1,
    sw.p2,
    sw.p3
/


