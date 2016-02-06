--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

procedure ash_print_stmt_profile (
  p_inst_id          sys.gv_$sql.inst_id%type,
  p_sql_id           varchar2, 
  p_child_number     sys.gv_$sql.child_number%type,
  p_last_load_time   date,
  p_last_active_time date
)
is
  &COMM_IF_LT_10G. l_sample_time_min timestamp(3);
  &COMM_IF_LT_10G. l_sample_time_max timestamp(3);
  &COMM_IF_LT_10G. l_prof scf_state_t;
begin
  if :OPT_ASH_PROFILE_MINS = 0 then
    return;
  end if;
  
  &COMM_IF_GT_9I.  print ('gv$active_session_history does not exist before 10g.');
  
  &COMM_IF_LT_10G.  l_sample_time_min := greatest (p_last_load_time, nvl(p_last_active_time,systimestamp) - (:OPT_ASH_PROFILE_MINS / 1440));
  &COMM_IF_LT_10G.  l_sample_time_max := nvl(p_last_active_time,systimestamp);
  
  -- display ASH profile
  &COMM_IF_LT_10G. for p in (select /*+ xplan_exec_marker */ 
  &COMM_IF_LT_10G.                  nvl(event, 'cpu') as event, count(*) as cnt, 100 * ratio_to_report(count(*)) over() as perc
  &COMM_IF_LT_10G.             from sys.gv_$active_session_history
  &COMM_IF_LT_10G.            where inst_id             = p_inst_id
  &COMM_IF_LT_10G.              and sql_id              = p_sql_id
  &COMM_IF_LT_10G.              and sql_child_number    = p_child_number
  &COMM_IF_LT_10G.              and sample_time between l_sample_time_min and l_sample_time_max
  &COMM_IF_LT_10G.            group by event
  &COMM_IF_LT_10G.            order by cnt desc)
  &COMM_IF_LT_10G. loop
  &COMM_IF_LT_10G.   scf_add_elem (l_prof, 'ash event', p.event);
  &COMM_IF_LT_10G.   scf_add_elem (l_prof, 'cnt'      , p.cnt);
  &COMM_IF_LT_10G.   scf_add_elem (l_prof, '%'        , p.perc);
  &COMM_IF_LT_10G. end loop;
 
  &COMM_IF_LT_10G. scf_print_output (l_prof, 'no profile info found in ASH.', 'no profile info found in ASH.');
end ash_print_stmt_profile;
  