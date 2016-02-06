-- @xplan "" "sql_id=a1nxudt81v5y7,tabinfos=n,objinfos=n"
-- @xplan "" "sql_id=a1nxudt81v5y7"
--------------------------------------------------------------------------------
-- xplan - fetches and prints from the library cache the statements whose text matches
--         a given "like" expression, and their plan, statistics, plan statistics.
--         For every table accessed by the statement, it prints the table's columns,
--         indexes, constraints, and all CBO related statistics of the table and its indexes,
--         including partition-level ones.
--
--         The goal is to provide all the informations needed to investigate the
--         statement in a concise and complete format.
--
--         For a (commented) output example, see www.adellera.it/scripts_etcetera/xplan
--                
--         This script does NOT require creation of any database objects, a very handy
--         feature inspired by Tanel Poder's "Snapper" utility (http://www.tanelpoder.com/files/scripts/snapper.sql).
--         This script requires SELECT ANY DICTIONARY and SELECT ANY TABLE privileges.
--
-- Usage:    @xplan <sql like> <options, comma-separated>
-- Examples: @xplan "select%from dual" ""
--           @xplan "select%from dual" "order_by=elapsed_time desc"
--           @xplan "select%from dual" "order_by=elapsed_time desc,access_predicates=N" 
--           @xplan "" ""
-- If <sql like> is "last" => display last executed cursor by current session (10g+ only)
--   (same as dbms_xplan.display_cursor with sql_id and cursor_child_no set to null) 
--
-- Options: plan_stats : raw|per_exec|last (default last)
--                       How to print cumulative gv$sql_plan_statistics (e.g. cr_buffer_gets, elapsed_time) 
--                       raw      : prints the raw value 
--                       per_exec : prints the raw value / gv$sql.executions
--                       last     : use the last_ value (e.g. last_cr_buffer_gets, last_elapsed_time) 
--          access_predicates: y|n (default y)
--                             Whether to print or not the access and filter predicates
--                             (useful only in 9i to work around bug 2525630 or one of its variants)
--          lines : <number> (default 150)
--                  Sets the output width
--          module: <sql-like expression> (default null)
--                  Select only statements whose gv$sql.module matches the sql-like expression.
--          action: <sql-like expression> (default null)
--                  Select only statements whose gv$sql.action matches the sql-like expression.
--          hash  : <integer> (default null)
--                  Select only statements whose gv$sql.hash_value matches the provided integer
--          sql_id: <string> (default null)
--                  Select only statements whose gv$sql.sql_id matches the provided string (10g+ only)
--          inst_id: <integer> (default : instance which the sqlplus session is connected to)
--                  Select only statements from the instance whose id matches the provided integer (RAC only; 
--                  the default is ok for non-RAC systems)
--          parsed_by: <integer> | <string>
--                     Select only statements whose gv$sql.parsing_user_id is equal to either <integer> or
--                     the user_id associated with the user whose username is <string>
--          child_number: <integer> (default null)
--                        Select only statements whose gv$sql.child_number matches the provided integer
--          dbms_xplan: y|n (default n)
--                      If y, adds the output of dbms_xplan.display_cursor to the script output (10g+ only).
--          dbms_metadata: y|n|all (default n)
--                      If y or all, adds the output of dbms_metadata.get_ddl to the script output, for each table and index.
--                      If y no segment attribute (STORAGE, TABLESPACE, etc) is printed; if yes, all attributes are printed. .
--          plan_details: y|n (default n)
--                        Print plan details (qb_name, object_alias, object_type, object#(and base table obj#), Projection, Remarks)
--          plan_env: y|n (default y)
--                    Print optimizer environment parameters.
--                    In 10g+ : print gv$sys_optimizer_environment at the report top, then
--                              values from gv$sql_optimizer_environment different from gv$sys_optimizer_environment for each stmt.
--                    In 9i: print main optimizer environment params from gv$system_parameter at the report top only.
--          ash_profile_mins: <integer> (default 15 in 10g+)
--                            Print wait profile from gv$active_session_history (10g+ only).
--                            Only a window <integer> minutes wide is considered. 0 means "do not print".
--                            Warning: of course if this parameter is > 0, you are using ASH/AWR; make sure you are licensed to use it.
--          tabinfos: y|n|bottom (default y) [alias ti]
--                    Print all available informations about tables accessed by the statement.
--                    y      : print infos after each statement
--                    bottom : print infos at the bottom of the report
--          objinfos: y|n (default y) [alias oi]
--                    Print all available informations about non-table objects that the statement depends on (v$object_dependency)
--                    y      : print infos after each statement
--                    bottom : print infos at the bottom of the report
--          partinfos: y|n (default y) [alias pi]
--                     If y, print partitions/subpartitions informations when printing tables accessed by the statement.
--          self: y|n (default y)
--                If y, print self (=not including children) statistics of row source operations
--          order_by: <gv$sql semicolon-separated list of [column|expression]> (default: null)
--                    Order statements by the specified columns/expressions. Ties are ordered by sql_text and child_number.
--                    Use the semicolon instead of the comma in expressions.
--                    For example: "order_by=elapsed_time desc;buffer_gets"
--                                 "order_by=elapsed_time/decode(executions;0;null;executions) desc;buffer_gets"
--          numbers_with_comma: y|n (default y)
--                              If y, display numbers with commas (e.g. 1,234,567.8) 
--          spool_name : name of spool file (default: xplan.lst; default extension: .LST)
--          spool_files: single|by_hash|by_sql_id (default: see below)
--                       Produce a single spool file or one for each different gv$sql.hash_value or gv$sql.sql_id.
--                       If not specified, it defaults to "by_sql_id" if sql_id is set, to "by_hash" if hash is set,
--                       otherwise to "single".
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009, 2010, 2011, 2012 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

define XPLAN_VERSION="2.5.3 23-Aug-2012"
define XPLAN_COPYRIGHT="(C) Copyright 2008-2012 Alberto Dell''Era, www.adellera.it"

set null  "" trimspool on define on escape off pages 50000 tab off arraysize 100 
set echo off verify off feedback off termout off timing off

spool xplan_setup.lst

-- debug:
/*
set echo on verify on feedback on termout on
*/

define SQL_LIKE="&1"
define XPLAN_OPTIONS="&2"

alter session set nls_territory='america';
alter session set nls_language='american';

-- fetch prev_sql_id and prev_hash_value (such as dbms_xplan.display_cursor does) - 10g only
variable PREV_SQL_ID varchar2(15)
variable PREV_CHILD_NUMBER number
declare
  invalid_userenv_par exception;
  pragma exception_init (invalid_userenv_par, -2003);
begin /* xplan_exec_marker */
  -- following statement is from 10.2.0.3 dbms_xplan.display_cursor
  execute immediate 'select /* xplan_exec_marker */ prev_sql_id, prev_child_number from v$session'
                  ||' where sid=userenv(''sid'') and username is not null and prev_hash_value <> 0'
  into :PREV_SQL_ID, :PREV_CHILD_NUMBER;
exception
 when invalid_userenv_par then -- happens in 9i only
   :PREV_SQL_ID       := null;
   :PREV_CHILD_NUMBER := null;
end;
/
print PREV_SQL_ID
print PREV_CHILD_NUMBER

alter session set cursor_sharing=exact;

set termout on
@@xplan_defines.sql
set termout off

spool off

spool &MAIN_BLOCK_SPOOL.

set lines &LINE_SIZE.

set termout on 
-- following statement is just in case the next one fails (due to old versions of sqlplus)
set serveroutput on size 1000000 format wrapped 
set serveroutput on &SERVEROUT_SIZE_CLAUSE format wrapped 

declare /* xplan_exec_marker */ &ERROR_BEFORE_MAIN_BLOCK. -- main block
@@xplan_utilities_vars.sql
@@xplan_mcf_vars.sql
@@xplan_scf_vars.sql
@@xplan_optim_env_vars.sql
@@xplan_tabinfos_vars.sql
@@xplan_objinfos_vars.sql

  m_sql_like          varchar2(300 char) := :SQL_LIKE;
  m_action_like       varchar2(300 char) := :ACTION_LIKE;
  m_module_like       varchar2(300 char) := :MODULE_LIKE;
  m_hash_value        number             := :OPT_HASH_VALUE;  
  m_sql_id            varchar2(30 char)  := :OPT_SQL_ID;  
  m_parsing_user_id   number             := null;
  m_child_number      number             := :OPT_CHILD_NUMBER;  
  
  m_stmt long;
  m_stmt_truncated boolean;
  m_line varchar2(500 char);
  
  l_num_stmts_found int := 0;
  l_stmt_hash_or_id_as_string varchar2(13 char);
  l_stmt_hash_or_id_param     varchar2(6 char);
  l_stmt_length number;
  
  -- referenced sql hash values
  type referenced_sql_hashid_t is table of varchar2(1) index by varchar2(13);
  m_referenced_sql_hashids referenced_sql_hashid_t;
  
@@xplan_utilities_body.sql
@@xplan_mcf_body.sql
@@xplan_scf_body.sql
@@xplan_optim_env_body.sql
@@xplan_ash_body.sql
@@xplan_tabinfos_body.sql
@@xplan_objinfos_body.sql
@@xplan_print_plan.sql

begin
  if :OPT_SPOOL_FILES = 'single' then 
    print ('xplan version &XPLAN_VERSION. &XPLAN_COPYRIGHT.');
    print ('db_name='||:DB_NAME||' instance_name='||:INSTANCE_NAME||' version='||:V_DB_VERSION||' (compatible = '||:V_DB_VERSION_COMPAT||')');
  end if;
  
  -- If <sql like> is 'last' => display last executed cursor by current session
  if lower(m_sql_like) = 'last' then
    &COMM_IF_GT_9I. raise_application_error (-20090, 'cannot pass <sql-like> = "last" before 10g');
    m_sql_id       := :PREV_SQL_ID;
    m_child_number := :PREV_CHILD_NUMBER;
    print ('displaying last executed cursor - sql_id='||m_sql_id||', child_number='||m_child_number);
  end if;
  
  -- convert <parsed_by> into m_parsing_user_id (convert name to user_id if necessary)
  if :OPT_PARSED_BY is not null then
    if is_integer (:OPT_PARSED_BY) then
      m_parsing_user_id := to_number (:OPT_PARSED_BY);
    else
      m_parsing_user_id := get_cache_user_id (:OPT_PARSED_BY);
    end if;
  end if;
  
  if :OPT_SPOOL_FILES = 'single' then 
    -- print optimizer env sys-level parameters (10g+: gv$sys_optimizer_env; 9i:gv$parameter)
    optim_env_init_print_sys_pars;
    -- print system statistics
    optim_env_print_sys_stats;
  end if;
  
  &COMM_IF_NO_DBMS_METADATA. if :OPT_DBMS_METADATA = 'ALL' then
  &COMM_IF_NO_DBMS_METADATA.   dbms_metadata.set_transform_param( dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', true);
  &COMM_IF_NO_DBMS_METADATA. else
  &COMM_IF_NO_DBMS_METADATA.   dbms_metadata.set_transform_param( dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', false);
  &COMM_IF_NO_DBMS_METADATA. end if;
  
  for stmt in (select /*+ xplan_exec_marker */
                      t.*,
                      decode (executions, 0, to_number(null), executions) execs
                 from sys.gv_$sql t
                where inst_id = :OPT_INST_ID 
                  and (parse_calls > 0 or executions > 0)
&COMM_IF_NO_SQL_LIKE. and lower(sql_text) like lower(m_sql_like) escape '\'
                  and (m_action_like       is null or lower(action  ) like lower(m_action_like) escape '\')
                  and (m_module_like       is null or lower(module  ) like lower(m_module_like) escape '\')
-- following cmmenting-out is to optimize access by hash value (if specified => fixed index is used)
&COMM_IF_NO_HASH. and hash_value = m_hash_value
&COMM_IF_LT_10G.  and (m_sql_id          is null or sql_id          = m_sql_id)
                  and (m_parsing_user_id is null or parsing_user_id = m_parsing_user_id)
                  and (m_child_number    is null or child_number    = m_child_number)
                  and not lower (sql_text) like ('%dbms\_application\_info.%') escape '\'
                  and not lower (sql_text) like ('%xplan\_exec\_marker%') escape '\'
                order by &MAIN_ORDER_BY. sql_text, child_number)
  loop
    l_num_stmts_found := l_num_stmts_found + 1;
    
    if :OPT_SPOOL_FILES = 'single' then 
      print (rpad ('=', least(&LINE_SIZE.,50), '='));
      
      -- main statement attributes
      m_line := '';
      &COMM_IF_LT_10G. if stmt.sql_id is not null then m_line := m_line || 'sql_id=' || stmt.sql_id || ' '; end if;
      if stmt.hash_value is not null then m_line := m_line || 'hash=' || stmt.hash_value || ' '; end if;
      if stmt.child_number is not null then m_line := m_line || 'child_number=' || stmt.child_number || ' '; end if;
      if stmt.plan_hash_value is not null then m_line := m_line || 'plan_hash=' || stmt.plan_hash_value || ' '; end if;
      if stmt.module is not null then m_line := m_line || 'module=' || stmt.module || ' '; end if;
      if stmt.action is not null then m_line := m_line || 'action=' || stmt.action || ' '; end if;
      print (m_line);
      
      m_line := '';
      m_line := m_line || 'first_load: ' || to_char ( to_date (stmt.first_load_time, 'yyyy-mm-dd/hh24:mi:ss'),'yyyy/mm/dd hh24:mi:ss');
      m_line := m_line || ' last_load: ' || to_char ( to_date (stmt. last_load_time, 'yyyy-mm-dd/hh24:mi:ss'),'yyyy/mm/dd hh24:mi:ss');
      &COMM_IF_LT_10GR2. m_line := m_line || ' last_active: '|| to_char (stmt.last_active_time,'yyyy/mm/dd hh24:mi:ss');
      print (m_line);
      
      m_line := '';
      m_line := m_line || 'parsed_by='|| get_cache_username (stmt.parsing_user_id);
      m_line := m_line || ' inst_id='|| stmt.inst_id;
      &COMM_IF_LT_10G. if stmt.sql_profile is not null then m_line := m_line ||' sql_profile=' || stmt.sql_profile; end if;
      &COMM_IF_LT_10G. if stmt.program_id <> 0 then
      &COMM_IF_LT_10G.   m_line := m_line || ' program="' || get_cache_program_info (stmt.program_id) || '" line='||stmt.program_line#;
      &COMM_IF_LT_10G. end if;
      print (m_line);
          
      -- print main execution statistics (from gv$sql)
      mcf_reset (p_default_execs => stmt.executions, p_stat_default_decimals => 0, p_stex_default_decimals => 1);
      mcf_add_line_char ('gv$sql statname', 'total', '/exec');
      mcf_add_line ('executions'     , stmt.executions    , to_number(null));
      mcf_add_line ('rows_processed' , stmt.rows_processed);
      mcf_add_line ('buffer_gets'    , stmt.buffer_gets   );
      mcf_add_line ('disk_reads'     , stmt.disk_reads    );
      &COMM_IF_LT_10G. mcf_add_line ('direct_writes'  , stmt.direct_writes );
      mcf_add_line ('elapsed (usec)' , stmt.elapsed_time  );
      mcf_add_line ('cpu_time (usec)', stmt.cpu_time      );
      mcf_add_line ('sorts'          , stmt.sorts         );
      mcf_add_line ('fetches'        , stmt.fetches       );
      &COMM_IF_LT_10G. mcf_add_line ('end_of_fetch_c' , stmt.end_of_fetch_count);
      mcf_add_line ('parse_calls'    , stmt.parse_calls   );
      mcf_add_line ('sharable_mem'   , stmt.sharable_mem  , to_number(null));
      mcf_add_line ('persistent_mem' , stmt.persistent_mem, to_number(null));
      mcf_add_line ('runtime_mem'    , stmt.runtime_mem   , to_number(null));
      mcf_add_line ('users_executing', stmt.users_executing);
      
      &COMM_IF_LT_10G. mcf_add_line ('application wait (usec)', stmt.application_wait_time);
      &COMM_IF_LT_10G. mcf_add_line ('concurrency wait (usec)', stmt.concurrency_wait_time);
      &COMM_IF_LT_10G. mcf_add_line ('cluster     wait (usec)', stmt.cluster_wait_time    );
      &COMM_IF_LT_10G. mcf_add_line ('user io     wait (usec)', stmt.user_io_wait_time    );
      &COMM_IF_LT_10G. mcf_add_line ('plsql exec  wait (usec)', stmt.plsql_exec_time      );
      &COMM_IF_LT_10G. mcf_add_line ('java  exec  wait (usec)', stmt.java_exec_time       );
      
      mcf_prepare_output (p_num_columns => 3);
      loop
        m_line := mcf_next_output_line;
        exit when m_line is null;
        print (m_line);
      end loop;
      
      -- statement text
      m_stmt := null; l_stmt_length := 0;
      for x in (select /*+ xplan_exec_marker */ sql_text 
                  from sys.gv_$sqltext_with_newlines
                 where inst_id    = :OPT_INST_ID 
                   and address    = stmt.address
                   and hash_value = stmt.hash_value
                 order by piece)
      loop
        l_stmt_length := l_stmt_length + length ( x.sql_text );
        if l_stmt_length >= 32760-50 then
          m_stmt_truncated := true;
        else
          m_stmt := m_stmt || x.sql_text;
        end if;
      end loop;
      if m_stmt_truncated then 
        m_stmt := rtrim(m_stmt) || chr(13) || chr(10) || '** --TRUNCATED STATEMENT-- **' || chr(13) || chr(10); 
      end if;
      print_stmt_lines ( m_stmt );
      
      -- object dependency infos: print and remember
      if :OPT_OBJINFOS = 'Y' then
        print_obj_dep_and_store (p_inst_id    => :OPT_INST_ID, 
                                 p_address    => stmt.address,
                                 p_hash_value => stmt.hash_value);
      end if;
      
      -- bind sensitive, bind aware (11g Adaptive Cursor Sharing)
      &COMM_IF_LT_11G.m_line := '';
      &COMM_IF_LT_11G. if stmt.is_bind_sensitive = 'Y' then m_line := m_line || 'bind_sensitive '; end if;
      &COMM_IF_LT_11G. if stmt.is_bind_aware     = 'Y' then m_line := m_line || 'bind_aware '    ; end if;  
      &COMM_IF_LT_11G. if stmt.is_shareable      = 'N' then m_line := m_line || 'not_shareable ' ; end if;  
      &COMM_IF_LT_11G. print(m_line);
      &COMM_IF_LT_11G. if stmt.is_bind_aware     = 'Y' then
      &COMM_IF_LT_11G.   for x in (select rtrim(predicate,chr(0)) as predicate, rtrim(low,chr(0)) as low, rtrim(high,chr(0)) as high 
      &COMM_IF_LT_11G.               from sys.gv_$sql_cs_selectivity
      &COMM_IF_LT_11G.              where inst_id      = :OPT_INST_ID 
      &COMM_IF_LT_11G.                and address      = stmt.address
      &COMM_IF_LT_11G.                and hash_value   = stmt.hash_value 
      &COMM_IF_LT_11G.                and child_number = stmt.child_number
      &COMM_IF_LT_11G.              order by rtrim(predicate,chr(0)) )
      &COMM_IF_LT_11G.   loop
      &COMM_IF_LT_11G.     print(x.predicate||' '||x.low||' <-> '||x.high);
      &COMM_IF_LT_11G.   end loop;
      &COMM_IF_LT_11G. end if; 
     
      -- statement plan
      print_plan (p_inst_id        => :OPT_INST_ID, 
                  p_address        => stmt.address     , p_hash_value => stmt.hash_value, 
                  p_child_number   => stmt.child_number, p_executions => stmt.executions,
                  p_last_load_time => to_date (stmt.last_load_time, 'yyyy-mm-dd/hh24:mi:ss')
                  &COMM_IF_LT_10GR2., p_last_active_time  => stmt.last_active_time
                  &COMM_IF_LT_11G. , p_sql_plan_baseline => stmt.sql_plan_baseline
                 );
    else -- if :OPT_SPOOL_FILES = ... ("by_hash" and "by_sql_id" branches)
      &COMM_IF_LT_10G. if :OPT_SPOOL_FILES = 'by_hash' then
                         l_stmt_hash_or_id_as_string := lpad (trim(stmt.hash_value),10,'0');
                         l_stmt_hash_or_id_param     := 'hash';
      &COMM_IF_LT_10G. else
      &COMM_IF_LT_10G.   l_stmt_hash_or_id_as_string := stmt.sql_id; 
      &COMM_IF_LT_10G.   l_stmt_hash_or_id_param     := 'sql_id';
      &COMM_IF_LT_10G. end if;
      if stmt.hash_value > 0 and not m_referenced_sql_hashids.exists(l_stmt_hash_or_id_as_string) then
        m_referenced_sql_hashids (l_stmt_hash_or_id_as_string) := 'X';
        declare
          l_spool_name_last_dot number             := instr  (:OPT_SPOOL_NAME, '.', -1);
          l_spool_name_wo_ext   varchar2(100 char) := substr (:OPT_SPOOL_NAME, 1, l_spool_name_last_dot-1);
          l_spool_name_ext      varchar2(100 char) := substr (:OPT_SPOOL_NAME, l_spool_name_last_dot+1);
          l_curr_spool_name     varchar2(120 char);
        begin
          l_curr_spool_name := l_spool_name_wo_ext||'_'||l_stmt_hash_or_id_as_string
                            ||'_i'||:OPT_INST_ID||'.'||l_spool_name_ext;
          -- note: last option value overrides all the previous ones
          dbms_output.put_line ('@xplan "'||m_sql_like||'" "'||:XPLAN_OPTIONS||
            ','||l_stmt_hash_or_id_param||'='||l_stmt_hash_or_id_as_string||',spool_files=single,spool_name='||l_curr_spool_name||'"'); 
        end;
      end if;
    end if; -- if :OPT_SPOOL_FILES = 'single'
  end loop; -- gv$sql
  
  -- print tabinfos at the bottom, if requested
  if :OPT_SPOOL_FILES = 'single' then 
    if :OPT_TABINFOS = 'BOTTOM' then 
      print ('================== ALL TABINFOS ==================');
      if m_all_referenced_object_ids.count = 0  then
        print ('no tabinfos found.');
      else
        declare 
          l_curr_id varchar2(30);
        begin
          l_curr_id := m_all_referenced_object_ids.first;
          loop
            exit when l_curr_id is null;
            -- print tabinfos (no cache)
            print_table_infos (l_curr_id);
            l_curr_id := m_all_referenced_object_ids.next (l_curr_id);
          end loop;
        end;
      end if;
    end if;
  end if;
  
  -- print non-table object infos
  if :OPT_SPOOL_FILES = 'single' and :OPT_OBJINFOS = 'Y' then
    print_objinfos;
  end if;
 
  if l_num_stmts_found = 0 then
    if :OPT_SPOOL_FILES = 'single' then 
      print ('no statements found.'); 
    elsif :OPT_SPOOL_FILES in ('by_hash','by_sql_id') then
      print ('-- no statements found.');
    end if;
  end if;
  
  if :OPT_SPOOL_FILES = 'single' then 
    print ('OPTIONS: '||:CURRENT_XPLAN_OPTIONS);
    print ('SQL_LIKE="'||m_sql_like||'"');
  end if;   
  
  if :OPT_ASH_PROFILE_MINS > 0 then
    print ('-- Warning: since ash_profile_mins > 0, you are using ASH/AWR; make sure you are licensed to use it.');
  end if;
end;
/

set serveroutput off

spool off

@ &BOTTOM_SCRIPT.
