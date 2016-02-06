-- ********************************************************************
-- * Copyright Notice   : (c)1998,1999,2000,2001,2002,...,2008,2011 OraPub, Inc.
-- * Filename		: sessinfo.sql
-- * Author		: Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Update	: 17-nov-2011
-- * Description	: Show session related information
-- * Usage		    : start sessinfo.sql
-- ********************************************************************
col "Session Info" form A80
col a              form a75 fold_after 1

accept sid      prompt 'Please enter the value for Sid if known            : '
accept client_identifier prompt 'Please enter the value for client identifer        : '
accept service_name      prompt 'Please enter the value for service name            : '
accept module            prompt 'Please enter the value for module                  : '
accept terminal prompt 'Please enter the value for terminal if known       : '
accept machine  prompt 'Please enter the machine name if known             : '
accept process  prompt 'Please enter the value for Client Process if known : '
accept spid     prompt 'Please enter the value for Server Process if known : '
accept osuser   prompt 'Please enter the value for OS User if known        : '
accept username prompt 'Please enter the value for DB User if known        : '
accept progname prompt 'Please enter the value for program name            : '

set heading off

select 'Sid, Serial#, Aud sid    : '|| s.sid||' , '||s.serial#||' , '||s.audsid a,
       'DB User / OS User        : '||s.username||' / '||s.osuser a,
       'Machine - Terminal       : '||s.machine||' - '|| s.terminal a,
       'OS Process Ids           : '||s.process||' (Client)  '||p.spid||' (Server)' a,
       'Client Program Name      : '||s.program a,
       'Client Identifier        : '||s.client_identifier a,
       'Service - Module - Action: '||s.service_name||' - '||s.module||' - '||s.action a,
       'Blocking sid             : '||s.blocking_session "Session Info",
       'SQL_ID / PREV_SQL_ID     : '||s.sql_id||' / '||s.PREV_SQL_ID a,
       'CPU consumption (sec)    : SP='||t1.time_s||' BG='||t2.time_s a,
       'PL/SQL exec elapsed (sec): '||t3.time_s a,
	   'Status                   : '|| s.status,
	   'Lass_call_et             : '|| s.last_call_et
  from v$process p,
       v$session s,
       ( select sid,value/1000000 time_s
         from   v$sess_time_model 
         where  stat_name = 'DB CPU'
       ) t1,
       ( select sid,value/1000000 time_s
         from   v$sess_time_model 
         where  stat_name = 'background cpu time'
       ) t2,
       ( select sid,value/1000000 time_s
         from   v$sess_time_model 
         where  stat_name = 'PL/SQL execution elapsed time'
       ) t3
 where p.addr              = s.paddr
   and s.sid		   = t1.sid
   and s.sid		   = t2.sid
   and s.sid		   = t3.sid
   and s.sid               = nvl('&SID',s.sid)
   and nvl(s.terminal,' ') like nvl('%&terminal%',nvl(s.terminal,' '))
   and s.process           = nvl('&Process',s.process)
   and p.spid              = nvl('&spid',p.spid)
   and upper(s.username)         like nvl(upper('%&username%'),upper(s.username))
   and nvl(upper(s.osuser),' ')  like nvl(upper('%&OSUser%'),nvl(upper(s.osuser),' '))
   and nvl(upper(s.machine),' ') like nvl(upper('%&machine%'),nvl(upper(s.machine),' '))
   and nvl(upper(s.program),' ') like nvl(upper('%&progname%'),'%')
   and nvl(s.module,' ') like nvl('%&module%',nvl(s.module,' '))
   and nvl(upper(s.client_identifier),' ') like nvl(upper('%&client_identifier%'),nvl(upper(s.client_identifier),' '))
   and nvl(upper(s.service_name),' ') like nvl(upper('%&service_name%'),nvl(upper(s.service_name),' '))
/
set heading on

