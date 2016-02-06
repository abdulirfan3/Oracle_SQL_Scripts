--Usage: refresh.sql "sql script name" interval sample
--ex:   @refresh sess_active 5 5 
--Usage: For script that do have input use below
--    @refresh "script_name input input" interval sample
--    @refresh "snapper all 5 1 sid=123" 5 5
set feed off
set head off
set echo off
set term off
set linesize 1500
set verify off
spool refresh_1.sql
set feedback off
set timi off
set feed off
set serveroutput on 
select cmd from (
select '@' || '&1'  as cmd from dual
union all
select 'exec dbms_lock.sleep(&2);' as cmd from dual
union all
select '' as cmd from dual
) , (select rownum from dual connect by level <=&3) ;
spool off
set term on
set serveroutput on
set head on
--clear scr
set timi on
@refresh_1.sql