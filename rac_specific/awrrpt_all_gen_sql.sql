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
spool awrrpt_all.sql
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
	p('declare');
	p('begin');
		p('select');
   		p('   (select distinct first_value (snap_id) over(' );
                p('          order by snap_id desc rows between unbounded preceding and unbounded following) prior_snap_id ');
        	p('from  dba_hist_snapshot ');
        	p('where snap_id < max_snap_id ');
      		p(') bid, ');
   		p('max_snap_id eid ');
  	p('into :bid, :eid ');
	p('from ');
	p('(  ');
  	p('	select distinct first_value (snap_id) over( ');
	p('		order by snap_id desc rows between unbounded preceding and unbounded following) max_snap_id ');
  	p('	from  dba_hist_snapshot );');
	p('select dbid into :dbid from dba_hist_database_instance where rownum=1;');
p('end;');
p('/');

p('exec :rpt_options :=0;');
p('column rpt_name new_value rpt_name noprint;');

for c1 in  (select instance_number from gv$instance order by instance_number) 
loop   
   p('exec :inst_num :='||c1.instance_number ||';');
   v_str := q'[select 'awrrpt_'||:inst_num||'_'||:bid||'_'||:eid||'.txt' rpt_name from dual;]';
   p(v_str);
   p('set lines 80');
   p('spool &rpt_name');
   p(' select output from table(sys.dbms_workload_repository.awr_report_text( :dbid,');
   p('                                                         :inst_num,');
   p('                                                         :bid, :eid,');
   p('                                                         :rpt_options ));');
   p('spool off');
   p('set termout on');
   p('PROMPT    ...AWR report created for instance '||c1.instance_number||'. Please wait..');
   p('set feedback off');
   v_str := q'[select '....File_name: awrrpt_'||:inst_num||'_'||:bid||'_'||:eid||'.txt' file_name from dual;]';
   p(v_str);
   p('set termout off');
   p('set feedback on');
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
set termout off
@awrrpt_all.sql
set termout on
set pagesize 24
PROMPT    AWR reports created.