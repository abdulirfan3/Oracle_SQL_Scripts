----------------------------------------------------------------------------------------
-- SEE DOC at C:\My personal work Related\MY STUFF\perf notes\Fixing Bad Index Hints in SQL Profiles (automatically)
--
-- File name:   fix_sql_profile_hint.sql
--
-- Purpose:     Replaces a hint in a sql profile.
-
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for three values.
--
--              profile_name: the name of the profile to be modified
--
--              bad_hint: the hint to be replaced (cut and paste hint from listing 
--                        using sql_profile_hints.sql)
--
--              good_hint: the hint to replace the bad_hint
--
-- Description: This script was written becuase Oracle decided to start using a index 
--              hints that don't specifiy the index name. This allows the optimizer a 
--              great deal of flexibility, which is not desirable when you are trying 
--              "lock" a plan. 
--
--              
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
--
-- WARNING: don't use this script if you don't know what you're doing!
--
accept profile_name -
       prompt 'Enter value for profile_name: ' -
       default 'X0X0X0X0'
accept bad_hint -
       prompt 'Enter value for bad_hint: ' -
       default '&%$&%$X0X0X0X0!.*&$5#'
accept good_hint -
       prompt 'Enter value for good_hint: ' -
       default ' '

declare
ar_profile_hints sys.sqlprof_attr;
cl_sql_text clob;
version varchar2(3);
l_category varchar2(30);
l_force_matching varchar2(3);
b_force_matching boolean;
begin
 select regexp_replace(version,'\..*') into version from v$instance;

if version = '10' then

   dbms_output.put_line('version: '||version);
   execute immediate -- to avoid 942 error 
   'select replace(attr_val,''&&bad_hint'',''&&good_hint'') as outline_hints '||
   'from dba_sql_profiles p, sqlprof$attr h '||
   'where p.signature = h.signature '||
   'and name like (''&&profile_name'') '||
   'order by attr#'
   bulk collect 
   into ar_profile_hints;

elsif version = '11' then

   dbms_output.put_line('version: '||version);
   execute immediate -- to avoid 942 error 
   'select replace(hint,''&&bad_hint'',''&&good_hint'') as outline_hints '||
   'from (select p.name, p.signature, p.category, row_number() '||
   '      over (partition by sd.signature, sd.category order by sd.signature) row_num, '||
   '      extractValue(value(t), ''/hint'') hint '||
   'from sqlobj$data sd, dba_sql_profiles p, '||
   '     table(xmlsequence(extract(xmltype(sd.comp_data), '||
   '                               ''/outline_data/hint''))) t '||
   'where sd.obj_type = 1 '||
   'and p.signature = sd.signature '||
   'and p.name like (''&&profile_name'')) '||
   'order by row_num'
   bulk collect 
   into ar_profile_hints;

end if;

select
sql_text, category, force_matching
into
cl_sql_text, l_category, l_force_matching
from
dba_sql_profiles 
where name like ('&&profile_name');

if l_force_matching = 'YES' then
   b_force_matching := TRUE;
else
   b_force_matching := FALSE;
end if;

dbms_sqltune.import_sql_profile(
sql_text => cl_sql_text
, profile => ar_profile_hints
, name => '&&profile_name'
, description => 'Warning: hints modified by fix_sql_profile_hint.sql'
, category => l_category
, force_match => b_force_matching
, replace => TRUE
, validate => TRUE
);
end;
/

undef profile_name
undef bad_hint
undef good_hint
