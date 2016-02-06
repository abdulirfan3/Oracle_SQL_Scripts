/**********************************************************************
 * File:        sqlhistory.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        29sep08
 *
 * Description:
 *	SQL*Plus script to query the "history" of a specified SQL
 *	statement, using its "SQL ID" across all database instances
 *	in a database, using the AWR repository.  This report is useful
 *	for obtaining an hourly perspective on SQL statements seen in
 *	more aggregated reports.
 *
 * Modifications:
 *	TGorman	29sep08	adapted from the earlier STATSPACK-based
 *			"sphistory.sql" script
 *********************************************************************/
set echo off
set feedback off timing off verify off pagesize 100 linesize 200 recsep off echo off
set serveroutput on size 1000000 format wrapped trimout on trimspool on
col phv heading "Plan|Hash Value"
col snap_time format a12 truncate heading "Snapshot|Time"
col execs format 999,990 heading "Execs"
col lio_per_exec format 999,999,999,990.00 heading "Avg LIO|Per Exec"
col pio_per_exec format 999,999,999,990.00 heading "Avg PIO|Per Exec"
col cpu_per_exec format 999,999,999,990.00 heading "Avg|CPU (secs)|Per Exec"
col ela_per_exec format 999,999,999,990.00 heading "Avg|Elapsed (secs)|Per Exec"
col sql_text format a64 heading "Text of SQL statement"
clear breaks computes
ttitle off
btitle off

accept V_SQL_ID prompt "Enter the SQL_ID: "
accept V_NBR_DAYS prompt "Enter number of days (backwards from this hour) to report (default: ALL): "

variable v_nbr_days number

--spool sqlhistory_&&V_SQL_ID

declare
	cursor get_phv(in_sql_id in varchar2, in_days in integer)
	is
	select	ss.plan_hash_value,
		min(s.begin_interval_time) min_time,
		max(s.begin_interval_time) max_time,
		min(s.snap_id) min_snap,
		max(s.snap_id) max_snap,
		sum(ss.executions_delta) sum_execs,
		sum(ss.disk_reads_delta) sum_disk_reads,
		sum(ss.buffer_gets_delta) sum_buffer_gets,
		sum(ss.cpu_time_delta)/1000000 sum_cpu_time,
		sum(ss.elapsed_time_delta)/1000000 sum_elapsed_time
	from	dba_hist_sqlstat	ss,
		dba_hist_snapshot	s
	where	ss.dbid = s.dbid
	and	ss.instance_number = s.instance_number
	and	ss.snap_id = s.snap_id
	and	ss.sql_id = in_sql_id
	/* and	ss.executions_delta > 0 */
	and	s.begin_interval_time >= sysdate-in_days
	group by ss.plan_hash_value
	order by sum_elapsed_time desc;
        --
	cursor get_xplan(in_sql_id in varchar2, in_phv in number)
	is
	select	plan_table_output
	from	table(dbms_xplan.display_awr(in_sql_id, in_phv, null, 'ALL -ALIAS'));
	--
	v_prev_plan_hash_value	number := -1;
	v_text_lines		number := 0;
	v_errcontext		varchar2(100);
	v_errmsg		varchar2(100);
	v_display_sql_text	boolean;
	--
begin
	--
	v_errcontext := 'query NBR_DAYS from DUAL';
	select	decode('&&V_NBR_DAYS','',10,to_number(nvl('&&V_NBR_DAYS','10')))
	into	:v_nbr_days
	from	dual;
	--
	v_errcontext := 'open/fetch get_phv';
	for phv in get_phv('&&V_SQL_ID', :v_nbr_days) loop
		--
		if get_phv%rowcount = 1 then
			--
			dbms_output.put_line('+'||
				rpad('-',12,'-')||
				rpad('-',10,'-')||
				rpad('-',10,'-')||
				rpad('-',12,'-')||
				rpad('-',15,'-')||
				rpad('-',15,'-')||
				rpad('-',12,'-')||
				rpad('-',12,'-')||'+');
			dbms_output.put_line('|'||
				rpad('Plan HV',12,' ')||
				rpad('Min Snap',10,' ')||
				rpad('Max Snap',10,' ')||
				rpad('Execs',12,' ')||
				rpad('LIO',15,' ')||
				rpad('PIO',15,' ')||
				rpad('CPU',12,' ')||
				rpad('Elapsed',12,' ')||'|');
			dbms_output.put_line('+'||
				rpad('-',12,'-')||
				rpad('-',10,'-')||
				rpad('-',10,'-')||
				rpad('-',12,'-')||
				rpad('-',15,'-')||
				rpad('-',15,'-')||
				rpad('-',12,'-')||
				rpad('-',12,'-')||'+');
			--
		end if;
		--
		dbms_output.put_line('|'||
			rpad(trim(to_char(phv.plan_hash_value)),12,' ')||
			rpad(trim(to_char(phv.min_snap)),10,' ')||
			rpad(trim(to_char(phv.max_snap)),10,' ')||
			rpad(trim(to_char(phv.sum_execs,'999,999,990')),12,' ')||
			rpad(trim(to_char(phv.sum_buffer_gets,'999,999,999,990')),15,' ')||
			rpad(trim(to_char(phv.sum_disk_reads,'999,999,999,990')),15,' ')||
			rpad(trim(to_char(phv.sum_cpu_time,'999,990.00')),12,' ')||
			rpad(trim(to_char(phv.sum_elapsed_time,'999,990.00')),12,' ')||'|');
		--
		v_errcontext := 'fetch/close get_phv';
		--
	end loop;
	dbms_output.put_line('+'||
		rpad('-',12,'-')||
		rpad('-',10,'-')||
		rpad('-',10,'-')||
		rpad('-',12,'-')||
		rpad('-',15,'-')||
		rpad('-',15,'-')||
		rpad('-',12,'-')||
		rpad('-',12,'-')||'+');
	--
	v_errcontext := 'open/fetch get_phv';
	for phv in get_phv('&&V_SQL_ID', :v_nbr_days) loop
		--
		if v_prev_plan_hash_value <> phv.plan_hash_value then
			--
			v_prev_plan_hash_value := phv.plan_hash_value;
			v_display_sql_text := FALSE;
			--
			v_text_lines := 0;
			v_errcontext := 'open/fetch get_xplan';
			for s in get_xplan('&&V_SQL_ID', phv.plan_hash_value) loop
				--
				if v_text_lines = 0 then
					dbms_output.put_line('.');
					dbms_output.put_line('========== PHV = ' ||
						phv.plan_hash_value ||
						'==========');
					dbms_output.put_line('First seen from "'||
						to_char(phv.min_time,'MM/DD/YY HH24:MI:SS') ||
						'" (snap #'||phv.min_snap||')');
					dbms_output.put_line('Last seen from  "'||
						to_char(phv.max_time,'MM/DD/YY HH24:MI:SS') ||
						'" (snap #'||phv.max_snap||')');
					dbms_output.put_line('.');
					dbms_output.put_line(
						rpad('Execs',15,' ')||
						rpad('LIO',15,' ')||
						rpad('PIO',15,' ')||
						rpad('CPU',15,' ')||
						rpad('Elapsed',15,' '));
					dbms_output.put_line(
						rpad('=====',15,' ')||
						rpad('===',15,' ')||
						rpad('===',15,' ')||
						rpad('===',15,' ')||
						rpad('=======',15,' '));
					dbms_output.put_line(
						rpad(trim(to_char(phv.sum_execs,'999,999,999,990')),15,' ')||
						rpad(trim(to_char(phv.sum_buffer_gets,'999,999,999,990')),15,' ')||
						rpad(trim(to_char(phv.sum_disk_reads,'999,999,999,990')),15,' ')||
						rpad(trim(to_char(phv.sum_cpu_time,'999,999,990.00')),15,' ')||
						rpad(trim(to_char(phv.sum_elapsed_time,'999,999,990.00')),15,' '));
					dbms_output.put_line('.');
				end if;
				--
				if v_display_sql_text = FALSE and
				   s.plan_table_output like 'Plan hash value: %' then
					--
					v_display_sql_text := TRUE;
					--
				end if;
				--
				if v_display_sql_text = TRUE then
					--
					dbms_output.put_line(s.plan_table_output);
					--
				end if;
				--
				v_text_lines := v_text_lines + 1;
				--
			end loop;
			--
		end if;
		--
		v_errcontext := 'fetch/close get_phv';
		--
	end loop;
	--
exception
	when others then
		v_errmsg := sqlerrm;
		raise_application_error(-20000, v_errcontext || ': ' || v_errmsg);
end;
/

break on report
compute sum of execs on report
compute avg of lio_per_exec on report
compute avg of pio_per_exec on report
compute avg of cpu_per_exec on report
compute avg of ela_per_exec on report
ttitle center 'Summary Execution Statistics Over Time'
select	to_char(s.begin_interval_time, 'DD-MON HH24:MI') snap_time,
	ss.executions_delta execs,
	ss.buffer_gets_delta/decode(ss.executions_delta,0,1,ss.executions_delta) lio_per_exec,
	ss.disk_reads_delta/decode(ss.executions_delta,0,1,ss.executions_delta) pio_per_exec,
	(ss.cpu_time_delta/1000000)/decode(ss.executions_delta,0,1,ss.executions_delta) cpu_per_exec,
	(ss.elapsed_time_delta/1000000)/decode(ss.executions_delta,0,1,ss.executions_delta) ela_per_exec
from 	dba_hist_snapshot	s,
	dba_hist_sqlstat	ss
where	ss.dbid = s.dbid
and	ss.instance_number = s.instance_number
and	ss.snap_id = s.snap_id
and	ss.sql_id = '&&V_SQL_ID'
/* and	ss.executions_delta > 0 */
and	s.begin_interval_time >= sysdate - :v_nbr_days
order by s.snap_id;
clear breaks computes

break on phv skip 1 on report
compute sum of execs on phv
compute avg of lio_per_exec on phv
compute avg of pio_per_exec on phv
compute avg of cpu_per_exec on phv
compute avg of ela_per_exec on phv
ttitle center 'Per-Plan Execution Statistics Over Time'
select	ss.plan_hash_value phv,
	to_char(s.begin_interval_time, 'DD-MON HH24:MI') snap_time,
	ss.executions_delta execs,
	ss.buffer_gets_delta/decode(ss.executions_delta,0,1,ss.executions_delta) lio_per_exec,
	ss.disk_reads_delta/decode(ss.executions_delta,0,1,ss.executions_delta) pio_per_exec,
	(ss.cpu_time_delta/1000000)/decode(ss.executions_delta,0,1,ss.executions_delta) cpu_per_exec,
	(ss.elapsed_time_delta/1000000)/decode(ss.executions_delta,0,1,ss.executions_delta) ela_per_exec
from 	dba_hist_snapshot	s,
	dba_hist_sqlstat	ss
where	ss.dbid = s.dbid
and	ss.instance_number = s.instance_number
and	ss.snap_id = s.snap_id
and	ss.sql_id = '&&V_SQL_ID'
/* and	ss.executions_delta > 0 */
and	s.begin_interval_time >= sysdate - :v_nbr_days
order by ss.plan_hash_value, s.snap_id;
clear breaks computes

--spool off
set verify on echo on feedback on
ttitle off
