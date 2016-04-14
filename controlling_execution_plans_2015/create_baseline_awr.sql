----------------------------------------------------------------------------------------
--
-- File name:   create_baseline_awr.sql
--
-- Purpose:     Creates a SQL Baseline on a SQL statement using a plan in AWR.
-
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for five values.
--
--              sql_id: the sql_id of the statement (must be in the shared pool)
--
--              plan_hash_value: the hash value of the plan
--
--              fixed: a toggle to turn on or off the fixed feature (NO)
--
--              enabled: a toggle to turn on or off the enabled flag (YES)
--
--              plan_name: the name of the plan (SQLID_sqlid_planhashvalue)
--
-- Description: This script uses the DBMS_SPM.LOAD_PLANS_FROM_SQLSET procedure to
--              create a Baseline on a statement that is currently in the shared pool.
--              The plan will be pulled from the AWR tables. By default, the Baseline 
--              is renamed to include the sql_id and plan_hash_value.
--
--              See kerryosborne.oracle-guy.com for additional information.
-----------------------------------------------------------------------------------------
set serveroutput on
set sqlblanklines on
set feedback off
col sql_text for a50 trunc
col last_executed for a28
col enabled for a7
col plan_hash_value for a16
col last_executed for a16
col sql_handle for a24
accept sql_id -
  prompt 'Enter value for SQL_ID: ' -
  default '3ggjbbd2varq2'
accept plan_hash_value -
  prompt 'Enter value for PLAN_HASH_VALUE: ' -
  default '568322376'
accept fixed -
       prompt 'Enter value for fixed (NO): ' -
       default 'NO'
accept enabled -
       prompt 'Enter value for enabled (YES): ' -
       default 'YES'
accept plan_name -
       prompt 'Enter value for plan_name (ID_sqlid_planhashvalue): ' -
       default 'X0X0X0X0'

exec DBMS_SQLTUNE.CREATE_SQLSET('CREATE_BASELINE_AWR');

declare
baseline_ref_cursor DBMS_SQLTUNE.SQLSET_CURSOR;
min_snap number;
max_snap number;
ret binary_integer;
l_sql_handle varchar2(40);
l_plan_name varchar2(40);
l_old_plan_name varchar2(40);
major_release varchar2(3);
minor_release varchar2(3);
BEGIN
select regexp_replace(version,'\..*'), regexp_substr(version,'[0-9]+',1,2) into major_release, minor_release from v$instance;

select min(snap_id), max(snap_id) into min_snap, max_snap from dba_hist_snapshot;

open baseline_ref_cursor for
select VALUE(p) from table(DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(min_snap, max_snap,
'sql_id='||CHR(39)||'&&sql_id'||CHR(39)||' and plan_hash_value=&plan_hash_value',NULL,NULL,NULL,NULL,NULL,NULL,'ALL')) p;

DBMS_SQLTUNE.LOAD_SQLSET('CREATE_BASELINE_AWR', baseline_ref_cursor);

ret := DBMS_SPM.LOAD_PLANS_FROM_SQLSET (
sqlset_name => 'CREATE_BASELINE_AWR',
sqlset_owner => 'SYS',
fixed => 'NO',
enabled => 'YES');

if minor_release = '1' then

-- 11gR1 has a bug that prevents renaming Baselines

    select plan_name
    into l_plan_name
    from dba_sql_plan_baselines spb
    where created > sysdate-(1/24/60/15);

else

-- This statements looks for Baselines create in the last 4 seconds

    select sql_handle, plan_name,
    decode('&&plan_name','X0X0X0X0','SQLID_'||'&&sql_id'||'_'||'&&plan_hash_value','&&plan_name')
    into l_sql_handle, l_old_plan_name, l_plan_name
    from dba_sql_plan_baselines spb
    where created > sysdate-(1/24/60/15);


    ret := dbms_spm.alter_sql_plan_baseline(
    sql_handle=>l_sql_handle,
    plan_name=>l_old_plan_name,
    attribute_name=>'PLAN_NAME',
    attribute_value=>l_plan_name);

end if;

dbms_output.put_line(' ');
dbms_output.put_line('Baseline '||upper(l_plan_name)||' created.');
dbms_output.put_line(' ');

end;
/
/*
set feedback on
select NAME,OWNER,CREATED,STATEMENT_COUNT FROM DBA_SQLSET where name like 'CREATE_BASELINE_AWR';
select spb.sql_handle, spb.plan_name, spb.sql_text,
spb.enabled, spb.accepted, spb.fixed, 
to_char(spb.last_executed,'dd-mon-yy HH24:MI') last_executed
from dba_sql_plan_baselines spb
where upper(spb.plan_name) = upper('&&plan_name');
*/
clear breaks
exec  DBMS_SQLTUNE.DROP_SQLSET( sqlset_name => 'CREATE_BASELINE_AWR' );
undef sql_id
undef plan_hash_value
undef fixed
undef enabled
undef plan_name
