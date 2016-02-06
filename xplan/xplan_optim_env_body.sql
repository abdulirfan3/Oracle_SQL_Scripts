--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

procedure optim_env_init_print_sys_pars
is
  l_line varchar2(500 char);
begin
  if :OPT_PLAN_ENV = 'N' then
    return;
  end if;
  
  -- put sys optimizer parameters in global hash table
  mcf_reset (p_default_execs         => to_number(null), -- ignored
             p_stat_default_decimals => 0, -- ignored
             p_stex_default_decimals => to_number(null) -- suppress disaply if stat/exec
            );
  mcf_add_line_char ('optimizer param name', 'value', null);
  for r in (    select /*+ xplan_exec_marker */ name, nvl(value,'*null*') as value, isdefault
  &COMM_IF_GT_9I. from sys.gv_$system_parameter 
  &COMM_IF_GT_9I.where inst_id = :OPT_INST_ID 
  &COMM_IF_GT_9I.  and name in ('active_instance_count', 'bitmap_merge_area_size', 'cpu_count', 'cursor_sharing', 'hash_area_size',
  &COMM_IF_GT_9I.               'is_recur_flags', 'optimizer_capture_sql_plan_baselines', 'optimizer_dynamic_sampling',
  &COMM_IF_GT_9I.               'optimizer_features_enable', 'optimizer_index_caching', 'optimizer_index_cost_adj', 'optimizer_mode',
  &COMM_IF_GT_9I.               'optimizer_secure_view_merging', 'optimizer_use_invisible_indexes', 'optimizer_use_pending_statistics',
  &COMM_IF_GT_9I.               'optimizer_use_sql_plan_baselines', 'parallel_ddl_mode', 'parallel_degree', 'parallel_dml_mode',
  &COMM_IF_GT_9I.               'parallel_execution_enabled', 'parallel_query_default_dop', 'parallel_query_mode', 'parallel_threads_per_cpu',
  &COMM_IF_GT_9I.               'pga_aggregate_target', 'query_rewrite_enabled', 'query_rewrite_integrity', 'result_cache_mode',
  &COMM_IF_GT_9I.               'skip_unusable_indexes', 'sort_area_retained_size', 'sort_area_size', 'star_transformation_enabled',
  &COMM_IF_GT_9I.               'statistics_level', 'transaction_isolation_level', 'workarea_size_policy')
  &COMM_IF_LT_10G  from sys.gv_$sys_optimizer_env
  &COMM_IF_LT_10G.where inst_id = :OPT_INST_ID 
                  order by name)
  loop
    m_optim_env_sys_params(r.name) := r.value;
    mcf_add_line_char (case when r.isdefault in ('YES','TRUE') then r.name else upper(r.name) end, r.value, null);
  end loop;
  
  -- display sys optimizer parameters
  print ('optimizer parameters instance(sys) settings:');
  mcf_prepare_output (p_num_columns => 3);
  loop
    l_line := mcf_next_output_line;
    exit when l_line is null;
    print (l_line);
  end loop;
end optim_env_init_print_sys_pars;

procedure optim_env_print_sql_pars (
  p_address       raw, 
  p_hash_value    number, 
  p_child_number  number
)
is
  &COMM_IF_LT_10G. l_line varchar2(500 char);
  &COMM_IF_LT_10G. l_num_params_found int := 0;
begin
  if :OPT_PLAN_ENV = 'N' then
    return;
  end if;
  
  &COMM_IF_GT_9I.  print ('gv$sql_optimizer_env does not exist before 10g.');
  
  -- display sql optimizer parameters
  &COMM_IF_LT_10G. mcf_reset (p_default_execs         => to_number(null), -- ignored
  &COMM_IF_LT_10G.            p_stat_default_decimals => 0, -- ignored
  &COMM_IF_LT_10G.            p_stex_default_decimals => to_number(null) -- suppress disaply if stat/exec
  &COMM_IF_LT_10G.           );
  &COMM_IF_LT_10G. mcf_add_line_char ('optimizer param name', 'value', null);
  &COMM_IF_LT_10G. for r in (select /*+ xplan_exec_marker */ name, nvl(value,'*null*') as value 
  &COMM_IF_LT_10G.             from sys.gv_$sql_optimizer_env
  &COMM_IF_LT_10G.            where inst_id      = :OPT_INST_ID 
  &COMM_IF_LT_10G.              and address      = p_address
  &COMM_IF_LT_10G.              and hash_value   = p_hash_value
  &COMM_IF_LT_10G.              and child_number = p_child_number
  &COMM_IF_LT_10G.            order by name)
  &COMM_IF_LT_10G. loop
  &COMM_IF_LT_10G.   if not m_optim_env_sys_params.exists(r.name) or m_optim_env_sys_params(r.name) != r.value then
  &COMM_IF_LT_10G.     mcf_add_line_char (r.name, r.value, null);
  &COMM_IF_LT_10G.     l_num_params_found := l_num_params_found + 1;
  &COMM_IF_LT_10G.   end if;
  &COMM_IF_LT_10G. end loop;
  
  &COMM_IF_LT_10G. if l_num_params_found > 0 then 
  &COMM_IF_LT_10G.   print ('WARNING: '||l_num_params_found || ' params in gv$sql_optimizer_env are not the same as instance ones:');
  &COMM_IF_LT_10G.   mcf_prepare_output (p_num_columns => least (l_num_params_found, 3));
  &COMM_IF_LT_10G.   loop
  &COMM_IF_LT_10G.     l_line := mcf_next_output_line;
  &COMM_IF_LT_10G.     exit when l_line is null;
  &COMM_IF_LT_10G.     print (l_line);
  &COMM_IF_LT_10G.   end loop;
  &COMM_IF_LT_10G. else
  &COMM_IF_LT_10G.   print ('all params in gv$sql_optimizer_env are the same as instance ones.');
  &COMM_IF_LT_10G. end if;
end optim_env_print_sql_pars;

procedure optim_env_add_sys_stats_to_mcf (p_name varchar2, p_insert_general boolean default false)
is
  l_status VARCHAR2(100 char);
  l_dstart date;
  l_dstop  date;
  l_value  number;
  SYS_STAT_UNABLE_GET exception;
  pragma exception_init (SYS_STAT_UNABLE_GET, -20003);
  SYS_STAT_NOT_EXISTS exception;
  pragma exception_init (SYS_STAT_NOT_EXISTS, -20004);
begin
  
  dbms_stats.get_system_stats (
    status    => l_status,
    dstart    => l_dstart,
    dstop     => l_dstop,
    pname     => p_name,
    pvalue    => l_value
  );
  
  if p_insert_general then
    mcf_add_line_char ('status', lower(l_status), null);
    mcf_add_line_char ('gathering start', to_char (l_dstart, 'yyyy-mm-dd/hh24:mi:ss'), null);
    mcf_add_line_char ('gathering stop',  to_char (l_dstop,  'yyyy-mm-dd/hh24:mi:ss'), null);
  end if;
 
  if l_value is not null then
    mcf_add_line      (lower(p_name), l_value);
  else
    mcf_add_line_char (lower(p_name), 'null', null);
  end if;
exception
  when SYS_STAT_UNABLE_GET then
     mcf_add_line_char (lower(p_name), 'no value found', null);
  when SYS_STAT_NOT_EXISTS then
     mcf_add_line_char (lower(p_name), 'not existent', null);
end optim_env_add_sys_stats_to_mcf;

procedure optim_env_print_sys_stats
is
  l_line varchar2(500 char);
begin
  mcf_reset (p_default_execs         => to_number(null), -- ignored
             p_stat_default_decimals => 0, -- ignored
             p_stex_default_decimals => to_number(null) -- suppress disaply if stat/exec
            );
  mcf_add_line_char ('system statistic', 'value', null);
  
  optim_env_add_sys_stats_to_mcf ('CPUSPEED', true);
  &COMM_IF_LT_10G. optim_env_add_sys_stats_to_mcf ('CPUSPEEDNW');
  optim_env_add_sys_stats_to_mcf ('SREADTIM');
  optim_env_add_sys_stats_to_mcf ('MREADTIM');
  optim_env_add_sys_stats_to_mcf ('MBRC'); 
  &COMM_IF_LT_10G. optim_env_add_sys_stats_to_mcf ('IOSEEKTIM');
  &COMM_IF_LT_10G. optim_env_add_sys_stats_to_mcf ('IOTFRSPEED');
  optim_env_add_sys_stats_to_mcf ('MAXTHR'); 
  optim_env_add_sys_stats_to_mcf ('SLAVETHR');
  
  print ('optimizer system statistics:');
  mcf_prepare_output (p_num_columns => 3);
  loop
    l_line := mcf_next_output_line;
    exit when l_line is null;
    print (l_line);
  end loop;
end optim_env_print_sys_stats;
  