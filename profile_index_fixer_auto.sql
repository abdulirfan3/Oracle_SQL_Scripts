----------------------------------------------------------------------------------------
-- SEE DOC at C:\My personal work Related\MY STUFF\perf notes\Fixing Bad Index Hints in SQL Profiles (automatically)
--
-- File name:   pif.sql (profile_index_fixer)
--
-- Purpose:     Fix INDEX hints in SQL Profiles.
-
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for three values.
--
--              profile_name: the name of the profile to be modified
--
--              simplify_hints: (Y/N) flag tells pif to simplify  all INDEX hints 
--                                  (i.e. "Y" means INDEX_RS_ASC changed to INDEX)
--
--              make_modifications: (Y/N) flag tells pif to implement proposed fixes 
--
--  
-- Description: SQL Profiles use a form of INDEX hints that specifies the columns
--              it wishes to use an index on. This is done one purpose to allow
--              the hint to use any available index on the spcified table. Unfortunately,
--              the effect of this decision is less stablity of plans due to allowing
--              the optimizer the flexibility to choose amongst potentially many indexs
--              (as opposed to the older format which specifies an index name directly).
--              This script pulls the index hints associated with a SQL Profile from 
--              sqlprof$attr and changes them to the older more specific format.
--
--              This script has some debug lines. Modify the script to set debug='Y' to enable debug statements.
--
-- Issues:      1. If there are multiple indexes with the same name on the base table, 
--              (owned by mutliple users) the first found with the right set of columns
--              will be used.
-- 
--              2. Synonymns could be an issue. If there are multiple synonymns with the
--              same name that point to different objects, the script will not be able 
--              to continue. 
--
--              3. ??? will be used for the index name if the script can't determine 
--              what index to use.
--
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
--
set sqlblanklines on
set feedback off
accept profile_name -
       prompt 'Enter value for profile_name: ' -
       default 'X0X0X0X0'

accept simplify_hints -
       prompt 'Enter value for simplify_hints: ' -
       default 'N'

declare

debug varchar2(1) := 'N';
TYPE hints_type IS TABLE OF varchar2(4000) INDEX BY BINARY_INTEGER;
new_hints hints_type;
ar_profile_hints sys.sqlprof_attr;
cl_sql_text clob;
version varchar2(3);
l_category varchar2(30);
l_force_matching varchar2(3);
b_force_matching boolean;
index_name varchar2(30);
orig_tab varchar2(30);
tab_name varchar2(30);
orig_tab_cols varchar2(4000);
syn_flag varchar2(1);
syn_count number;
index_hint_count number := 0;
make_mods varchar2(1);

begin

 select regexp_replace(version,'\..*') into version from v$instance;

if version = '10' then

-- dbms_output.put_line('version: '||version);
   execute immediate -- to avoid 942 error 
   'select attr_val as outline_hints '||
   'from dba_sql_profiles p, sqlprof$attr h '||
   'where p.signature = h.signature '||
--   'and upper(attr_val) like ''INDEX%(%.%'' '||
   'and name like (''&&profile_name'') '||
   'order by attr#'
   bulk collect 
   into ar_profile_hints;

elsif version = '11' then

-- dbms_output.put_line('version: '||version);
   execute immediate -- to avoid 942 error 
   'select hint as outline_hints '||
   'from (select p.name, p.signature, p.category, row_number() '||
   '      over (partition by sd.signature, sd.category order by sd.signature) row_num, '||
   '      extractValue(value(t), ''/hint'') hint '||
   'from sqlobj$data sd, dba_sql_profiles p, '||
   '     table(xmlsequence(extract(xmltype(sd.comp_data), '||
   '                               ''/outline_data/hint''))) t '||
   'where sd.obj_type = 1 '||
   'and p.signature = sd.signature '||
   'and p.name like (''&&profile_name'')) '||
--   'where upper(hint) like ''INDEX%(%.%'' '||
   'order by row_num'
   bulk collect 
   into ar_profile_hints;

end if;

dbms_output.put_line(' ');
dbms_output.put_line('HINT');
dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------');

for i in 1..ar_profile_hints.count loop -- main (loop through all hints in Profile)
if ar_profile_hints(i) like 'INDEX%(%.%' then
  index_hint_count := index_hint_count+1;
/*
-- shared cursor - may want to add capability to specify cursor in shared pool
  select object_name into index_name
  from v$sql_plan sp, dba_sql_profiles prof, v$sql s
  where s.sql_id = sp.sql_id
  and s.child_number = sp.child_number
  and s.EXACT_MATCHING_SIGNATURE = prof.signature
  and sp.child_number = (select max(child_number) from v$sql_plan a where a.sql_id = s.sql_id)
  and operation = 'INDEX'
  and qblock_name = replace(regexp_substr(ar_profile_hints(i),'"[^"]+"'),'"','')
  and regexp_substr(object_alias,'[^@]+') = replace(regexp_substr(ar_profile_hints(i),'"[^"]+"',1,2),'"','')
  and prof.name = '&&profile_name';
*/
orig_tab_cols := replace(regexp_replace(ar_profile_hints(i),'(.*)\((.*)\)(.*)','\2'),')','');  -- all between ( and )
orig_tab := replace(regexp_substr(orig_tab_cols,'"[^"]+"'),'"','');  -- first string in double quotes (")
index_name := '???';

-- Table or Synonym?
select case when count(*) =  0 then 'Y' end into syn_flag from dba_tables where table_name = orig_tab;
if syn_flag = 'Y' then 
  select count(distinct table_name) into syn_count from dba_synonyms where synonym_name = orig_tab;
  if syn_count = 1 then
    select distinct table_name into tab_name 
    from dba_synonyms where synonym_name = orig_tab;
  else
    tab_name := '???';
  end if;
else
  tab_name := orig_tab;
end if;

declare
  v_last_index_name varchar2(30) := null;
  v_last_index_owner varchar2(30) := null;
  v_line  varchar2(4000);
begin
  for r in ( select index_owner, index_name, column_position, '"'||table_name||'"."'||b.column_name||'"' col_name, 1 counter
             from all_ind_columns b
             where b.table_name = tab_name
             union -- just here to give us one more record
             select 'ZZZZZZZZZZZZZZZZZZ',null,1,'Dummy Record', 2 counter from dual 
             order by 5, 1,2,3,4) loop
    if v_last_index_name is null and v_last_index_owner is null then
       v_line:=r.col_name;
       v_last_index_name := r.index_name;
       v_last_index_owner := r.index_owner;
       if debug='Y' then dbms_output.put_line('1: '||v_line); end if;
    else
       if r.index_name = v_last_index_name and r.index_owner = v_last_index_owner then 
          v_line:=v_line||' '||r.col_name;
          if debug='Y' then dbms_output.put_line('2: '||v_line); end if;
       else
          if debug='Y' then dbms_output.put_line('3: '||v_last_index_name||' '||v_line); end if;
          if replace(v_line,tab_name,orig_tab) = orig_tab_cols then
             index_name := v_last_index_name;
             exit;
          end if;
          v_line:=r.col_name;
          v_last_index_name := r.index_name;
       end if;
    end if;
  end loop;

exception
  when no_data_found then
    index_name := '???';
end;

-- Output Section

new_hints(i) := case when '&&simplify_hints' = 'Y' then 'INDEX(@' else 
                regexp_substr(ar_profile_hints(i),'[a-zA-Z_]+',1,1)||'(@' end || -- hint
                regexp_substr(ar_profile_hints(i),'"[^"]+"')||' '||              -- qblock
                regexp_substr(ar_profile_hints(i),'"[^"]+"',1,2)||'@'||          -- alias
                regexp_substr(ar_profile_hints(i),'"[^"]+"',1,3)||' '||          -- alias_qblock
                '"'||index_name||'")';

if debug='Y' then dbms_output.put_line('  Orig Tab: '||orig_tab); end if;
if debug='Y' then dbms_output.put_line('  Tab:      '||tab_name); end if;
if debug='Y' then dbms_output.put_line('  Tab Cols: '||orig_tab_cols); end if;

dbms_output.put_line('Old: '||ar_profile_hints(i));
dbms_output.put_line('New: '||new_hints(i)); 
dbms_output.put_line(' ');

ar_profile_hints(i) := new_hints(i); -- set up for fix if requested

end if; -- INDEX hints
end loop; -- main

dbms_output.put_line(' ');
dbms_output.put_line(index_hint_count||' INDEX hint(s) found.');

-- Fix it Section
-- ===================================
select nvl('&make_modifications','N') into make_mods from dual;
if make_mods = 'Y' then 
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
  dbms_output.put_line(index_hint_count||' INDEX hint(s) modified.');
else
  dbms_output.put_line('0 INDEX hint(s) modified.');
end if;
-- ===================================
  dbms_output.put_line(' ');
end;
/
undef profile_name
undef simplify_hints
set feedback on