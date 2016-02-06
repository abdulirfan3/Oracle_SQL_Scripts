--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

function calc_obj_info_seq (p_owner varchar2, p_seq_name varchar2)
return varchar2
is
  l_str varchar2(200 char);
begin
  for s in (select /*+ xplan_exec_marker */ sequence_name, min_value, max_value, increment_by,
                   cycle_flag, order_flag, cache_size, last_number 
              from sys.all_sequences 
             where sequence_owner = p_owner 
               and sequence_name  = p_seq_name)
  loop
    l_str := l_str || ' cache ' ||s.cache_size;
    l_str := l_str || ' last_number=' ||s.last_number;
    if s.min_value != 1 then l_str := l_str || ' minvalue '||s.min_value; end if;
    if s.max_value != 999999999999999999999999999 then l_str := l_str || ' maxvalue '||s.max_value; end if;
    if s.increment_by != 1 then l_str := l_str || ' increment by  '||s.increment_by;  end if;
    if s.cycle_flag != 'N' then l_str := l_str || ' CYCLE'; end if;
    if s.order_flag != 'N' then l_str := l_str || ' ORDER'; end if;
    return l_str;
  end loop;
  return '* not found *';
end calc_obj_info_seq;

function calc_obj_info_syn (p_owner varchar2, p_syn_name varchar2)
return varchar2
is
  l_str varchar2(100 char);
begin
  -- print ('syn ' ||p_owner||' '||p_syn_name);
  
  for s in (select /*+ ordered use_nl(o) xplan_exec_marker */ a.table_owner, a.table_name, a.db_link, o.object_type
              from sys.all_synonyms a, sys.all_objects o
             where a.owner        = p_owner
               and a.synonym_name = p_syn_name
               and a.table_owner  = o.owner
               and a.table_name   = o.object_name
               and o.object_type  not in ('SYNONYM','PACKAGE BODY','TYPE BODY','TABLE PARTITION')
               order by 1,2,3,4)
  loop
    l_str := l_str || lower(s.object_type)||' '||s.table_owner||'.'||s.table_name;
    if s.db_link is not null then
      l_str := l_str || '@' || s.db_link;
    end if;
    l_str := l_str || ', ';
  end loop;
  return rtrim(trim(l_str),',');
end calc_obj_info_syn;

function calc_type_of_unknown(
  p_owner       varchar2,
  p_name        varchar2
)
return varchar2
is
  l_type_string sys.all_objects.object_type%type;
begin
  --print( 'calc_type_of_unknown '||p_owner||'.'||p_name||' trying ...');

  select /*+ xplan_exec_marker */ o.object_type
    into l_type_string
    from sys.all_objects o
   where owner = p_owner
     and object_name = p_name;
     
  print( 'resolved UNKNOWN_OBJECT_TYPE as '||p_owner||'.'||p_name||' -> '||l_type_string);
  return l_type_string;
exception
  when no_data_found then
    return 'UNKNOWN_OBJECT_TYPE';
  when too_many_rows then
    return 'UNKNOWN_OBJECT_TYPE';
end calc_type_of_unknown;

procedure print_obj_dep_and_store_1 (
  p_owner       varchar2,
  p_name        varchar2,
  p_type_string varchar2
)
is
  l_object_str        varchar2(100 char);
  l_object_str_unk    varchar2(100 char);
  l_type_string       varchar2(50  char);
  l_veedollar_is_fixed_view varchar2(1 char);
  l_append_str        varchar2(200 char); 
begin
  -- many objects in 10g and 11g have UNKNOWN_OBJECT_TYPE as their type
  -- the following block reconstructs the type if p_owner/p_name identify
  -- it unambigously
  if p_type_string = 'UNKNOWN_OBJECT_TYPE' then
    l_object_str_unk := p_owner || '.' || p_name;
    if m_all_non_tab_objects_unk.exists( l_object_str_unk ) then
      l_type_string := m_all_non_tab_objects_unk( l_object_str_unk );
    else
      l_type_string := calc_type_of_unknown( p_owner, p_name );
      m_all_non_tab_objects_unk( l_object_str_unk ) := l_type_string;
    end if;
  else
    l_type_string := p_type_string;
  end if;

  l_object_str  := l_type_string || '.' || p_owner || '.' || p_name;
  
  if m_all_non_tab_objects_skip.exists (l_object_str) then
    return;
  end if;
  
  if not m_all_non_tab_objects.exists (l_object_str) then 
   
    if p_type_string = 'PACKAGE' and p_owner = 'SYS' and p_name in ('DBMS_OUTPUT','STANDARD','DBMS_STANDARD') then
      m_all_non_tab_objects_skip (l_object_str) := 'X';
      return;
    end if;
    
    -- almost all of the gv$ and v$ are generically reported as views in 9i, 10g(?), 11g, 
    -- but they are fixed views, hence not present in all_views
    -- E.g. SYS.V$OBJECT_USAGE is a view, not a fixed view; almost all others are fixed views
    if p_type_string = 'VIEW' and p_owner = 'SYS' and (p_name like 'V$%' or p_name like 'GV$%') then
    
      select /*+ xplan_exec_marker */ decode (count(*), 0, 'N', 'Y') 
        into l_veedollar_is_fixed_view
        from sys.v_$fixed_view_definition 
       where view_name = p_name 
         and rownum    = 1;
      
      if l_veedollar_is_fixed_view = 'Y' then
        l_type_string := 'FIXED VIEW';
        l_object_str  := l_type_string || '.' || p_owner || '.' || p_name;
      end if;
    end if;
    
    if l_type_string = 'SYNONYM' then
      m_all_non_tab_objects (l_object_str) := calc_obj_info_syn (p_owner, p_name);
    elsif l_type_string = 'SEQUENCE' then
      m_all_non_tab_objects (l_object_str) := calc_obj_info_seq (p_owner, p_name);
    else
      m_all_non_tab_objects (l_object_str) := 'X';
    end if;
  end if;
  
  if l_type_string = 'SYNONYM' then
    l_append_str := ' -> ' || m_all_non_tab_objects (l_object_str);
  elsif l_type_string = 'SEQUENCE' then
    l_append_str := m_all_non_tab_objects (l_object_str);
  end if;
  
  -- print dependency
  print ('- depends on ' || lower(l_type_string) || ' ' || p_owner || '.' || p_name || l_append_str);
  
end print_obj_dep_and_store_1;

procedure print_obj_dep_and_store (
  p_inst_id          sys.gv_$sql.inst_id%type,
  p_address          sys.gv_$sql.address%type, 
  p_hash_value       sys.gv_$sql.hash_value%type
)
is
begin
  -- found in pro :CURSOR,FUNCTION,LIBRARY,NON-EXISTENT,PACKAGE,PROCEDURE,SEQUENCE,SUMMARY,SYNONYM,TABLE,TRIGGER,TYPE,VIEW
  for d in (select /*+ xplan_exec_marker */ 
                   to_owner, 
                   to_name, 
                   -- following decode() is from 11.1.0.7 gv$db_object_cache (same as in 9.2.0.8)
                   -- see 43767.1 for meaning of NON-EXISTENT and INVALID TYPE
                   decode(to_type, 0,'CURSOR',1,'INDEX',2,'TABLE', 3,'CLUSTER',4,'VIEW', 5,'SYNONYM',6,'SEQUENCE',
                   7,'PROCEDURE',8,'FUNCTION',9,'PACKAGE',10, 'NON-EXISTENT',11,'PACKAGE BODY',12,'TRIGGER',13,'TYPE',
                   14, 'TYPE BODY', 15,'OBJECT',16,'USER',17,'DBLINK',18,'PIPE',19,'TABLE PARTITION', 20,'INDEX PARTITION',21,'LOB',
                   22,'LIBRARY',23,'DIRECTORY',24,'QUEUE', 25,'INDEX-ORGANIZED TABLE',26,'REPLICATION OBJECT GROUP', 
                   27,'REPLICATION PROPAGATOR', 28,'JAVA SOURCE',29,'JAVA CLASS',30,'JAVA RESOURCE',31,'JAVA JAR',
                   32,'INDEX TYPE',33, 'OPERATOR',34,'TABLE SUBPARTITION',35,'INDEX SUBPARTITION', 36, 'REPLICATED TABLE OBJECT',
                   37,'REPLICATION INTERNAL PACKAGE', 38, 'CONTEXT POLICY',39,'PUB_SUB',40,'LOB PARTITION',41,'LOB SUBPARTITION', 
                   42,'SUMMARY',43,'DIMENSION',44,'APP CONTEXT',45,'STORED OUTLINE',46,'RULESET', 47,'RSRC PLAN',
                   48,'RSRC CONSUMER GROUP',49,'PENDING RSRC PLAN', 50,'PENDING RSRC CONSUMER GROUP',51,'SUBSCRIPTION',
                   52,'LOCATION', 53,'REMOTE OBJECT', 54,'SNAPSHOT METADATA',55,'XDB', 56,'JAVA SHARED DATA',57,'SECURITY PROFILE',
                   'INVALID TYPE') as to_type_string,
                   to_type
              from sys.gv_$object_dependency
             where inst_id      = p_inst_id
               and from_address = p_address
               and from_hash    = p_hash_value
               and to_type not in (0,2,10,25,34,35)
               and to_type between 1 and 70
               order by to_type, to_owner, to_name)
  loop 
    print_obj_dep_and_store_1 (
      p_owner => d.to_owner, p_name => d.to_name, 
      -- do not change UNKNOWN_OBJECT_TYPE string !!
      p_type_string => case when d.to_type_string = 'INVALID TYPE' then 'UNKNOWN_OBJECT_TYPE' else d.to_type_string end
    );
  end loop;
end print_obj_dep_and_store;

procedure print_obj_info_view (p_owner varchar2, p_view_name varchar2)
is
  l_cols_string long;
begin
  for c in (select /*+ xplan_exec_marker */ column_id, column_name, data_type 
             from sys.all_tab_cols
            where owner      = p_owner
              and table_name = p_view_name
            order by column_id) 
  loop
    l_cols_string := l_cols_string||'#'||c.column_id||' '||c.column_name ||'('||c.data_type||'),';  
  end loop;
  print ('view columns: '||rtrim(l_cols_string,','));
  
  print_long (p_query => 'select /*+ xplan_exec_marker */ text from sys.all_views where owner = :1 and view_name = :2',
              p_bind_1_name => ':1', p_bind_1_value => p_owner,
              p_bind_2_name => ':2', p_bind_2_value => p_view_name);
exception
  when no_data_found then
    null;  
end print_obj_info_view;

procedure print_obj_info_mview (p_owner varchar2, p_mview_name varchar2)
is
  l_cols_string long;
  l_table_name varchar2(30 char); 
  l_object_id number;
begin
  for m in (select /*+ xplan_exec_marker */ container_name, compile_state, staleness, last_refresh_date
              from sys.all_mviews 
             where owner = p_owner
               and mview_name = p_mview_name)
  loop
    l_table_name := m.container_name;
    print ('compile_state: '||m.compile_state||' staleness: '||m.staleness
       ||' last_refresh_date: '||to_char (m.last_refresh_date, 'yyyy-mm-dd/hh24:mi:ss'));
  end loop;
     
  for c in (select /*+ xplan_exec_marker */ column_id, column_name, data_type 
             from sys.all_tab_cols
            where owner      = p_owner
              and table_name = l_table_name
            order by column_id) 
  loop
    l_cols_string := l_cols_string||'#'||c.column_id||' '||c.column_name ||'('||c.data_type||'),';  
  end loop;
  print ('view columns: '||rtrim(l_cols_string,','));
  
  print_long (p_query => 'select /*+ xplan_exec_marker */ query from sys.all_mviews where owner = :1 and mview_name = :2',
              p_bind_1_name => ':1', p_bind_1_value => p_owner,
              p_bind_2_name => ':2', p_bind_2_value => p_mview_name);
              
  select /*+ xplan_exec_marker */ object_id
    into l_object_id
    from sys.all_objects
   where owner = p_owner
     and object_name = l_table_name
     and object_type = 'TABLE';
    
  print ('table holding MV data:');   
  print_cache_table_infos (l_object_id);  
exception
  when no_data_found then
    null;  
end print_obj_info_mview;

procedure print_obj_info_fixed_view (p_owner varchar2, p_view_name varchar2)
is
  l_cols_string long;
  l_view_definition sys.v_$fixed_view_definition.view_definition%type;
begin
  for c in (select /*+ xplan_exec_marker */ column_id, column_name, data_type 
             from sys.all_tab_cols
            where owner = p_owner
              and table_name = replace (p_view_name, 'V$', 'V_$')
            order by column_id) 
  loop
    l_cols_string := l_cols_string||'#'||c.column_id||' '||c.column_name ||'('||c.data_type||'),';  
  end loop;
  print ('fixed view columns: '||rtrim(l_cols_string,','));
  
  select /*+ xplan_exec_marker */ view_definition
    into l_view_definition
    from sys.v_$fixed_view_definition
   where view_name = p_view_name;
   
  print (l_view_definition);
exception
  when no_data_found then
    null;
end print_obj_info_fixed_view;

procedure print_obj_info_assoc_stats (p_owner varchar2, p_name varchar2, p_type_str varchar2)
is
  l_str      varchar2(300 char);
  l_str_cost varchar2(300 char);
  l_str_stat varchar2(300 char);
begin
  if p_type_str not in ('FUNCTION', 'PACKAGE', 'TYPE', 'INDEXTYPE') then
    return;
  end if;
  
  for a in (select /*+ xplan_exec_marker */ def_selectivity, def_cpu_cost, def_io_cost, def_net_cost,
                   statstype_schema, statstype_name
              from sys.all_associations
             where object_owner = p_owner
               and object_name  = p_name
               and object_type  = p_type_str)
  loop
    l_str := 'ASSOCIATED STATISTICS: ';
    if a.def_selectivity is not null then l_str := l_str || ' default selectivity ('||a.def_selectivity||')'; end if;
    l_str_cost := '';
    if a.def_cpu_cost  is not null then l_str_cost := l_str_cost || ' cpu='||a.def_cpu_cost; end if;
    if a.def_io_cost   is not null then l_str_cost := l_str_cost || ' io=' ||a.def_io_cost ; end if;
    if a.def_net_cost  is not null then l_str_cost := l_str_cost || ' net='||a.def_net_cost; end if;
    if l_str_cost is not null then
      l_str := l_str || ' default cost ('||trim(l_str_cost)||')';
    end if; 
    if a.statstype_schema is not null then
      l_str := l_str || ' using '||a.statstype_schema||'.'||a.statstype_name;
    end if;
    print (l_str);
  end loop;
end print_obj_info_assoc_stats;

procedure print_obj_info_dba_source (p_owner varchar2, p_name varchar2, p_type_str varchar2)
is
begin
  for l in (select /*+ xplan_exec_marker */ text 
              from sys.all_source
             where owner = p_owner
               and name = p_name
               and type = p_type_str
             order by line)
  loop
    print (l.text);
  end loop;
end print_obj_info_dba_source;

procedure print_objinfos
is
  l_dot_1 number;
  l_dot_2 number;
  l_object_str varchar2(100 char);
  l_type_str   varchar2(100 char);
  l_owner      varchar2(100 char);
  l_name       varchar2(100 char);
begin
  l_object_str := m_all_non_tab_objects.first;
  loop
    exit when l_object_str is null;
 
    l_dot_1 := instr (l_object_str, '.', 1);
    l_dot_2 := instr (l_object_str, '.', l_dot_1+1);
    l_type_str := substr (l_object_str, 1, l_dot_1-1);
    l_owner    := substr (l_object_str, l_dot_1+1, (l_dot_2-l_dot_1-1) );
    l_name     := substr (l_object_str, l_dot_2+1 );
    
    --print (l_type_str||' '||l_owner||' '||l_name);
    if l_type_str not in ('SYNONYM','SEQUENCE','UNKNOWN_OBJECT_TYPE') then
      print ('############################################# '||
             case when l_type_str != 'SUMMARY' then lower(l_type_str) else '(summary) materialized view' end
             ||' '||l_owner||'.'||l_name||' ###');
    end if;
   
    if l_type_str in ('SYNONYM','SEQUENCE') then
      null;
    elsif l_type_str = 'VIEW' then
      print_obj_info_view (l_owner, l_name);
    elsif l_type_str = 'FIXED VIEW' then
      print_obj_info_fixed_view (l_owner, l_name);
    -- PACKAGE BODY and TYPE BODY should not be possible for SQL and PL/SQL
    elsif l_type_str in ('FUNCTION','PROCEDURE','TYPE','TYPE BODY','PACKAGE','PACKAGE BODY','TRIGGER') then
      print_obj_info_assoc_stats (l_owner, l_name, l_type_str);
      print_obj_info_dba_source  (l_owner, l_name, l_type_str);
    elsif l_type_str in ('SUMMARY') then
      print_obj_info_mview (l_owner, l_name);
    elsif l_type_str in ('INDEX TYPE') then
      print_obj_info_assoc_stats (l_owner, l_name, 'INDEXTYPE');
      print ('xplan: infos for index types not implemented');
    elsif l_type_str in ('OPERATOR') then
      print ('xplan: infos for operators not implemented');
    end if;
    
    l_object_str := m_all_non_tab_objects.next (l_object_str);
  end loop;
end print_objinfos;


