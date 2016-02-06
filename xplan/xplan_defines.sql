--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009, 2010, 2012 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

variable ERROR_BEFORE_MAIN_BLOCK varchar2(50 char)

variable CURRENT_ERROR varchar2(50 char)
exec /* xplan_exec_marker */ :CURRENT_ERROR := ''; 

-- set version defines, get parameters
variable V_DB_MAJOR_VERSION  number
variable V_DB_MINOR_VERSION  number
variable V_DB_VERSION        varchar2(20 char)
variable V_DB_VERSION_COMPAT varchar2(20 char)
variable DB_NAME             varchar2(30 char)
variable INSTANCE_NAME       varchar2(30 char)
declare /* xplan_exec_marker */
  l_dummy_bi1  binary_integer;
  l_dummy_bi2  binary_integer;
  l_version_dot_1  binary_integer;
  l_version_dot_2  binary_integer;
begin
  sys.dbms_utility.db_version (:V_DB_VERSION, :V_DB_VERSION_COMPAT);
  l_version_dot_1 := instr (:V_DB_VERSION, '.');
  l_version_dot_2 := instr (:V_DB_VERSION, '.', 1, 2);
  :V_DB_MAJOR_VERSION := to_number (substr (:V_DB_VERSION, 1, l_version_dot_1 - 1));
  :V_DB_MINOR_VERSION := to_number (substr (:V_DB_VERSION,  l_version_dot_1+1, l_version_dot_2 - l_version_dot_1 - 1));
  l_dummy_bi1 := sys.dbms_utility.get_parameter_value ('db_name'      , l_dummy_bi2, :DB_NAME      );
  l_dummy_bi1 := sys.dbms_utility.get_parameter_value ('instance_name', l_dummy_bi2, :INSTANCE_NAME);
end;
/

-- set version-dependent commenting-out defines
define COMM_IF_LT_11G="error"
define COMM_IF_LT_10GR2="error"
define COMM_IF_LT_10G="error"
define COMM_IF_GT_9I="error"
col COMM_IF_LT_11G   noprint new_value COMM_IF_LT_11G
col COMM_IF_LT_10GR2 noprint new_value COMM_IF_LT_10GR2
col COMM_IF_LT_10G   noprint new_value COMM_IF_LT_10G
col COMM_IF_GT_9I    noprint new_value COMM_IF_GT_9I
col COMM_IF_GT_10G   noprint new_value COMM_IF_GT_10G
select /*+ xplan_exec_marker */
       case when :v_db_major_version < 11 then '--' else '' end COMM_IF_LT_11G,
       case when :v_db_major_version < 10 or (:v_db_major_version = 10 and :v_db_minor_version < 2) then '--' else '' end COMM_IF_LT_10GR2,  
       case when :v_db_major_version < 10 then '--' else '' end COMM_IF_LT_10G,
       case when :v_db_major_version >  9 then '--' else '' end COMM_IF_GT_9I,
       case when :v_db_major_version >= 11 or (:v_db_major_version = 10 and :v_db_minor_version >= 2) then '--' else '' end COMM_IF_GT_10G
  from dual;
  
-- set servroutput size clause to max possible (+infinite in10g+)
define SERVEROUT_SIZE_CLAUSE="error"
col SERVEROUT_SIZE_CLAUSE noprint new_value SERVEROUT_SIZE_CLAUSE
select /*+ xplan_exec_marker */ 
       case when :v_db_major_version < 10 then 'size 1000000' else 'size unlimited' end SERVEROUT_SIZE_CLAUSE 
  from dual;
  
-- set SQL_LIKE bind variable (10g handles single-quotes much better )
-- also, set :XPLAN_OPTIONS
variable XPLAN_OPTIONS  varchar2(200 char)
exec /* xplan_exec_marker */ if :CURRENT_ERROR is null then :CURRENT_ERROR := 'sql_like invalid'; end if;
variable SQL_LIKE varchar2(4000)
begin /*+ xplan_exec_marker */ 
   :SQL_LIKE := 
   &COMM_IF_GT_9I.  '&SQL_LIKE.'   ;
   &COMM_IF_LT_10G. q'|&SQL_LIKE.|';
   :CURRENT_ERROR := '';
   :XPLAN_OPTIONS := '&XPLAN_OPTIONS.';
end;
/

-- set options defines
variable OPT_INST_ID           number
variable OPT_PLAN_STATS        varchar2(10  char)
variable OPT_ACCESS_PREDICATES varchar2(1)
variable OPT_LINES             number
variable OPT_ASH_PROFILE_MINS  number
variable OPT_MODULE            varchar2(100 char)
variable OPT_ACTION            varchar2(100 char)
variable OPT_HASH_VALUE        varchar2(30  char)
variable OPT_SQL_ID            varchar2(30  char)
variable OPT_PARSED_BY         varchar2(30  char)
variable OPT_CHILD_NUMBER      number
variable OPT_DBMS_XPLAN        varchar2(1)
variable OPT_DBMS_METADATA     varchar2(3)
variable OPT_PLAN_DETAILS      varchar2(1)
variable OPT_PLAN_ENV          varchar2(1)
variable OPT_TABINFOS          varchar2(6   char)
variable OPT_OBJINFOS          varchar2(1)
variable OPT_PARTINFOS         varchar2(1)
variable OPT_SELF              varchar2(1)
variable OPT_ORDER_BY          varchar2(100 char)
variable OPT_SPOOL_NAME        varchar2(100 char)
variable OPT_SPOOL_FILES       varchar2(30  char)
variable OPT_NUMBER_COMMAS     varchar2(1)

exec /* xplan_exec_marker */ if :CURRENT_ERROR is null then :CURRENT_ERROR := 'processing XPLAN_OPTIONS'; end if; 

declare /* xplan_exec_marker */ -- process options
  l_opt_string varchar2(200 char) := :XPLAN_OPTIONS||',';
  l_curr_opt_str varchar2(200 char);
  l_first_colon int; l_first_eq int;
  l_name varchar2(30 char); 
  l_value varchar2(200 char);
begin  
  if :CURRENT_ERROR != 'processing XPLAN_OPTIONS' then
    raise_application_error (-20001, 'skipping due to previous error');
  end if;
  
  -- set defaults
  :OPT_INST_ID             := userenv('Instance');
  :OPT_PLAN_STATS          := 'last';
  :OPT_ACCESS_PREDICATES   := 'Y';
  :OPT_LINES               := 200;
  :OPT_ASH_PROFILE_MINS    := null;
  :OPT_MODULE              := null;
  :OPT_ACTION              := null;
  :OPT_HASH_VALUE          := null;
  :OPT_SQL_ID              := null;
  :OPT_PARSED_BY           := null;
  :OPT_CHILD_NUMBER        := null;
  :OPT_DBMS_XPLAN          := 'N';
  :OPT_DBMS_METADATA       := 'N';
  :OPT_PLAN_DETAILS        := 'N';
  :OPT_PLAN_ENV            := 'Y';
  :OPT_TABINFOS            := 'Y';
  :OPT_OBJINFOS            := 'Y';
  :OPT_PARTINFOS           := 'Y';
  :OPT_SELF                := 'Y';
  :OPT_ORDER_BY            := '';
  :OPT_SPOOL_NAME          := null;
  :OPT_SPOOL_FILES         := null;
  :OPT_NUMBER_COMMAS       := 'Y'; 
  
  -- override defaults from XPLAN_OPTIONS
  loop
    l_first_colon := instr (l_opt_string, ',');
    exit when l_first_colon = 0 or l_first_colon is null;
    l_curr_opt_str := substr (l_opt_string, 1, l_first_colon-1);
    l_opt_string := substr (l_opt_string, l_first_colon+1);
    if trim(l_curr_opt_str) is not null then
      l_first_eq := instr (l_curr_opt_str, '=');
      if l_first_eq <= 1 or l_first_eq is null then
        raise_application_error (-20001, 'invalid option ="'||l_curr_opt_str||'".');
      end if;
      l_name  := trim(lower(substr (l_curr_opt_str, 1, l_first_eq-1)));
      l_value := trim(lower(substr (l_curr_opt_str, l_first_eq+1)));
      if l_name is null then
        raise_application_error (-20002, 'invalid option ="'||l_curr_opt_str||'".');
      end if;
      if l_name in ('inst_id') then
        :OPT_INST_ID := to_number (l_value);
      elsif l_name = 'plan_stats' then
        if l_value in ('raw','per_exec','last') then
          :OPT_PLAN_STATS := l_value;
        else
          raise_application_error (-20003, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if;
      elsif l_name = 'access_predicates' then
        if l_value in ('y','n') then
          :OPT_ACCESS_PREDICATES := upper (l_value);
        else
          raise_application_error (-20004, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if;
      elsif l_name in ('lines','linesize') then
        :OPT_LINES := to_number (l_value);
      elsif l_name = 'module' then
        :OPT_MODULE := l_value;
      elsif l_name = 'action' then
        :OPT_ACTION := l_value;
      elsif l_name in ('hash', 'hash_value') then
        :OPT_HASH_VALUE := to_number (l_value);
      elsif l_name = 'sql_id' then
        :OPT_SQL_ID := trim(l_value);  
        &COMM_IF_GT_9I. if :OPT_SQL_ID is not null then raise_application_error (-20005, 'cannot use sql_id before 10g'); end if;
      elsif l_name = 'parsed_by' then  
        :OPT_PARSED_BY := upper(l_value);
      elsif l_name = 'child_number' then
        :OPT_CHILD_NUMBER := to_number (l_value);
      elsif l_name = 'dbms_xplan' then
        if l_value in ('y','n') then
          :OPT_DBMS_XPLAN := upper (l_value);
          &COMM_IF_GT_9I. if :OPT_DBMS_XPLAN = 'Y' then raise_application_error (-20006, 'cannot use dbms_xplan before 10g'); end if;
        else
          raise_application_error (-20007, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if;
      elsif l_name = 'dbms_metadata' then
        if l_value in ('y','n','all') then
          :OPT_DBMS_METADATA := upper (l_value);
        else
          raise_application_error (-20008, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if;
      elsif l_name = 'plan_details' then
        if l_value in ('y','n') then
          :OPT_PLAN_DETAILS := upper (l_value);
          &COMM_IF_GT_9I. if :OPT_PLAN_DETAILS = 'Y' then raise_application_error (-20008, 'cannot display plan_details before 10g'); end if;
        else
          raise_application_error (-20009, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if;  
      elsif l_name = 'plan_env' then
        if l_value in ('y','n') then
          :OPT_PLAN_ENV := upper (l_value);
        else
          raise_application_error (-20010, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if;  
      elsif l_name in ('ash_profile_mins','ash_profile_min') then
        :OPT_ASH_PROFILE_MINS := to_number (l_value);
        if :OPT_ASH_PROFILE_MINS >= 0 and :OPT_ASH_PROFILE_MINS = trunc (:OPT_ASH_PROFILE_MINS) then 
          null;
        else
          raise_application_error (-20011, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if;
        &COMM_IF_GT_9I. if :OPT_ASH_PROFILE_MINS != 0 then raise_application_error (-20012, 'cannot use ASH before 10g'); end if;
      elsif l_name in ('tabinfos', 'ti') then
        if l_value in ('y','n','bottom') then
          :OPT_TABINFOS := upper (l_value);
        else
          raise_application_error (-20013, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if;   
      elsif l_name in ('objinfos', 'oi') then
        if l_value in ('y','n') then
          :OPT_OBJINFOS := upper (l_value);
        else
          raise_application_error (-20014, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if; 
      elsif l_name in ('partinfos', 'pi') then
        if l_value in ('y','n') then
          :OPT_PARTINFOS := upper (l_value);
        else
          raise_application_error (-20015, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if; 
      elsif l_name = 'order_by' then
         :OPT_ORDER_BY := replace (trim(l_value), ';', ',') || ',';
      elsif l_name = 'spool_name' then
         :OPT_SPOOL_NAME := l_value;
         if instr (:OPT_SPOOL_NAME, '.') = 0 then
           :OPT_SPOOL_NAME := :OPT_SPOOL_NAME || '.lst';
         end if;
      elsif l_name = 'spool_files' then
        if l_value in ('single', 'by_hash', 'by_sql_id') then
          :OPT_SPOOL_FILES := l_value;
        else
          raise_application_error (-20016, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if;
        &COMM_IF_GT_9I. if :OPT_SPOOL_FILES = 'by_sql_id' then raise_application_error (-20017, 'cannot name files using sql_id before 10g'); end if;
      elsif l_name = 'self' then
        if l_value in ('y','n') then
          :OPT_SELF := upper (l_value);
        else
          raise_application_error (-20017, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if; 
      elsif l_name = 'numbers_with_comma' then
        if l_value in ('y','n') then
          :OPT_NUMBER_COMMAS := upper (l_value);
        else
          raise_application_error (-20018, 'invalid value "'||l_value||'" for option '||l_name||'.');
        end if;  
      else 
        raise_application_error (-20099, 'invalid option name for "'||l_curr_opt_str||'".');
      end if;
    end if;
  end loop;  
  
  -- handle ash_profile_mins not set
  &COMM_IF_LT_10G. if :OPT_ASH_PROFILE_MINS is null then
  &COMM_IF_LT_10G.   :OPT_ASH_PROFILE_MINS := 15;
  &COMM_IF_LT_10G. end if;
  
  -- handle spool_files not set
  if :OPT_SPOOL_FILES is null then
    if :OPT_SQL_ID is not null then
      :OPT_SPOOL_FILES := 'by_sql_id';
    elsif :OPT_HASH_VALUE is not null then
      :OPT_SPOOL_FILES := 'by_hash';
    else
      :OPT_SPOOL_FILES := 'single';
    end if;
  end if;
  
  -- handle spool_name not set
  if :OPT_SPOOL_NAME is null then
    if :OPT_SPOOL_FILES = 'single' then
      :OPT_SPOOL_NAME := 'xplan'||'_i'||:OPT_INST_ID||'.lst';
    else
      :OPT_SPOOL_NAME := 'xplan.lst';
    end if;
  end if;
  
  :CURRENT_ERROR := null;
end;
/

-- print current options values
variable CURRENT_XPLAN_OPTIONS varchar2(500 char)
begin
select /*+ xplan_exec_marker */ 
       'inst_id=' || :OPT_INST_ID
    || ' plan_stats='||:OPT_PLAN_STATS
    || ' access_predicates='||:OPT_ACCESS_PREDICATES
    || ' lines='||:OPT_LINES
    || ' ash_profile_mins='||:OPT_ASH_PROFILE_MINS
    || ' module='||:OPT_MODULE
    || ' action='||:OPT_ACTION
    || ' hash='||:OPT_HASH_VALUE
    || ' sql_id='||:OPT_SQL_ID
    || ' parsed_by='||:OPT_PARSED_BY
    || ' child_number='||:OPT_CHILD_NUMBER
    || ' dbms_xplan='||:OPT_DBMS_XPLAN
    || ' dbms_metadata='||:OPT_DBMS_METADATA
    || ' plan_details='||:OPT_PLAN_DETAILS
    || ' plan_env='||:OPT_PLAN_ENV
    || ' tabinfos='||:OPT_TABINFOS
    || ' objinfos='||:OPT_OBJINFOS
    || ' partinfos='||:OPT_PARTINFOS
    || ' self='||:OPT_SELF
    || ' order_by='||:OPT_ORDER_BY
    || ' numbers_with_comma='||:OPT_NUMBER_COMMAS
    || ' spool_name='||:OPT_SPOOL_NAME
    || ' spool_files='||:OPT_SPOOL_FILES
  into :CURRENT_XPLAN_OPTIONS
  from dual;
end;
/
  
-- set internal defines
define PLAN_LAST_OR_NULL="error"
col PLAN_LAST_OR_NULL noprint new_value PLAN_LAST_OR_NULL
select /*+ xplan_exec_marker */ case when :OPT_PLAN_STATS = 'last' then 'LAST_' else null end as PLAN_LAST_OR_NULL from dual;
 
define PLAN_AVG_PER_EXEC="error"
col PLAN_AVG_PER_EXEC noprint new_value PLAN_AVG_PER_EXEC
select /*+ xplan_exec_marker */ case when :OPT_PLAN_STATS = 'per_exec' then 'Y' else 'N' end as PLAN_AVG_PER_EXEC from dual;

define COMM_IF_NO_PREDS="error"
col COMM_IF_NO_PREDS noprint new_value COMM_IF_NO_PREDS
select /*+ xplan_exec_marker */ case when :OPT_ACCESS_PREDICATES = 'Y' then '' else '--' end as COMM_IF_NO_PREDS from dual; 

define COMM_IF_NO_DBMS_XPLAN="error"
col COMM_IF_NO_DBMS_XPLAN noprint new_value COMM_IF_NO_DBMS_XPLAN
select /*+ xplan_exec_marker */ case when :OPT_DBMS_XPLAN = 'Y' then '' else '--' end as COMM_IF_NO_DBMS_XPLAN from dual; 

define COMM_IF_NO_DBMS_METADATA="error"
col COMM_IF_NO_DBMS_METADATA noprint new_value COMM_IF_NO_DBMS_METADATA
select /*+ METADATA_exec_marker */ case when :OPT_DBMS_METADATA != 'N' then '' else '--' end as COMM_IF_NO_DBMS_METADATA from dual;

define COMM_IF_NO_HASH="error"
col COMM_IF_NO_HASH noprint new_value COMM_IF_NO_HASH
select /*+ xplan_exec_marker */ case when :OPT_HASH_VALUE is not null then '' else '--' end as COMM_IF_NO_HASH from dual; 
  
define COMM_IF_NO_SELF="error"
col COMM_IF_NO_SELF noprint new_value COMM_IF_NO_SELF
select /*+ xplan_exec_marker */ case when :OPT_SELF = 'Y' then '' else '--' end as COMM_IF_NO_SELF from dual; 

define COMM_IF_NO_SQL_LIKE="error"
col COMM_IF_NO_SQL_LIKE noprint new_value COMM_IF_NO_SQL_LIKE
select /*+ xplan_exec_marker */ 
       case when :SQL_LIKE is null or :SQL_LIKE = '%' then '--' else '' end as COMM_IF_NO_SQL_LIKE
  from dual;
    
define MAIN_BLOCK_SPOOL="error"
define BOTTOM_SCRIPT="error"
col MAIN_BLOCK_SPOOL noprint new_value MAIN_BLOCK_SPOOL
col BOTTOM_SCRIPT noprint new_value BOTTOM_SCRIPT
select /*+ xplan_exec_marker */
       case when :OPT_SPOOL_FILES = 'single' then :OPT_SPOOL_NAME         else 'xplan_run.lst' end MAIN_BLOCK_SPOOL,
       case when :OPT_SPOOL_FILES = 'single' then 'xplan_null_script.sql' else 'xplan_run.lst' end BOTTOM_SCRIPT
  from dual;

define LINE_SIZE="error"
col LINE_SIZE noprint new_value LINE_SIZE
select /*+ xplan_exec_marker */ 
       case when :OPT_SPOOL_FILES = 'single' then to_char(:OPT_LINES) else to_char(500) end as LINE_SIZE 
  from dual;

define MAIN_ORDER_BY="error"
col MAIN_ORDER_BY noprint new_value MAIN_ORDER_BY
select /*+ xplan_exec_marker */ :OPT_ORDER_BY as MAIN_ORDER_BY from dual; 

define SPOOL_NAME="error"
col SPOOL_NAME noprint new_value SPOOL_NAME
select /*+ xplan_exec_marker */ to_char(:OPT_SPOOL_NAME) as SPOOL_NAME from dual;

define SPOOL_FILES="error"
col SPOOL_FILES noprint new_value SPOOL_FILES
select /*+ xplan_exec_marker */ to_char(:OPT_SPOOL_FILES) as SPOOL_FILES from dual;

variable MODULE_LIKE varchar2(100 char)
variable ACTION_LIKE varchar2(100 char)
exec /*+ xplan_exec_marker */ :MODULE_LIKE := :OPT_MODULE; :ACTION_LIKE := :OPT_ACTION; 

define ERROR_BEFORE_MAIN_BLOCK=""
col ERROR_BEFORE_MAIN_BLOCK noprint new_value ERROR_BEFORE_MAIN_BLOCK
select /*+ xplan_exec_marker */ case when :CURRENT_ERROR is null then null
                                     else ' *** error before main block ( '||:CURRENT_ERROR||' ) ***' 
                                end as ERROR_BEFORE_MAIN_BLOCK 
  from dual; 
