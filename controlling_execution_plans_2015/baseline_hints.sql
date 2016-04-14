----------------------------------------------------------------------------------------
--
-- File name:   baseline_hints.sql
--
-- Purpose:     Show hints associated with a SQL Plan Baseline.
-
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for one value.
--
--              baseline_name: the name of the basleine to be used
--
-- Description: This script pulls the hints associated with a SQL Profile.
--
-- Mods:        Modified to check for 11g or 12c as the hint structure changed.
--              Note that 12c actually stores a plan table (but still uses hints).
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
--
set serverout on format wrapped
set sqlblanklines on
set feedback off
accept baseline_plan_name -
       prompt 'Enter value for baseline_plan_name: ' -
       default 'X0X0X0X0'

declare
ar_baseline_hints sys.sqlprof_attr;
cl_sql_text clob;
version varchar2(3);
unsupported_version varchar2(1);
l_category varchar2(30);
l_force_matching varchar2(3);
b_force_matching boolean;
begin
 select regexp_replace(version,'\..*') into version from v$instance;

if version = '11' then

-- dbms_output.put_line('version: '||version);
   execute immediate -- to avoid 942 error 
   'select extractvalue(value(d), ''/hint'') as outline_hints '||
   'from xmltable(''/outline_data/hint'' passing ( '||
   'select xmltype(comp_data) as xmlval '||
   'from sqlobj$data sod, sqlobj$ so '||
   'where so.signature = sod.signature '||
   'and so.plan_id = sod.plan_id '||
   'and comp_data is not null '||
   'and name like ''&baseline_plan_name'')) d'
   bulk collect 
   into ar_baseline_hints;

elsif version = '12' then

-- dbms_output.put_line('version: '||version);
   execute immediate -- to avoid 942 error 
   'select extractvalue(value(d), ''/hint'') as outline_hints '||
   'from xmltable(''/other_xml//outline_data/hint'' passing ('||
   'select xmltype(other_xml) as xmlval '||
   'from SQLOBJ$PLAN sod, sqlobj$ so '||
   'where so.signature = sod.signature '||
   'and so.plan_id = sod.plan_id '||
   'and other_xml is not null '||
   'and name like ''&&baseline_plan_name'')) d'
   bulk collect 
   into ar_baseline_hints;

else 

  unsupported_version := 'Y';

end if;

if unsupported_version = 'Y' then 
  dbms_output.put_line(' ');
  dbms_output.put_line('This script does not support version '||version);
  dbms_output.put_line(' ');
else
  dbms_output.put_line(' ');
  dbms_output.put_line('HINT');
  dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------');
  for i in 1..ar_baseline_hints.count loop
    dbms_output.put_line(ar_baseline_hints(i));
  end loop;
  dbms_output.put_line(' ');
  dbms_output.put_line(ar_baseline_hints.count||' rows selected.');
  dbms_output.put_line(' ');
end if;

end;
/
undef baseline_plan__name
set feedback on
set serverout off
