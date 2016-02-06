--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

/*
type ref_object_t is record (
  object_id            int,
  object_type          varchar2(30 char),
  object_owner         varchar2(30 char),
  object_name          varchar2(30 char),
  base_table_object_id int,
  base_table_owner     varchar2(30 char),
  base_table_name      varchar2(30 char)
); */

function calc_base_table_object_id (p_object_id int)
return int
is
begin
  -- N.B. Even for partitioned tables accessed with FROM T PARTITION(P),
  -- gv$sql_plan.object# is always the object_id of the table, not the partition.
  -- Same for partitioned indexes.
  for o in (select /*+ xplan_exec_marker */ owner, object_name, object_type
              from sys.all_objects
             where object_id = p_object_id)
  loop
    if o.object_type = 'TABLE' then
      return p_object_id;
    elsif o.object_type in ('SEQUENCE', 'VIEW') then
      return null;
    elsif o.object_type in ('INDEX') then
      for o2 in (select /*+ xplan_exec_marker */ table_owner, table_name
                   from sys.all_indexes
                  where owner = o.owner
                    and index_name = o.object_name)
      loop
        for o3 in (select /*+ xplan_exec_marker */ object_id
                     from sys.all_objects
                    where object_type = 'TABLE'
                      and owner = o2.table_owner
                      and object_name  = o2.table_name)
        loop
          return o3.object_id;
        end loop;
      end loop;
    end if;
  end loop;

  return null;
end calc_base_table_object_id;

function get_cache_base_table_object_id (p_object_id int)
return int
is
begin
  if p_object_id is null then
    return null;
  end if;
  if not m_cache_base_table_object_id.exists(to_char(p_object_id)) then
    m_cache_base_table_object_id(to_char(p_object_id)) := calc_base_table_object_id (to_char(p_object_id));
  end if;
  return to_number(m_cache_base_table_object_id (to_char(p_object_id)));
end get_cache_base_table_object_id;

procedure cache_obj_infos (p_object_id int)
is
begin
  if not m_cache_obj_infos.exists (to_char(p_object_id)) then
    declare
      l_obj_infos obj_infos_t;
    begin
      for r in (select /*+ xplan_exec_marker */ owner, object_name, object_type
                 from sys.all_objects
                where object_id = p_object_id)
      loop
        --if r.object_type <> 'TABLE' then
        --  raise_application_error (-20001, 'object_id="'||p_object_id||'" is of type "'||r.object_type||'", not TABLE.');
        --end if;
        l_obj_infos.object_type := r.object_type;
        l_obj_infos.owner       := r.owner;
        l_obj_infos.object_name := r.object_name;
      end loop;
      m_cache_obj_infos(to_char(p_object_id)) := l_obj_infos;
    end;
  end if;
end cache_obj_infos;

function get_cache_obj_name (p_object_id int)
return varchar2
is
begin
  if p_object_id is null then
    return null;
  end if;
  cache_obj_infos (p_object_id);
  return m_cache_obj_infos(to_char(p_object_id)).object_name;
end get_cache_obj_name;

function get_cache_obj_owner (p_object_id int)
return varchar2
is
begin
  if p_object_id is null then
    return null;
  end if;
  cache_obj_infos (p_object_id);
  return m_cache_obj_infos(to_char(p_object_id)).owner;
end get_cache_obj_owner;

function get_virtual_col_expr (
  p_table_owner   varchar2,
  p_table_name    varchar2,
  p_virt_col_name varchar2
)
return varchar2
is
  l_ret long;
begin
  -- try FBI expression
  for i in (select /*+ xplan_exec_marker */ index_owner, index_name, column_position
              from sys.all_ind_columns 
             where table_owner = p_table_owner and table_name = p_table_name
               and column_name = p_virt_col_name)
  loop
    for e in (select /*+ xplan_exec_marker */ column_expression 
                from sys.all_ind_expressions
               where table_owner = p_table_owner and table_name = p_table_name
                 and index_owner = i.index_owner and index_name = i.index_name
                 and column_position = i.column_position)
    loop
      if l_ret != e.column_expression then
        return 'INTERNAL ERROR conflicting virtual col defs found for'||p_virt_col_name;
      end if;
      if l_ret is null then
        l_ret := e.column_expression;
      end if;
    end loop;
  end loop;
  l_ret := 'I:' || l_ret;
  
  -- try multi-column expression 
  &COMM_IF_LT_11G  if l_ret is null then 
  &COMM_IF_LT_11G.   for e in (select /*+ xplan_exec_marker */ extension
  &COMM_IF_LT_11G.               from sys.all_stat_extensions
  &COMM_IF_LT_11G.              where owner = p_table_owner and table_name = p_table_name
  &COMM_IF_LT_11G.                and extension_name = p_virt_col_name)
  &COMM_IF_LT_11G.   loop
  &COMM_IF_LT_11G.     l_ret := 'E:'|| e.extension;
  &COMM_IF_LT_11G.   end loop;
  &COMM_IF_LT_11G. end if;
  return l_ret;
end get_virtual_col_expr;

function get_part_key_list (
  p_owner       varchar2, 
  p_name        varchar2, 
  p_object_type varchar2
)
return varchar2
is
  l_ret varchar2(500 char);
begin
  for r in (select /*+ xplan_exec_marker */ column_name 
              from sys.all_part_key_columns
             where owner       = p_owner
               and name        = p_name
               and object_type = p_object_type
             order by column_position)
  loop
    l_ret := l_ret || r.column_name || ', ';
  end loop;
  return rtrim (l_ret, ', ');
end get_part_key_list;

function get_subpart_key_list (
  p_owner       varchar2, 
  p_name        varchar2, 
  p_object_type varchar2
)
return varchar2
is
  l_ret varchar2(500 char);
begin
  for r in (select /*+ xplan_exec_marker */ column_name 
              from sys.all_subpart_key_columns
             where owner       = p_owner
               and name        = p_name
               and object_type = p_object_type
             order by column_position)
  loop
    l_ret := l_ret || r.column_name || ', ';
  end loop;
  return rtrim (l_ret, ', ');
end get_subpart_key_list;

procedure print_table_infos (p_object_id int)
is
  type t_prog_number is table of binary_integer index by varchar2(61 char);
  l_index_number   t_prog_number;
  l_cons_u_number  t_prog_number;
  l_cons_r_number  t_prog_number;
  l_cons_r2_number t_prog_number;
  type t_virt_expressions is table of varchar2(2000 char) index by varchar2(30 char);
  l_virt_expressions t_virt_expressions;
  l_table_owner varchar2(30) := get_cache_obj_owner (p_object_id);
  l_table_name  varchar2(30) := get_cache_obj_name  (p_object_id);
  l_scf  scf_state_t;
  l_iot_type    sys.all_tables.iot_type%type;
  l_partitioned sys.all_tables.partitioned%type;
  l_temporary   sys.all_tables.temporary%type;
  l_duration    sys.all_tables.duration%type;
  l_tmp long;
  l_tmp2 varchar2(1 char);
  l_data_mod varchar2(100 char);
  l_num_rows number;
  l_columns_names_inited boolean;
begin
  -- label each index with a progressive number
  for i in (select /*+ xplan_exec_marker */
                   owner index_owner, index_name
              from sys.all_indexes
             where table_owner = l_table_owner and table_name = l_table_name
             order by index_name, owner -- keep this row aligned with rows labeled as "block b001" 
           )
  loop
    l_index_number(i.index_owner||'.'||i.index_name) := l_index_number.count;
  end loop;
  -- label each unique/reference constraint with a progressive number
  -- UQ and from-this-table-to-others FK
  for co in (select /*+ xplan_exec_marker */ constraint_name, constraint_type
               from sys.all_constraints
              where owner = l_table_owner and table_name = l_table_name
                and constraint_type in ('U','R')
              order by decode (constraint_type,'P',1,'U',2,'R',3), constraint_name -- keep this row aligned with rows labeled as "block b003"
           )
  loop
    if co.constraint_type = 'U' then
      l_cons_u_number (co.constraint_name) := l_cons_u_number.count;
    elsif co.constraint_type = 'R' then
      l_cons_r_number (co.constraint_name) := l_cons_r_number.count;
    end if;
  end loop;
   
  --------------- table ---------------
  print ('############################################# table '||l_table_owner||'.'||l_table_name||' ###');
  
  begin
    select iot_type, partitioned, temporary, duration, num_rows
      into l_iot_type, l_partitioned, l_temporary, l_duration, l_num_rows
      from sys.all_tables
     where owner = l_table_owner and table_name = l_table_name;
  exception
    when no_data_found then
      print (l_table_owner||'.'||l_table_name||' not found in all_tables.');
      return;
  end;
  
  if l_temporary = 'Y' then
    print ('GLOBAL TEMPORARY TABLE on commit '|| case when l_duration = 'SYS$SESSION' then 'PRESERVE' else 'delete' end ||' rows'); 
  end if;
  
  if l_partitioned='YES' then
    for r in (select /*+ xplan_exec_marker */ partitioning_type, subpartitioning_type 
                from sys.all_part_tables
               where owner = l_table_owner and table_name = l_table_name)
    loop
      print ('PARTITIONED BY '||r.partitioning_type||' ( '||get_part_key_list(l_table_owner,l_table_name,'TABLE')||' ) ');
      if r.subpartitioning_type<>'NONE' then
         print ( 'SUBPARTITIONED BY '||r.subpartitioning_type||' ( '||get_subpart_key_list(l_table_owner,l_table_name,'TABLE')||' ) ');
      end if;
    end loop;
  end if;
  print (l_iot_type);
  
  -- dbms_metadata.get_ddl for table
  &COMM_IF_NO_DBMS_METADATA. print('---- output of dbms_metadata.get_ddl ----');
  &COMM_IF_NO_DBMS_METADATA. print_clob( dbms_metadata.get_ddl( 'TABLE', l_table_name, l_table_owner) );
  
  -- columns
  scf_reset (l_scf);
  l_virt_expressions.delete;
  for c in (select /*+ xplan_exec_marker */ column_id, internal_column_id, column_name, nullable, 
                   data_type, data_length, data_precision, data_scale,
                   char_used, char_length, hidden_column, virtual_column
              from sys.all_tab_cols
             where owner = l_table_owner and table_name = l_table_name
             order by column_id, internal_column_id -- keep this row aligned with rows labeled as "block b002"
            )
  loop
    l_data_mod := '';
    if c.data_type in ('NUMBER') then
      if c.data_precision is not null or c.data_scale is not null then 
        l_data_mod := ' ('||nvl(c.data_precision,38)||','||c.data_scale||')';
      end if;
    elsif c.data_type in ('FLOAT') then
      l_data_mod := ' ('||c.data_precision||')';
    -- VARCHAR2, NVARCHAR2, CHAR, NCHAR are the only types that can have CHAR length semantics
    elsif c.data_type in ('VARCHAR2', 'VARCHAR', 'NVARCHAR2', 'NVARCHAR', 'CHAR', 'NCHAR') then
      if c.char_used = 'C' then
        l_data_mod := ' ('||c.char_length||' char)';
      else
        l_data_mod := ' ('||c.data_length||' byte)';
      end if;
    elsif c.data_type in ('RAW') then
      l_data_mod := ' ('||c.data_length||')';  
    end if;
    scf_add_elem (l_scf, 'Id'     , c.column_id);
    scf_add_elem (l_scf, 'IId'    , c.internal_column_id);
    scf_add_elem (l_scf, 'V'      , case when c.virtual_column = 'NO' then 'N' else 'Y' end);
    scf_add_elem (l_scf, 'ColName', c.column_name);
    scf_add_elem (l_scf, 'Type'   , c.data_type||l_data_mod);
    scf_add_elem (l_scf, 'Null'   , case when c.nullable = 'N' then 'NOT' else 'yes' end);
    if c.virtual_column ='YES' then
      l_tmp := get_virtual_col_expr (l_table_owner, l_table_name, c.column_name);
      l_virt_expressions (c.column_name) := l_tmp;
    else
      l_tmp := null;
    end if;
    scf_add_elem (l_scf, 'Expression', substr (l_tmp, 1, 10), p_sep_mid => 'trunc' );
  end loop;
  -- add to each indexed column a pointer to indexing index (via index#)
  for i in (select /*+ xplan_exec_marker */
                   owner index_owner, index_name, uniqueness
              from sys.all_indexes
             where table_owner = l_table_owner and table_name = l_table_name
             order by index_name, owner -- keep this row aligned with rows labeled as "block b001" 
           ) 
  loop
    l_tmp := to_char(l_index_number(i.index_owner||'.'||i.index_name));
    for r in (select /*+ xplan_exec_marker */ ic.column_position
                from sys.all_tab_cols c, sys.all_ind_columns ic
               where c.owner = l_table_owner and c.table_name = l_table_name
                 and c.column_name = ic.column_name(+)
                 and ic.table_owner(+) = l_table_owner and ic.table_name(+) = l_table_name
                 and ic.index_owner(+) = i.index_owner and ic.index_name(+) = i.index_name
               order by c.column_id, c.internal_column_id -- keep this row aligned with rows labeled as "block b002"
             )
    loop
      scf_add_elem (l_scf, l_tmp, r.column_position, p_sep_mid => case when i.uniqueness='UNIQUE' then 'U' end);
    end loop;
  end loop;
  
  -- al new
  scf_print_output (l_scf, 'INTERNAL ERROR : no columns infos found', 'INTERNAL ERROR : no columns infos found(aux)');
  scf_reset (l_scf);
  
  l_columns_names_inited := false;
  
  -- add to each constrained column a label marking it as constrained
  -- 1) UQ and from-this-table-to-others FK
  for co in (select /*+ xplan_exec_marker */ constraint_name, constraint_type
               from sys.all_constraints
              where owner = l_table_owner and table_name = l_table_name
                and constraint_type in ('P','U','R')
              order by decode (constraint_type,'P',1,'U',2,'R',3), constraint_name -- keep this row aligned with rows labeled as "block b003"
           )
  loop
    if co.constraint_type = 'P' then
      l_tmp := 'P';
    elsif co.constraint_type = 'U' then
      l_tmp := 'U'||to_char(l_cons_u_number (co.constraint_name));
    elsif co.constraint_type = 'R' then
      l_tmp := 'R'||to_char(l_cons_r_number (co.constraint_name));
    end if;
    -- mark every PK/FK constraint with at least a FK from another table to the current one
    l_tmp2 := '';
    if co.constraint_type in ('P','U') then
      for r in (select constraint_name
                  from sys.all_constraints
                 where constraint_type = 'R'
                   and r_owner = l_table_owner and r_constraint_name = co.constraint_name
                   and rownum = 1
               )
      loop
        -- dbms_output.put_line ('on '||co.constraint_name||' fk from '||r.constraint_name);
        l_tmp2 := 'R';
      end loop;
    end if;
    for c in (select /*+ xplan_exec_marker */ c.column_id, c.internal_column_id, c.virtual_column, c.column_name, cc.position
                from sys.all_tab_cols c, sys.all_cons_columns cc
               where c.owner = l_table_owner and c.table_name = l_table_name
                 and c.column_name = cc.column_name(+)
                 and cc.owner(+) = l_table_owner and cc.table_name(+) = l_table_name
                 and cc.constraint_name(+) = co.constraint_name 
               order by c.column_id, c.internal_column_id -- keep this row aligned with rows labeled as "block b002"
             )
    loop
      if not l_columns_names_inited then
        scf_add_elem (l_scf, 'Id'     , c.column_id);
        scf_add_elem (l_scf, 'IId'    , c.internal_column_id);
        scf_add_elem (l_scf, 'V'      , case when c.virtual_column = 'NO' then 'N' else 'Y' end);
        scf_add_elem (l_scf, 'ColName', c.column_name);
      end if;
      scf_add_elem (l_scf, l_tmp, case when c.position is null then null else l_tmp2||c.position end);
    end loop;
    l_columns_names_inited := true;
  end loop;
  
  if l_columns_names_inited then
    scf_print_output (l_scf, 'INTERNAL ERROR : no columns infos found', 'INTERNAL ERROR : no columns infos found(cons)');
  end if;
  
  -- virtual column expressions
  if l_virt_expressions.count > 0 then 
    scf_reset (l_scf);
    declare
      l_colname varchar2(30);
    begin
      l_colname := l_virt_expressions.first;
      loop
        exit when l_colname is null;
        scf_add_elem (l_scf, 'ColName', l_colname);
        scf_add_elem (l_scf, 'Expression (full)', l_virt_expressions(l_colname) );
        l_colname := l_virt_expressions.next (l_colname);
      end loop;
    end;  
    scf_print_output (l_scf, 'INTERNAL ERROR: no virt expression found', 'INTERNAL ERROR: no virt expression found(aux)'); 
  end if;  
  
  scf_reset (l_scf);

  for r in (select /*+ xplan_exec_marker */
                   '1' typ, cast(null as number) partition_position, null as partition_name, cast(null as number) subpartition_position, null as subpartition_name, 
                   num_rows, blocks, empty_blocks, avg_row_len, sample_size, last_analyzed, degree
              from sys.all_tables
             where owner = l_table_owner and table_name = l_table_name
             union all
            select '2' typ, partition_position, partition_name, null as subpartition_position, null as subpartition_name, 
                   num_rows, blocks, empty_blocks, avg_row_len, sample_size, last_analyzed, null as degree
              from sys.all_tab_partitions
             where table_owner = l_table_owner and table_name = l_table_name
               and :OPT_PARTINFOS = 'Y'
             union all
            select '3' typ, p.partition_position, s.partition_name, s.subpartition_position, s.subpartition_name, 
                   s.num_rows, s.blocks, s.empty_blocks, s.avg_row_len, s.sample_size, s.last_analyzed, null as degree
              from sys.all_tab_subpartitions s, sys.all_tab_partitions p
             where s.table_owner = l_table_owner and s.table_name = l_table_name
               and p.table_owner = l_table_owner and p.table_name = l_table_name
               and s.partition_name = p.partition_name
               and :OPT_PARTINFOS = 'Y'
             order by typ, partition_position, subpartition_position 
           )
  loop
    scf_add_elem (l_scf, 'Pid'          , r.partition_position);
    scf_add_elem (l_scf, 'Partition'    , r.partition_name);
    scf_add_elem (l_scf, 'SPid'         , r.subpartition_position);
    scf_add_elem (l_scf, 'SubPart'      , r.subpartition_name);
    scf_add_elem (l_scf, 'num_rows'     , r.num_rows);
    scf_add_elem (l_scf, 'blocks'       , r.blocks);
    scf_add_elem (l_scf, 'empty_blocks' , r.empty_blocks);
    scf_add_elem (l_scf, 'avg_row_len'  , r.avg_row_len);
    scf_add_elem (l_scf, 'sample_size'  , r.sample_size);
    scf_add_elem (l_scf, 'last_analyzed', nvl(d2s (r.last_analyzed),'* null *'));
    scf_add_elem (l_scf, 'parallel'     , r.degree); 
  end loop;
  scf_print_output (l_scf, 'INTERNAL ERROR : no table infos found', 'INTERNAL ERROR : no table infos found(aux)');
  if :OPT_PARTINFOS='N' and l_partitioned='YES' then
    print ( 'WARNING: (sub)partitions infos not printed.');
  end if;
  
  -- column statistics
  scf_reset (l_scf);
  for r in (select /*+ xplan_exec_marker */
                   '1' typ, column_id, internal_column_id, column_name, cast(null as number) partition_position, null as partition_name, cast(null as number) subpartition_position, null as subpartition_name, 
                   num_distinct, density, num_nulls, num_buckets, avg_col_len, sample_size, last_analyzed
                   &COMM_IF_LT_10G. , histogram
              from sys.all_tab_cols
             where owner = l_table_owner and table_name = l_table_name
             union all
            select '2' typ, c.column_id, c.internal_column_id, c.column_name, p.partition_position, pcs.partition_name, null as subpartition_position, null as subpartition_name, 
                   pcs.num_distinct, pcs.density, pcs.num_nulls, pcs.num_buckets, pcs.avg_col_len, pcs.sample_size, pcs.last_analyzed
                   &COMM_IF_LT_10G. , pcs.histogram
              from sys.all_part_col_statistics pcs, sys.all_tab_cols c, sys.all_tab_partitions p
             where pcs.owner     = l_table_owner and pcs.table_name = l_table_name
               and c.owner       = l_table_owner and c.table_name   = l_table_name
               and p.table_owner = l_table_owner and p.table_name   = l_table_name
               and pcs.column_name    = c.column_name
               and pcs.partition_name = p.partition_name
               and :OPT_PARTINFOS = 'Y'
             union all
            select '3' typ, c.column_id, c.internal_column_id, c.column_name, p.partition_position, p.partition_name, s.subpartition_position, s.subpartition_name, 
                   scs.num_distinct, scs.density, scs.num_nulls, scs.num_buckets, scs.avg_col_len, scs.sample_size, scs.last_analyzed
                   &COMM_IF_LT_10G. , scs.histogram
              from sys.all_subpart_col_statistics scs, sys.all_tab_cols c, sys.all_tab_subpartitions s, sys.all_tab_partitions p
             where scs.owner     = l_table_owner and scs.table_name = l_table_name
               and c.owner       = l_table_owner and c.table_name   = l_table_name
               and s.table_owner = l_table_owner and s.table_name   = l_table_name
               and p.table_owner = l_table_owner and p.table_name   = l_table_name
               and scs.column_name       = c.column_name
               and scs.subpartition_name = s.subpartition_name -- it seems that subpart names are unique across the whole table
               and s.partition_name      = p.partition_name
               and :OPT_PARTINFOS = 'Y'
             order by typ, column_id, internal_column_id, partition_position, subpartition_position
           )
  loop
    scf_add_elem (l_scf, 'ColName'   , r.column_name);
    scf_add_elem (l_scf, 'Partition' , r.partition_name);
    scf_add_elem (l_scf, 'SubPart'   , r.subpartition_name);
    scf_add_elem (l_scf, 'ndv'       , r.num_distinct);
    scf_add_elem (l_scf, 'dens*#rows'   , r.density * l_num_rows);
    scf_add_elem (l_scf, 'num_nulls' , r.num_nulls);
    scf_add_elem (l_scf, '#bkts'     , r.num_buckets);
    &COMM_IF_LT_10G. scf_add_elem (l_scf, 'hist', case r.histogram 
    &COMM_IF_LT_10G.                                when 'NONE'            then null 
    &COMM_IF_LT_10G.                                when 'FREQUENCY'       then 'FREQ'
    &COMM_IF_LT_10G.                                when 'HEIGHT BALANCED' then 'HB'
    &COMM_IF_LT_10G.                                else r.histogram 
    &COMM_IF_LT_10G.                               end);
    scf_add_elem (l_scf, 'avg_col_len'  , r.avg_col_len);
    scf_add_elem (l_scf, 'sample_size'  , r.sample_size);
    scf_add_elem (l_scf, 'last_analyzed', nvl(d2s (r.last_analyzed),'* null *'));
  end loop;
  scf_print_output (l_scf, 'INTERNAL ERROR : no column statistics infos found', 'INTERNAL ERROR : no column statistics infos found(aux)');
  if :OPT_PARTINFOS='N' and l_partitioned='YES' then
    print ( 'WARNING: (sub)partitions infos not printed.');
  end if;
  
  --------------- indexes ---------------
  for i in (select /*+ xplan_exec_marker */
                   owner index_owner, index_name, partitioned, uniqueness, index_type
              from sys.all_indexes
             where table_owner = l_table_owner and table_name = l_table_name
             order by index_name, owner -- keep this row aligned with rows labeled as "block b001" 
           ) 
  loop
    scf_reset (l_scf);
    print ('### index #'||l_index_number(i.index_owner||'.'||i.index_name)||': '||i.index_owner||'.'||i.index_name);
    l_tmp := null;
    for c in (select column_name, descend 
                from sys.all_ind_columns
               where table_owner = l_table_owner and table_name = l_table_name 
                 and index_owner = i.index_owner and index_name = i.index_name
               order by column_position)
    loop
      l_tmp := l_tmp || c.column_name || case when c.descend='DESC' then ' desc' end ||', ';
    end loop;
    print ('on '||l_table_owner||'.'||l_table_name||' ( '||rtrim(l_tmp,', ')||' )');
             
    print (i.uniqueness||' '||replace(i.index_type,'NORMAL','B+TREE'));
    
    if i.partitioned='YES' then
      for r in (select /*+ xplan_exec_marker */ partitioning_type, subpartitioning_type, locality 
                  from sys.all_part_indexes
                 where owner = i.index_owner and index_name = i.index_name)
      loop
        print (r.locality||' PARTITIONED BY '||r.partitioning_type||' ( '||get_part_key_list(i.index_owner,i.index_name,'INDEX')||' ) ');
        if r.subpartitioning_type<>'NONE' then
           print ( 'SUBPARTITIONED BY '||r.subpartitioning_type||' ( '||get_subpart_key_list(i.index_owner,i.index_name,'INDEX')||' ) ');
        end if;
      end loop;
    end if;
    
    -- dbms_metadata.get_ddl for index
    &COMM_IF_NO_DBMS_METADATA. print('---- output of dbms_metadata.get_ddl ----');
    &COMM_IF_NO_DBMS_METADATA. print_clob( dbms_metadata.get_ddl( 'INDEX', i.index_name, i.index_owner) );
    
    for r in (select /*+ xplan_exec_marker */
                     '1' typ, cast(null as number) partition_position, null as partition_name, cast(null as number) subpartition_position, null as subpartition_name, 
                     distinct_keys, num_rows, blevel, leaf_blocks, clustering_factor as cluf, sample_size, last_analyzed, degree
                from sys.all_indexes
               where owner = i.index_owner and index_name = i.index_name
               union all
              select '2' typ, partition_position, partition_name, null as subpartition_position, null as subpartition_name, 
                     distinct_keys, num_rows, blevel, leaf_blocks, clustering_factor as cluf, sample_size, last_analyzed, null as degree
                from sys.all_ind_partitions
               where index_owner = i.index_owner and index_name = i.index_name
                 and :OPT_PARTINFOS = 'Y'
               union all
              select '3' typ, p.partition_position, s.partition_name, s.subpartition_position, s.subpartition_name, 
                     s.distinct_keys, s.num_rows, s.blevel, s.leaf_blocks, s.clustering_factor as cluf, s.sample_size, s.last_analyzed, null as degree
                from sys.all_ind_subpartitions s, sys.all_ind_partitions p
               where s.index_owner = i.index_owner and s.index_name = i.index_name
                 and p.index_owner = i.index_owner and p.index_name = i.index_name
                 and s.partition_name = p.partition_name
                 and :OPT_PARTINFOS = 'Y'
               order by typ, partition_position, subpartition_position)
    loop
      scf_add_elem (l_scf, 'Partition'    , r.partition_name);
      scf_add_elem (l_scf, 'SubPart'      , r.subpartition_name);
      scf_add_elem (l_scf, 'distinct_keys', r.distinct_keys);
      scf_add_elem (l_scf, 'num_rows'     , r.num_rows);
      scf_add_elem (l_scf, 'blevel'       , r.blevel);
      scf_add_elem (l_scf, 'leaf_blocks'  , r.leaf_blocks);
      scf_add_elem (l_scf, 'cluf'         , r.cluf);
      scf_add_elem (l_scf, 'sample_size'  , r.sample_size);
      scf_add_elem (l_scf, 'last_analyzed', nvl(d2s (r.last_analyzed),'* null *'));
      scf_add_elem (l_scf, 'parallel'     , r.degree);
    end loop;
    scf_print_output (l_scf, 'INTERNAL ERROR : no index infos found', 'INTERNAL ERROR : no index infos found(aux)');
    if :OPT_PARTINFOS='N' and i.partitioned='YES' then
      print ( 'WARNING: (sub)partitions infos not printed.');
    end if;
  end loop;
end print_table_infos;

--type cache_table_printed_infos_t is table of print_buffer_t index by varchar2(20); -- binary_integer is too small for object_id
--m_cache_table_printed_infos cache_table_printed_infos_t;
procedure cache_table_printed_infos (p_object_id int)
is
  l_object_id_char varchar2(20) := to_char(p_object_id);
begin
  if m_cache_table_printed_infos.exists (l_object_id_char) then
    return;
  end if;
  
  enable_print_buffer ('ENABLE');
  
  print_table_infos (p_object_id);
  
  m_cache_table_printed_infos(l_object_id_char) := m_print_buffer;
  
  enable_print_buffer ('DISABLE');
end cache_table_printed_infos;

procedure print_cache_table_infos (p_object_id int)
is
  l_object_id_char varchar2(20) := to_char(p_object_id);
begin
  if p_object_id is null then
    return;
  end if;
  cache_table_printed_infos (p_object_id);
  for i in 0 .. m_cache_table_printed_infos(l_object_id_char).count-1 loop
    print (m_cache_table_printed_infos(l_object_id_char)(i));
  end loop;
end print_cache_table_infos;

-- following procedures are for gv$sql.program_id
procedure cache_program_info (p_program_id int)
is
begin
  if m_cache_program_info.exists (p_program_id) then
    return;
  end if;
  
  m_cache_program_info(p_program_id) := '(not found)'||p_program_id;
  for r in (select /*+ xplan_exec_marker */ owner, object_name, object_type
              from sys.all_objects
             where object_id = p_program_id) 
  loop
    m_cache_program_info(p_program_id) := r.object_type ||' '||r.owner||'.'||r.object_name;
  end loop;
end cache_program_info;

function get_cache_program_info (p_program_id int)
return varchar2
is
begin
  if p_program_id is null then
    return null;
  end if;
  cache_program_info (p_program_id);
  return m_cache_program_info(p_program_id);
end get_cache_program_info;

-- following procedures are for main xplan
procedure cache_username (p_user_id int)
is
begin
  if m_cache_username.exists (p_user_id) then
    return;
  end if;
  
  m_cache_username(p_user_id) := '(not found)'||p_user_id;
  for r in (select /*+ xplan_exec_marker */ username
              from sys.all_users
             where user_id = p_user_id) 
  loop
    m_cache_username(p_user_id) := r.username;
  end loop;
end cache_username;

function get_cache_username (p_user_id int)
return varchar2
is
begin
  if p_user_id is null then
    return null;
  end if;
  cache_username (p_user_id);
  return m_cache_username (p_user_id);
end get_cache_username;

procedure cache_user_id (p_username varchar2)
is
begin
  if m_cache_user_id.exists (p_username) then
    return;
  end if;
  
  m_cache_user_id(p_username) := -1;
  for r in (select /*+ xplan_exec_marker */ user_id
              from sys.all_users
             where username = p_username) 
  loop
    m_cache_user_id(p_username) := r.user_id;
  end loop;
end cache_user_id;

function get_cache_user_id (p_username varchar2)
return varchar2
is
begin
  if p_username is null then
    return null;
  end if;
  cache_user_id (p_username);
  return m_cache_user_id (p_username);
end get_cache_user_id;

