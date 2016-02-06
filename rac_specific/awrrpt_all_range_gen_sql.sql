REM --------------------------------------------------------------------------------------------------
REM Author: Riyaj Shamsudeen @OraInternals, LLC
REM         www.orainternals.com
REM
REM Functionality: This script is to get all AWR report from all nodes.
REM **************
REM
REM Source  : AWR tables
REM
REM Exectution type: Execute from sqlplus or any other tool.
REM
REM Parameters: No parameters. Uses Last snapshot and the one prior snap
REM No implied or explicit warranty
REM @Copyright : OraInternals, LLC
REM
REM Please send me an email to rshamsud@orainternals.com, if you found issues in this script :-)
REM --------------------------------------------------------------------------------------------------
prompt
PROMPT
PROMPT
PROMPT  awrrpt_all_gen.sql v1.03 by Riyaj Shamsudeen @orainternals.com
PROMPT
PROMPT   To generate AWR Report from all RAC instances concurrently. 
PROMPT    
PROMPT    Creates reports using last two snap_ids.
PROMPT      
PROMPT    ...Generating awrrpt_all.sql script.... Please wait....
set define off
set feedback off
set termout off
set pages 0
set lines 120
set serveroutput on 
spool awrrpt_all_range.sql
declare
   v_str varchar2(180);
   procedure p (l_str  varchar2)
   is
   begin
     dbms_output.put_line(l_str);
   end;
begin
	p('REM --------------------------------------------------------------------------------------------------');
	p('REM Author: Riyaj Shamsudeen @OraInternals, LLC');
	p('REM         www.orainternals.com');
	p('REM');
	p('REM Functionality: This script is to get all AWR report from all nodes.');
	p('REM **************');
	p('REM');
	p('REM Source  : AWR tables');
	p('REM');
	p('REM Exectution type: Execute from sqlplus or any other tool.');
	p('REM');
	p('REM Parameters: No parameters. Uses Last snapshot and the one prior snap');
	p('REM No implied or explicit warranty');
	p('REM @Copyright OraInternals, LLC');
	p('REM Please send me an email to rshamsud@orainternals.com, if you found issues in this script. ');
	p('REM --------------------------------------------------------------------------------------------------');
	p('set pages 0');
	p('variable dbid number');
	p('variable inst_num number');
	p('variable bid number');
	p('variable eid number');
	p('variable rpt_options number');
	p('');
        p('undef bid ');
	p('undef eid');
	p('declare');
	p('begin ');
	p('  select dbid into :dbid from dba_hist_database_instance where rownum=1;');
	p('end;');
	p('/');

	p('break on inst_name on  db_name');

	p('select ');
        p('	di.instance_name                                  inst_name');
     	p('	, di.db_name                                        db_name');
     	p('	, s.snap_id                                         snap_id');
     	p(q'[	, to_char(s.end_interval_time,'dd Mon YYYY HH24:mi') snapdat]');
     	p('	, s.snap_level                                      lvl');
  	p('	from dba_hist_snapshot s');
     	p('	, dba_hist_database_instance di');
 	p('	where s.dbid              =  (select dbid from v$database) ');
   	p('	and di.dbid             =   (select dbid from v$database)');
   	p('	and s.instance_number   = (select instance_number from v$instance) ');
   	p('	and di.instance_number  =  (select instance_number from v$instance)');
   	p('	and di.dbid             = s.dbid ');
   	p('	and di.instance_number  = s.instance_number');
   	p('	and di.startup_time     = s.startup_time');
   	p('	and s.end_interval_time >= sysdate-&days_to_show ');
 	p(' order by db_name, instance_name, snap_id');
	p('; ');

	p('exec :bid := to_number (&bid);');
	p('exec :eid := to_number (&eid);');

p('exec :rpt_options :=0;');
p('column rpt_name new_value rpt_name noprint;');

for c1 in  (select instance_number from gv$instance order by instance_number) 
loop   
   p('set termout off');
   p('exec :inst_num :='||c1.instance_number ||';');
   p('set lines 80');
   v_str := q'[select 'awrrpt_'||:inst_num||'_'||:bid||'_'||:eid||'.txt' rpt_name from dual;]';
   p(v_str);
   p('spool &rpt_name');
   p(' select output from table(dbms_workload_repository.awr_report_text( :dbid,');
   p('                                                         :inst_num,');
   p('                                                         :bid, :eid,');
   p('                                                         :rpt_options ));');
   p('spool off');
   p('set termout on');
   p('PROMPT    ...AWR report created for instance '||c1.instance_number||'. Please wait..');
   p('set feedback off');
   v_str := q'[select '....File_name: awrrpt_'||:inst_num||'_'||:bid||'_'||:eid||'.txt' file_name from dual;]';
   p(v_str);
   p('set feedback on');
   p('set termout off');
end loop;
end;
/
spool off
set define on
set feedback on
set termout on
PROMPT    ...Completed script generation. 
PROMPT   
PROMPT    Executing awrrpt_all.sql to generate AWR reports. 
PROMPT    ...Generates AWR reports with file name format awrrpt_<inst>_<bid>_<eid>.txt for each instance. 
PROMPT    ...Please wait for few minutes...
PROMPT
set termout on
@awrrpt_all_range.sql
set termout on
set pagesize 24