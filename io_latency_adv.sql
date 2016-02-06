set feed off
set head off
set echo off
set term off
set linesize 500
set verify off
spool oraiomon_3.sql
set feedback off
set feed off
set timing off
set serveroutput on
whenever sqlerror exit 


select cmd from (
select  '@oraiomon1.sql'  as cmd from dual
union all
select 'exec dbms_lock.sleep(&1);' as cmd from dual
)
union all
select case
when mod(rn,35)=0 and cmd='set head off' then '@oraiomon_head.sql'
when mod(rn,35)<>0 and cmd='set head off' then ' '
else cmd end as cmd
 from (
select 'set head off' as cmd from dual
union all
select  '@oraiomon2.sql'  as cmd from dual
union all
select 'exec dbms_lock.sleep(&1);' as cmd from dual
) , (select rownum as rn from dual connect by level <=&2)
;

spool off
set term on
set serveroutput on
set head on
--clear scr
@oraiomon_3.sql
set lines 1500;