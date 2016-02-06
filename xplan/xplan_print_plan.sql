--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009, 2010, 2012 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

procedure extract_tag_value( p_xml clob, p_tag_name varchar2, p_tag_text out varchar2) 
is
  l_start int;
  l_end   int;
  l_start_marker varchar2(30) := '<' || p_tag_name;
  l_end_marker   varchar2(30) := '</' || p_tag_name || '>' ;
  l_next_chars   varchar2(2 char);
begin
  l_start := dbms_lob.instr (p_xml, l_start_marker, 1);
  if l_start = 0 or l_start is null then
    return;
  end if;
  l_start := l_start + length(l_start_marker);
  
  l_next_chars := dbms_lob.substr (p_xml, 2, l_start);
  if l_next_chars is null or l_next_chars = '/>' then
    return;
  end if;
  l_start := l_start + 1;
   
  l_end := dbms_lob.instr (p_xml, l_end_marker, l_start);
  if l_end = 0 or l_end is null then
    print ('error: end marker not found for tag '||p_tag_name);
    return;
  end if;
  
  if l_end - l_start > 32767 then
    print ('error: tag too long for tag '||p_tag_name);
    return;
  end if;
  
  p_tag_text := dbms_lob.substr (p_xml, l_end - l_start, l_start);
end extract_tag_value;

function extract_tag(
  p_xml        varchar2, 
  p_tag_name   varchar2, 
  p_occurrence int, 
  p_attributes out varchar2, 
  p_value      out varchar2) 
return boolean
is
  l_start_section varchar2(30) := '<' || p_tag_name || ' ';
  l_end_tag       varchar2(30) := '</' || p_tag_name || '>'; 
  l_start         int;
  l_end_start_tag int;
  l_end           int;
begin
  l_start := instr (p_xml, l_start_section, 1, p_occurrence);
  if l_start = 0 or l_start is null then
    return false;
  end if;
  l_start := l_start + length(l_start_section);
  
  l_end_start_tag := instr (p_xml, '>', l_start);
  if l_end_start_tag = 0 or l_end_start_tag is null then
    print ('xml error: xml misformat for tag ' || p_tag_name);
    return false;
  end if;
  
  if substr(p_xml, l_end_start_tag-1, 1) = '/' then
    -- <pippo x="xx" />
    p_attributes := substr (p_xml, l_start, (l_end_start_tag-1) - l_start );
    p_value := null;
  else  
    -- <pippo x="xx" >value</pippo>
    p_attributes := substr (p_xml, l_start, l_end_start_tag - l_start );
    
    l_end := instr (p_xml, l_end_tag, l_end_start_tag+1);
    if l_end = 0 or l_end is null then
      print ('xml error: xml misformat 2 for tag ' || p_tag_name);
      return false;
    end if;
    
    p_value := substr (p_xml, l_end_start_tag+1, l_end - l_end_start_tag - 1); 
  end if;
  
  return true;
end extract_tag;

function get_attribute( p_attributes_str varchar2, p_name varchar2 )
return varchar2
is
  l_pos int; l_start int; l_end int;
begin
  l_pos := instr (p_attributes_str, p_name||'="');
  if l_pos = 0 then return null; end if;
  l_start := instr (p_attributes_str, '"', l_pos);
  if l_start = 0 then return '??'; end if;
  l_start := l_start + 1;
  l_end   := instr (p_attributes_str, '"', l_start);
  if l_end = 0 then return '???'; end if;
  return substr (p_attributes_str, l_start, l_end - l_start);
end get_attribute;

procedure print_peeked_binds(p_other_xml clob)
is
  l_peeked_binds_values long;
  l_peeked_binds_types  long;
  l_peeked_str long;
  l_bind_num  int;
  l_nam  varchar2(30 char);
  l_dty  int;
  l_frm int;
  l_mxl int;
  l_value_hex long;
  l_value_raw long raw;
  l_value long;
  l_type varchar2(100);
  l_value_varchar2  varchar2(32767);
  l_value_nvarchar2 nvarchar2(32767);
  l_value_number    number;
  l_value_date      date;
  l_value_timestamp timestamp;
  &COMM_IF_LT_10G. l_value_binary_float  binary_float;
  &COMM_IF_LT_10G. l_value_binary_double binary_double;
  l_value_rowid     rowid;
  l_bind_attributes long;
  l_bind_found      boolean;
begin
  if p_other_xml is null then
    return;
  end if;

  extract_tag_value ( p_other_xml, 'peeked_binds', l_peeked_str);
  if l_peeked_str is null then
    return;
  end if;
    
  if 1=0 then
    print ('peeked binds : original peeked bind xml section:"'||l_peeked_str||'"');
    --return;
  end if;
  
  -- format: <bind nam=":X" pos="1" dty="1" csi="873" frm="1" mxl="32">58</bind>
  --      or <bind nam=":X" pos="1" dty="1" csi="873" frm="1" mxl="32"/> (for nulls)
  -- max is the MaXLength in bytes
  l_bind_num := 1;
  l_peeked_binds_values := 'peeked binds values:';
  l_peeked_binds_types  := 'peeked binds types :';
  loop
    l_bind_found := extract_tag( l_peeked_str, 'bind', l_bind_num, l_bind_attributes, l_value_hex );
    --print('peeked binds : attrs=['||l_bind_attributes||'] val=['||l_value_hex||']');
    exit when not l_bind_found;
   
    begin
      l_value_raw := hextoraw (l_value_hex);
    exception
      when others then
        raise_application_error (-20089, 'l_value_hex="'||l_value_hex||'" '||sqlerrm);
    end;
    
    l_nam := get_attribute (l_bind_attributes, 'nam');
    l_mxl := to_number (get_attribute (l_bind_attributes, 'mxl'));
    l_dty := to_number (get_attribute (l_bind_attributes, 'dty'));
    l_frm := trim(get_attribute (l_bind_attributes, 'frm'));
    -- For dty codes, see "Call Interface Programmer's Guide", "Datatypes"
    -- Also, "select text from dba_views where view_name = 'USER_TAB_COLS'" gives
    -- a decode function to interpret them. charsetform is the "frm" in the xml string.
    -- Generally frm=2 means NLS charset.
    if l_dty = 1 and l_frm = '1' then -- varchar2 
      dbms_stats.convert_raw_value (l_value_raw, l_value_varchar2);
      l_value := ''''||l_value_varchar2||'''';
      l_type  := 'varchar2('||l_mxl||')';
    elsif l_dty = 1 and l_frm = '2' then -- nvarchar2 
      dbms_stats.convert_raw_value_nvarchar (l_value_raw, l_value_nvarchar2);
      l_value := ''''||l_value_nvarchar2||'''';
      l_type  := 'nvarchar2('||l_mxl||')';
    elsif l_dty = 2 then -- number
      dbms_stats.convert_raw_value (l_value_raw, l_value_number);
      l_value := nvl (to_char(l_value_number), 'null');
      l_type  := 'number('||l_mxl||')';
    elsif l_dty = 12 then -- date
      dbms_stats.convert_raw_value (l_value_raw, l_value_date);
      l_value := nvl (to_char (l_value_date, 'yyyy/mm/dd hh24:mi:ss'), 'null');
      l_type  := 'date';
    elsif l_dty = 23 then -- raw
      l_value := nvl (to_char(l_value_hex), 'null');
      l_type  := 'raw('||l_mxl||')';  
    elsif l_dty = 69  then -- rowid (not fully tested)
      dbms_stats.convert_raw_value_rowid (l_value_raw, l_value_rowid);
      l_value := nvl (rowidtochar (l_value_rowid), 'null');
      l_type  := 'rowid';
    elsif l_dty = 96 and l_frm = '1' then -- char 
      dbms_stats.convert_raw_value (l_value_raw, l_value_varchar2);
      l_value := ''''||l_value_varchar2||'''';
      l_type  := 'char('||l_mxl||')';
    elsif l_dty = 96 and l_frm = '2' then -- nchar 
      dbms_stats.convert_raw_value_nvarchar (l_value_raw, l_value_nvarchar2);
      l_value := ''''||l_value_nvarchar2||'''';
      l_type  := 'nchar('||l_mxl||')';  
    &COMM_IF_LT_10G. elsif l_dty = 100  then -- binary_float
    &COMM_IF_LT_10G.   dbms_stats.convert_raw_value (l_value_raw, l_value_binary_float);
    &COMM_IF_LT_10G.   l_value := to_char (l_value_binary_float);
    &COMM_IF_LT_10G.   l_type  := 'binary_float';
    &COMM_IF_LT_10G. elsif l_dty = 101  then -- binary_double
    &COMM_IF_LT_10G.   dbms_stats.convert_raw_value (l_value_raw, l_value_binary_double);
    &COMM_IF_LT_10G.   l_value := to_char (l_value_binary_double);
    &COMM_IF_LT_10G.   l_type  := 'binary_double';
    elsif l_dty = 180 then -- timestamp
      l_value := '(hex)'||l_value_hex; -- found no way to convert in 10.2
      l_type  := 'timestamp';
    elsif l_dty = 181 then -- timestamp with time zone
      l_value := '(hex)'||l_value_hex; -- found no way to convert in 10.2
      l_type  := 'timestamp with time zone';
    elsif l_dty = 182 then -- interval year to month
      l_value := '(hex)'||l_value_hex; -- found no way to convert in 10.2
      l_type  := 'interval year to month';
    elsif l_dty = 183 then -- interval day to second
      l_value := '(hex)'||l_value_hex; -- found no way to convert in 10.2
      l_type  := 'interval day to second';  
    elsif l_dty = 231 then -- timestamp with local time zone
      l_value := '(hex)'||l_value_hex; -- found no way to convert in 10.2
      l_type  := 'timestamp with local time zone';      
    else
      l_value := '(hex)'||l_value_hex;
      l_type  := '[dty='||l_dty||' frm='||l_frm||' mxl='||l_mxl||']';
    end if;
    l_peeked_binds_values := l_peeked_binds_values || ' ' || l_nam || ' = ' || l_value|| ',';
    l_peeked_binds_types  := l_peeked_binds_types  || ' ' || l_nam || ' = ' || l_type || ',';
    l_bind_num := l_bind_num + 1;
  end loop;
  
  l_peeked_binds_values := rtrim (l_peeked_binds_values, ',');
  l_peeked_binds_types  := rtrim (l_peeked_binds_types , ',');
  
  print (l_peeked_binds_values);
  print (l_peeked_binds_types);
  
end print_peeked_binds;

procedure print_notes(p_other_xml clob)
is
  l_xml long;
  l_info_num int;
  l_info_found boolean;
  l_notes long;
  l_info_attributes varchar2(200);
  l_info_value      varchar2(200);
  l_info_type       varchar2(200);
begin
  if p_other_xml is null then
    return;
  end if;
  
  if dbms_lob.getlength( p_other_xml)  > 32767 then
    print('print_notes: warning: cannot look for notes, other_xml too long');
    return;
  end if;
  
  l_xml := dbms_lob.substr (p_other_xml, 32767, 1);
    
  l_info_num := 1;
  loop
    l_info_found := extract_tag( l_xml, 'info', l_info_num, l_info_attributes, l_info_value );
    --print('print_notes : attrs=['||l_info_attributes||'] val=['||l_info_value||']');
    exit when not l_info_found;
    
    l_info_type := get_attribute( l_info_attributes, 'type' );
    if l_info_type not in ( 'plan_hash', 'db_version', 'parse_schema',  'plan_hash_2' ) then
      l_notes := l_notes || l_info_type || '=' || l_info_value || ' ';
    end if;
    
    l_info_num := l_info_num + 1;
  end loop;
  
  if l_notes is not null then
    print('notes : ' || l_notes );
  end if;
end print_notes;

function adapt_projection(p_txt varchar2)
return varchar2
is
  l_buf varchar2(4000) := replace( replace(p_txt, '"', ''), ' ', '');
  l_open int := 1;
  l_clos int;
begin
  loop
    l_open := instr(l_buf, '[', l_open);
    exit when l_open = 0 or l_open is null;
    l_clos := instr(l_buf, ']', l_open+1);
    exit when l_clos = 0 or l_clos is null;
    l_buf := substr(l_buf, 1, l_open-1) || substr(l_buf, l_clos+1);
  end loop;
  return substr(l_buf, 1, 1000); 
end adapt_projection;

function adapt_predicate(p_txt varchar2)
return varchar2
is
  l_buf varchar2(4000) := replace(p_txt, '"', '');
begin
  return l_buf; 
end adapt_predicate;

procedure print_plan (
  p_inst_id           sys.gv_$sql.inst_id%type,
  p_address           sys.gv_$sql.address%type, 
  p_hash_value        sys.gv_$sql.hash_value%type, 
  p_child_number      sys.gv_$sql.child_number%type,
  p_executions        int,
  p_last_load_time    date,
  p_last_active_time  date default null, -- null if not 10gR2+
  p_sql_plan_baseline varchar2 default null -- null if not 11g+
)
is
  type access_predicates_t     is table of sys.gv_$sql_plan.access_predicates%type index by binary_integer;
  type filter_predicates_t     is table of sys.gv_$sql_plan.filter_predicates%type index by binary_integer;
  type others_t                is table of sys.gv_$sql_plan.other            %type index by binary_integer;
  type base_table_object_ids_t is table of varchar2(1)                       index by varchar2(30);
  l_access_predicates access_predicates_t;
  l_filter_predicates filter_predicates_t;
  l_others            others_t;
  l_base_table_object_ids base_table_object_ids_t;
  l_base_object_id_char varchar2(30);
  l_plan  scf_state_t;
  l_plan2 scf_state_t;
  l_plan3 scf_state_t;
  l_col_tag varchar2(10 char);
  l_execs int;
  l_other_tag  sys.gv_$sql_plan.other_tag%type;
  l_id_min int := 1e6;
  l_id_max int := -1;
  l_id_string varchar2(10 char);
  l_tmp varchar2(1000 char);
  &COMM_IF_LT_10G. l_sql_id          sys.gv_$sql.sql_id%type;
  l_cursor sys_refcursor;
  l_dbms_xplan_tag varchar2(10 char);
  l_dbms_xplan_format varchar2(50 char);
begin
  if '&PLAN_LAST_OR_NULL.' = 'LAST_' then
    l_col_tag        := 'last';
    l_execs          := 1;
    l_dbms_xplan_tag := ' LAST';
  elsif '&PLAN_AVG_PER_EXEC.' = 'Y' then
    l_col_tag        := '/exec';
    l_execs          := p_executions;
  else
    l_col_tag        := 'raw';
    l_execs          := 1; -- a trick, of course
  end if;
  
  if l_execs <= 0 then
    l_execs := null;
  end if;
 
  for s in (select /*+ xplan_exec_marker */ -- 10.2.0.3 columns 
                    -- p.address,
                    -- p.hash_value,
&COMM_IF_LT_10G.       p.sql_id,
&COMM_IF_LT_10G.       p.plan_hash_value,
&COMM_IF_LT_10GR2.     p.child_address,
                       p.child_number,
                    -- p.timestamp,
                       p.operation,
                       p.options,
                       p.object_node,
                       p.object#,
                       p.object_owner,
                       p.object_name,
&COMM_IF_LT_10G.       p.object_alias,
&COMM_IF_LT_10G.       p.object_type,
                       p.optimizer,
                       p.id,
                       p.parent_id,
                       p.depth,
                       p.position,
                       p.search_columns,
                       p.cost,
                       p.cardinality,
                       p.bytes,
                       p.other_tag,
                       p.partition_start,
                       p.partition_stop,
                       p.partition_id,
                       p.other,
                       p.distribution,
                       p.cpu_cost,
                       p.io_cost,
                       p.temp_space,
&COMM_IF_NO_PREDS.     p.access_predicates,
&COMM_IF_NO_PREDS.     p.filter_predicates,
&COMM_IF_LT_10G.       p.projection,
                       --time
&COMM_IF_LT_10G.       p.qblock_name,
&COMM_IF_LT_10G.       p.remarks,
&COMM_IF_LT_10GR2.     p.other_xml,
                       s.executions,
                       s.&PLAN_LAST_OR_NULL.starts         as starts,
                       s.&PLAN_LAST_OR_NULL.output_rows    as output_rows,
                       s.&PLAN_LAST_OR_NULL.cr_buffer_gets as cr_buffer_gets,
                       s.&PLAN_LAST_OR_NULL.cu_buffer_gets as cu_buffer_gets,
                       s.&PLAN_LAST_OR_NULL.disk_reads     as disk_reads,
                       s.&PLAN_LAST_OR_NULL.disk_writes    as disk_writes,
                       s.&PLAN_LAST_OR_NULL.elapsed_time   as elapsed_time,
                       s.policy,
                       s.estimated_optimal_size,
                       s.estimated_onepass_size,
                       s.last_memory_used,
                       s.last_execution,
                       s.last_degree,
                       s.total_executions,
                       s.optimal_executions,
                       s.onepass_executions,
                       s.multipasses_executions,
                       s.active_time,
                       s.max_tempseg_size,
                       s.last_tempseg_size
              from sys.gv_$sql_plan p, sys.gv_$sql_plan_statistics_all s
             where p.inst_id         = p_inst_id 
               and s.inst_id(+)      = p_inst_id
               and p.address         = p_address
               and p.hash_value      = p_hash_value
               and p.child_number    = p_child_number
               and s.address(+)      = p_address
               and s.hash_value(+)   = p_hash_value
               and s.child_number(+) = p_child_number
               and p.id              = s.id(+)
             order by p.id)
  loop
    if s.id < l_id_min then l_id_min := s.id; end if;
    if s.id > l_id_max then l_id_max := s.id; end if;
    &COMM_IF_LT_10G. l_sql_id := s.sql_id;
    &COMM_IF_LT_10G. if s.id = 1 then 
    &COMM_IF_LT_10GR2. print_peeked_binds (s.other_xml); 
    &COMM_IF_LT_10GR2. print_notes (s.other_xml); 
    &COMM_IF_LT_10G.   if p_sql_plan_baseline is not null then print('sql plan baseline : '||p_sql_plan_baseline); end if;
    &COMM_IF_LT_10G. end if;
    l_base_object_id_char := to_char(get_cache_base_table_object_id (s.object#));
    if l_base_object_id_char is not null then
      l_base_table_object_ids (l_base_object_id_char) := 'X';
      if :OPT_TABINFOS = 'BOTTOM' then
        m_all_referenced_object_ids(l_base_object_id_char) := 'X';
      end if;
    end if;
    scf_add_elem (l_plan, 'CR+CU', (s.cr_buffer_gets + s.cu_buffer_gets) / l_execs, p_sep_mid => l_col_tag);
    &COMM_IF_NO_SELF scf_add_self (l_plan, 'CR+CU+', p_self_src => 'CR+CU'); 
    scf_add_elem (l_plan, 'Ela', s.elapsed_time / l_execs, p_sep_mid => l_col_tag, p_sep_bot=>'usec');
    &COMM_IF_NO_SELF scf_add_self (l_plan, 'Ela+', p_self_src => 'Ela'); 
    scf_add_elem (l_plan, 'Id' , s.id       , p_is_auxil => 'Y', p_self_is_id  => 'Y');
    scf_add_elem (l_plan, 'pId', s.parent_id, p_is_auxil => 'Y', p_self_is_pid => 'Y', p_is_hidden => 'Y'); 
    /* scf_add_elem (l_plan, 'pId', s.parent_id); -- TEMP!!
    scf_add_elem (l_plan, 'remarks', s.remarks); -- TEMP!!
    scf_add_elem (l_plan, 'depth', s.depth); -- TEMP!!
    scf_add_elem (l_plan, 'position', s.position); -- TEMP!!
    scf_add_elem (l_plan, 'qblock', s.qblock_name); -- TEMP!!
    scf_add_elem (l_plan, 'optim', s.optimizer); -- TEMP!!
    scf_add_elem (l_plan, 'object#', s.object#); -- TEMP!!*/
    scf_add_elem (l_plan, 'Operation', lpad (' ', s.depth) || s.operation||' '||s.options   );
    scf_add_elem (l_plan, 'Name', s.object_name);
    scf_add_elem (l_plan, 'Table', get_cache_obj_name (get_cache_base_table_object_id (s.object#)));
    scf_add_elem (l_plan, 'TQ', s.object_node);
    scf_add_elem (l_plan, 'Erows', s.cardinality);
    scf_add_elem (l_plan, 'Arows', s.output_rows / l_execs, p_sep_mid => l_col_tag); 
    scf_add_elem (l_plan, 'Cost', s.cost);  
    scf_add_elem (l_plan, 'IoCost', s.io_cost);
    scf_add_elem (l_plan, 'Psta', replace (s.partition_start, 'ROW LOCATION', 'ROWID') ); 
    scf_add_elem (l_plan, 'Psto', replace (s.partition_stop , 'ROW LOCATION', 'ROWID') ); 
    scf_add_elem (l_plan, 'IdP', s.partition_id); 
    l_other_tag := s.other_tag;
    l_other_tag := replace (l_other_tag, 'SERIAL_FROM_REMOTE'           , 'S->R');
    l_other_tag := replace (l_other_tag, 'PARALLEL_FROM_SERIAL'         , 'S->P');
    l_other_tag := replace (l_other_tag, 'PARALLEL_TO_SERIAL'           , 'P->S');  
    l_other_tag := replace (l_other_tag, 'PARALLEL_TO_PARALLEL'         , 'P->P');
    l_other_tag := replace (l_other_tag, 'PARALLEL_COMBINED_WITH_PARENT', 'PCWP');
    l_other_tag := replace (l_other_tag, 'PARALLEL_COMBINED_WITH_CHILD' , 'PCWC');    
    scf_add_elem (l_plan, 'OT', l_other_tag);
    scf_add_elem (l_plan, 'Distr', replace (replace (s.distribution, ' (RANDOM)', '(RAND)'),' (ORDER)', '(ORDER)'));
    --scf_add_elem (l_plan, 'obj alias', s.object_alias);
    --scf_add_elem (l_plan, 'qb_name', s.qblock_name);
    &COMM_IF_NO_PREDS. if s.access_predicates is not null then l_access_predicates(s.id) := adapt_predicate(s.access_predicates); end if;
    &COMM_IF_NO_PREDS. if s.filter_predicates is not null then l_filter_predicates(s.id) := adapt_predicate(s.filter_predicates); end if;
    if s.other is not null then l_others(s.id) := s.other; end if;
    
    scf_add_elem (l_plan2, 'Id' , s.id       , p_is_auxil => 'Y', p_self_is_id  => 'Y');
    scf_add_elem (l_plan2, 'pId', s.parent_id, p_is_auxil => 'Y', p_self_is_pid => 'Y', p_is_hidden => 'Y'); 
    scf_add_elem (l_plan2, 'Starts', s.starts / l_execs, p_sep_mid => l_col_tag);
    scf_add_elem (l_plan2, 'CR', s.cr_buffer_gets / l_execs, p_sep_mid => l_col_tag);
    &COMM_IF_NO_SELF scf_add_self (l_plan2, 'CR+', p_self_src => 'CR'); 
    scf_add_elem (l_plan2, 'CU', s.cu_buffer_gets / l_execs, p_sep_mid => l_col_tag); 
    &COMM_IF_NO_SELF scf_add_self (l_plan2, 'CU+', p_self_src => 'CU'); 
    scf_add_elem (l_plan2, 'diskR', s.disk_reads / l_execs, p_sep_mid => l_col_tag); 
    &COMM_IF_NO_SELF scf_add_self (l_plan2, 'diskR+', p_self_src => 'diskR');
    scf_add_elem (l_plan2, 'diskW', s.disk_writes / l_execs, p_sep_mid => l_col_tag);
    &COMM_IF_NO_SELF scf_add_self (l_plan2, 'diskW+', p_self_src => 'diskW');
    scf_add_elem (l_plan2, 'E0ram', s.estimated_optimal_size, p_sep_bot=>'KB');
    scf_add_elem (l_plan2, 'E1ram', s.estimated_optimal_size, p_sep_bot=>'KB');
    scf_add_elem (l_plan2, 'Aram', s.last_memory_used, p_sep_mid => 'last', p_sep_bot=>'KB');
    scf_add_elem (l_plan2, 'Policy', s.policy);
    scf_add_elem (l_plan2, 'A01M', s.last_execution, p_sep_mid => 'last');
    l_tmp := null;
    if s.optimal_executions > 0 or s.onepass_executions > 0 or s.multipasses_executions > 0 then
      l_tmp := s.optimal_executions||'/'||s.onepass_executions||'/'||s.multipasses_executions;
    end if;
    scf_add_elem (l_plan2, '0/1/M', l_tmp, p_sep_bot=>'#');
    
    scf_add_elem (l_plan2, 'ActTim', s.active_time*10, p_sep_mid => 'avg', p_sep_bot=>'msec');
    scf_add_elem (l_plan2, 'ETmpSpc',  s.temp_space/1024, p_sep_bot=>'KB');
    scf_add_elem (l_plan2, 'ATmpSpcM', s. max_tempseg_size/1024, p_sep_mid => 'max' , p_sep_bot=>'KB');
    scf_add_elem (l_plan2, 'ATmpSpcL', s.last_tempseg_size/1024, p_sep_mid => 'last', p_sep_bot=>'KB');
    &COMM_IF_LT_10G. if :OPT_PLAN_DETAILS = 'Y' then
    &COMM_IF_LT_10G.   scf_add_elem (l_plan3, 'Id', s.id, p_is_auxil => 'Y');
    &COMM_IF_LT_10G.   scf_add_elem (l_plan3, 'Qb_name', s.qblock_name);
    &COMM_IF_LT_10G.   scf_add_elem (l_plan3, 'ObjAlias', s.object_alias);
    &COMM_IF_LT_10G.   scf_add_elem (l_plan3, 'ObjType', s.object_type);
    &COMM_IF_LT_10G.   scf_add_elem (l_plan3, 'Obj', get_cache_obj_name(s.object#));
    &COMM_IF_LT_10G.   scf_add_elem (l_plan3, 'BaseObj', get_cache_obj_name(get_cache_base_table_object_id (s.object#)));
    --&COMM_IF_LT_10G.   scf_add_elem (l_plan3, 'Obj#', s.object#);
    --&COMM_IF_LT_10G.   scf_add_elem (l_plan3, 'BaseObj#', get_cache_base_table_object_id (s.object#));
    &COMM_IF_LT_10G.   scf_add_elem (l_plan3, 'Projection', adapt_projection(s.projection));
    &COMM_IF_LT_10G.   scf_add_elem (l_plan3, 'Remarks', s.remarks);
    &COMM_IF_LT_10G. end if;
  end loop;
  scf_print_output (l_plan, 'no plan found.', 'only aux plan infos found.');
  
  -- filter and access predicates
  for id in l_id_min .. l_id_max loop
    l_id_string := '.'|| to_char (id, '990');
    if l_access_predicates.exists(id) then
      print (l_id_string||' - access[ '||l_access_predicates(id)||' ]');
      l_id_string := rpad ('.', length (l_id_string));
    end if;
    if l_filter_predicates.exists(id) then
      print (l_id_string||' - filter[ '||l_filter_predicates(id)||' ]');
      l_id_string := rpad ('.', length (l_id_string));
    end if;
  end loop;
  -- PX Slave SQL
  if l_others.count > 0 then
    print ('---- PX Slave SQL:');
    for id in l_id_min .. l_id_max loop
      l_id_string := '.'|| to_char (id, '990');
      if l_others.exists(id) then
        print (l_id_string||' - ['||l_others(id)||']');
        l_id_string := rpad ('.', length (l_id_string));
      end if;
    end loop;    
  end if;
  
  &COMM_IF_LT_10G. ash_print_stmt_profile (
  &COMM_IF_LT_10G.   p_inst_id        => p_inst_id       , p_sql_id           => l_sql_id, 
  &COMM_IF_LT_10G.   p_child_number   => p_child_number  , 
  &COMM_IF_LT_10G.   p_last_load_time => p_last_load_time, p_last_active_time => p_last_active_time);
  
  scf_print_output (l_plan2, 'no plan details found.', 'only aux plan details found.',
                    p_note => 'note: stats Aram, A01M, 0/1/M, ActTim do not seem to be always accurate.' );
                    
  scf_print_output (l_plan3, '', '');
  
  -- output from dbms_xplan.display_cursor
  &COMM_IF_NO_DBMS_XPLAN. if l_sql_id is not null then
  &COMM_IF_NO_DBMS_XPLAN.   l_dbms_xplan_format := 'ADVANCED'||l_dbms_xplan_tag;
  &COMM_IF_NO_DBMS_XPLAN.   print ('===== dbms_xplan.display_cursor ('||l_dbms_xplan_format||'):');                    
  &COMM_IF_NO_DBMS_XPLAN.   open l_cursor for 
  &COMM_IF_NO_DBMS_XPLAN.   select /*+ xplan_exec_marker */ plan_table_output
  &COMM_IF_NO_DBMS_XPLAN.   from table (dbms_xplan.display_cursor (l_sql_id, p_child_number, l_dbms_xplan_format));
  &COMM_IF_NO_DBMS_XPLAN.   loop
  &COMM_IF_NO_DBMS_XPLAN.     fetch l_cursor into l_tmp;
  &COMM_IF_NO_DBMS_XPLAN.     if l_cursor%notfound then
  &COMM_IF_NO_DBMS_XPLAN.       close l_cursor;
  &COMM_IF_NO_DBMS_XPLAN.       exit;
  &COMM_IF_NO_DBMS_XPLAN.     end if;
  &COMM_IF_NO_DBMS_XPLAN.     print (l_tmp);
  &COMM_IF_NO_DBMS_XPLAN.   end loop;
  &COMM_IF_NO_DBMS_XPLAN. end if;      
  
  -- print sql-level optimizer env
  optim_env_print_sql_pars (p_address => p_address, p_hash_value => p_hash_value, p_child_number => p_child_number);
  
  -- table infos from data dictionary
  if :OPT_TABINFOS = 'Y' then 
    declare
      l_curr_id varchar2(20);
    begin
      l_curr_id := l_base_table_object_ids.first;
      loop
        exit when l_curr_id is null;
        print_cache_table_infos (l_curr_id);
        l_curr_id := l_base_table_object_ids.next (l_curr_id);
      end loop;
    end;    
  end if;
  
end print_plan;