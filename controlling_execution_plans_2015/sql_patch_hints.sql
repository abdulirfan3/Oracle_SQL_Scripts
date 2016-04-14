----------------------------------------------------------------------------------------
--
-- File name:   sql_patch_hints.sql
--
-- Purpose:     Show hints associated with a SQL Patch.
-
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for one value.
--
--              patch_name: the name of the patch to be used
--
-- Description: This script pulls the hints associated with a SQL Patch.
--
-- Mods:        Modified to check for 10g or 11g as the hint structure changed.
--              Modified to join on category as well as signature.
--              Modified to work with 12c as well.
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
--
set serverout on format wrapped
set feedback off
set sqlblanklines on
accept patch_name -
       prompt 'Enter value for patch_name: ' -
       default 'X0X0X0X0'

declare
ar_patch_hints sys.sqlprof_attr;
cl_sql_text clob;
version varchar2(3);
l_category varchar2(30);
l_force_matching varchar2(3);
b_force_matching boolean;
begin
 select regexp_replace(version,'\..*') into version from v$instance;

if version = '10' then

-- dbms_output.put_line('version: '||version);
   execute immediate -- to avoid 942 error 
   'select attr_val as outline_hints '||
   'from dba_sql_patches p, sqlprof$attr h '||
   'where p.signature = h.signature '||
   'and p.category = h.category  '||
   'and name like (''&&patch_name'') '||
   'order by attr#'
   bulk collect 
   into ar_patch_hints;

elsif version = '11' or version = '12' then

-- dbms_output.put_line('version: '||version);
   execute immediate -- to avoid 942 error 
   'select hint as outline_hints '||
   'from (select p.name, p.signature, p.category, row_number() '||
   '      over (partition by sd.signature, sd.category order by sd.signature) row_num, '||
   '      extractValue(value(t), ''/hint'') hint '||
   'from sqlobj$data sd, dba_sql_patches p, '||
   '     table(xmlsequence(extract(xmltype(sd.comp_data), '||
   '                               ''/outline_data/hint''))) t '||
   'where sd.obj_type = 3 '||
   'and p.signature = sd.signature '||
   'and p.category = sd.category '||
   'and p.name like (''&&patch_name'')) '||
   'order by row_num'
   bulk collect 
   into ar_patch_hints;

end if;

  dbms_output.put_line(' ');
  dbms_output.put_line('HINT');
  dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------');
  for i in 1..ar_patch_hints.count loop
    dbms_output.put_line(ar_patch_hints(i));
  end loop;
  dbms_output.put_line(' ');
  dbms_output.put_line(ar_patch_hints.count||' rows selected.');
  dbms_output.put_line(' ');

end;
/
undef patch_name
set feedback on
set serverout off
