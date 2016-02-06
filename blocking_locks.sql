prompt****************************************************  
prompt Blocking Status Section  
prompt****************************************************   

/*

-- to generate kill statements as well

select 'alter system kill session ''' ||s1.sid||','||s1.serial#|| ''' immediate;' as kill_statmt
--,s1.username || '@' || s1.machine
-- || ' ( SID=' || s1.sid ||','||s1.serial# || ' )  is blocking '
--  || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status 
  from v$lock l1, v$session s1, v$lock l2, v$session s2
  where s1.sid=l1.sid and s2.sid=l2.sid
  and l1.BLOCK=1 and l2.request > 0
  and l1.id1 = l2.id1
  and l2.id2 = l2.id2 ; 

*/

/* -- VERSION 1

select s1.username || '@' || s1.machine
 || ' ( SID=' || s1.sid ||','||s1.serial# || ' )  is blocking '
  || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
  from v$lock l1, v$session s1, v$lock l2, v$session s2
  where s1.sid=l1.sid and s2.sid=l2.sid
  and l1.BLOCK=1 and l2.request > 0
  and l1.id1 = l2.id1
  and l2.id2 = l2.id2 ; 
*/	
	
-- Version 2

select s1.username || '@' || s1.machine || ' SID=' || s1.sid || ' (STATUS=' || s1.STATUS ||' for '|| s1.LAST_CALL_ET ||' sec)' 
|| '  IS BLOCKING ' || s2.username || '@' || s2.machine ||  ' SID=' || s2.sid  AS blocking_status
  from v$lock l1, v$session s1, v$lock l2, v$session s2
  where s1.sid=l1.sid and s2.sid=l2.sid
  and l1.BLOCK=1 and l2.request > 0
  and l1.id1 = l2.id1
  and l2.id2 = l2.id2 ;	
