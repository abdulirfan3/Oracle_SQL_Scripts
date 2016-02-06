set serveroutput on size 100000
REM --------------------------------------------------------------------------------------------------
REM Author: Riyaj Shamsudeen @OraInternals, LLC
REM         www.orainternals.com
REM
REM Functionality: This script is to print GC processing timing for the past N seconds or so
REM **************
REM   
REM Source  : gv$sysstat
REM
REM Note : 1. Keep window 160 columns for better visibility.
REM
REM Exectution type: Execute from sqlplus or any other tool.  Modify sleep as needed. Default is 60 seconds
REM
REM Parameters: 
REM No implied or explicit warranty
REM
REM Please send me an email to rshamsud@orainternals.com for any question..
REM  NOTE   1. Querying gv$ tables when there is a GC performance issue is not exactly nice. So, don't run this too often.
REM         2. Until 11g, gv statistics did not include PQ traffic.
REM         3. Of course, this does not tell any thing about root cause :-)
REM @copyright : OraInternals, LLC. www.orainternals.com
REM Version	Change
REM ----------	--------------------
REM 1.10	Corrected zero divisor issue
REM --------------------------------------------------------------------------------------------------
PROMPT
PROMPT
PROMPT  gc_traffic_processing.sql v1.10 by Riyaj Shamsudeen @orainternals.com
PROMPT
PROMPT  ...Prints various timing related information for the past N seconds
PROMPT  ...Default collection period is 60 seconds.... Please wait for at least 60 seconds...
PROMPT
PROMPT Column name key:
PROMPT	 CR blk TX	: GC CR blocks served
PROMPT   CR bld tm	: Average GC CR build time/CR block served
PROMPT   CR fls tm	: Average GC CR flush time/CR block served
PROMPT   CR snd tm	: Average GC CR send time/CR block served
PROMPT
PROMPT   CUR blk TX	: GC CUR blocks served
PROMPT   CUR pin tm	: Average GC Current pin time /CUR block served
PROMPT   CUR fls tm 	: Average GC Current flush time/CUR block served
PROMPT   CUR snd tm	: Average GC current send time/CUR block served
undef sleep
set lines 170 pages 100
set verify off
declare
	type number_table   is table of number       index by binary_integer;
	b_inst_id  number_table ;
	b_cr_blks_serv  number_table ;
	b_cur_blks_serv  number_table ;
	b_cr_bld_tm  number_table ;
	b_cr_flsh_tm    number_table ;
	b_cr_snd_tm    number_table ;
	b_cur_bld_tm  number_table ;
	b_cur_pin_tm    number_table ;
	b_cur_flsh_tm    number_table ;
	b_cur_snd_tm    number_table ;
	b_cr_tot_snd_tm    number_table ;
	b_cur_tot_snd_tm    number_table ;

	e_inst_id  number_table ;
	e_cr_blks_serv  number_table ;
	e_cur_blks_serv  number_table ;
	e_cr_bld_tm  number_table ;
	e_cr_flsh_tm    number_table ;
	e_cr_snd_tm    number_table ;
	e_cur_bld_tm  number_table ;
	e_cur_pin_tm    number_table ;
	e_cur_flsh_tm    number_table ;
	e_cur_snd_tm    number_table ;
	e_cr_tot_snd_tm    number_table ;
	e_cur_tot_snd_tm    number_table ;
	v_tot_instances number;

	v_cr_blks_serv  varchar2(256);
        v_cur_blks_serv  varchar2(256);
        v_cr_blks_bld    varchar2(256);
        v_cr_blks_flsh   varchar2(256);
        v_cr_blks_sndt    varchar2(256);
        v_cur_blks_pin    varchar2(256);
        v_cur_blks_flsh   varchar2(256);
        v_cur_blks_sndt    varchar2(256);
	
	v_ver number;
	l_sleep number:=60;
	l_cr_blks_served number :=0;
	l_cur_blks_served number :=0;
begin
	  select count(*) into v_tot_instances from gv$instance;
	  select to_number(substr(banner, instr(banner, 'Release ')+8,2)) ver into v_ver from v$version where rownum=1;
	  if (v_ver  <=9) then
                v_cr_blks_serv :='global cache cr blocks served';
                v_cur_blks_serv := 'global cache current blocks served';
                v_cr_blks_bld := 'global cache cr block build time';
                v_cr_blks_flsh := 'global cache cr block flush time';
                v_cr_blks_sndt := 'global cache cr block send time';
                v_cur_blks_pin := 'global cache current block pin time';
                v_cur_blks_flsh := 'global cache current block flush time';
                v_cur_blks_sndt := 'global cache current block send time';
          else
                v_cr_blks_serv :='gc cr blocks served';
                v_cur_blks_serv := 'gc current blocks served';
                v_cr_blks_bld := 'gc cr block build time';
                v_cr_blks_flsh := 'gc cr block flush time';
                v_cr_blks_sndt := 'gc cr block send time';
                v_cur_blks_pin := 'gc current block pin time';
                v_cur_blks_flsh := 'gc current block flush time';
                v_cur_blks_sndt := 'gc current block send time';
          end if;

          select
                evt_cr_serv.inst_id,
   		evt_cr_serv.value cr_blks_serv,
   		evt_cur_serv.value cur_blks_serv,
		evt_cr_bld.value cr_bld_tm,
		evt_cr_flsh.value cr_flsh_tm,
		evt_cr_snd.value cr_snd_tm,
		evt_cur_pin.value cur_pin_tm,
		evt_cur_flsh.value cur_flsh_tm,
		evt_cur_snd.value cur_snd_tm,
		evt_cr_bld.value + evt_cr_flsh.value + evt_cr_snd.value cr_tot_snd_tm,
		evt_cur_pin.value + evt_cur_flsh.value + evt_cur_snd.value cur_tot_snd_tm
	    bulk collect into
         	b_inst_id,b_cr_blks_serv,b_cur_blks_serv,b_cr_bld_tm,b_cr_flsh_tm,b_cr_snd_tm,b_cur_pin_tm,b_cur_flsh_tm,b_cur_snd_tm,b_cr_tot_snd_tm,b_cur_tot_snd_tm
            from
		gv$sysstat evt_cr_serv,
		gv$sysstat evt_cur_serv,
		gv$sysstat evt_cr_bld,
		gv$sysstat evt_cr_flsh,
		gv$sysstat evt_cr_snd,
		gv$sysstat evt_cur_pin,
		gv$sysstat evt_cur_snd,
		gv$sysstat evt_cur_flsh
	   where
    		    evt_cr_serv.name =v_cr_blks_serv
    		and evt_cur_serv.name =v_cur_blks_serv
		and evt_cr_bld.name =v_cr_blks_bld
		and evt_cr_flsh.name =v_cr_blks_flsh
		and evt_cr_snd.name =v_cr_blks_sndt
		and evt_cur_pin.name =v_cur_blks_pin
		and evt_cur_flsh.name =v_cur_blks_flsh
		and evt_cur_snd.name =v_cur_blks_sndt
                and evt_cr_serv.inst_id=evt_cur_serv.inst_id
                and evt_cr_serv.inst_id=evt_cr_bld.inst_id
                and evt_cr_serv.inst_id=evt_cr_flsh.inst_id
                and evt_cr_serv.inst_id=evt_cr_snd.inst_id
                and evt_cr_serv.inst_id=evt_cur_pin.inst_id
                and evt_cr_serv.inst_id=evt_cur_snd.inst_id
                and evt_cr_serv.inst_id=evt_cur_flsh.inst_id
		order by inst_id
		;
          select upper(nvl('&sleep',60)) into l_sleep from dual;
	  dbms_lock.sleep(l_sleep);
          select
                evt_cr_serv.inst_id,
   		evt_cr_serv.value cr_blks_serv,
   		evt_cur_serv.value cur_blks_serv,
		evt_cr_bld.value cr_bld_tm,
		evt_cr_flsh.value cr_flsh_tm,
		evt_cr_snd.value cr_snd_tm,
		evt_cur_pin.value cur_pin_tm,
		evt_cur_flsh.value cur_flsh_tm,
		evt_cur_snd.value cur_snd_tm,
		evt_cr_bld.value + evt_cr_flsh.value + evt_cr_snd.value cr_tot_snd_tm,
		evt_cur_pin.value + evt_cur_flsh.value + evt_cur_snd.value cur_tot_snd_tm
	    bulk collect into
		e_inst_id,e_cr_blks_serv,e_cur_blks_serv,e_cr_bld_tm,e_cr_flsh_tm,e_cr_snd_tm,e_cur_pin_tm,e_cur_flsh_tm,e_cur_snd_tm,e_cr_tot_snd_tm,e_cur_tot_snd_tm
            from
		gv$sysstat evt_cr_serv,
		gv$sysstat evt_cur_serv,
		gv$sysstat evt_cr_bld,
		gv$sysstat evt_cr_flsh,
		gv$sysstat evt_cr_snd,
		gv$sysstat evt_cur_pin,
		gv$sysstat evt_cur_snd,
		gv$sysstat evt_cur_flsh
	   where
    		    evt_cr_serv.name =v_cr_blks_serv
    		and evt_cur_serv.name =v_cur_blks_serv
		and evt_cr_bld.name =v_cr_blks_bld
		and evt_cr_flsh.name =v_cr_blks_flsh
		and evt_cr_snd.name =v_cr_blks_sndt
		and evt_cur_pin.name =v_cur_blks_pin
		and evt_cur_flsh.name =v_cur_blks_flsh
		and evt_cur_snd.name =v_cur_blks_sndt
                and evt_cr_serv.inst_id=evt_cur_serv.inst_id
                and evt_cr_serv.inst_id=evt_cr_bld.inst_id
                and evt_cr_serv.inst_id=evt_cr_flsh.inst_id
                and evt_cr_serv.inst_id=evt_cr_snd.inst_id
                and evt_cr_serv.inst_id=evt_cur_pin.inst_id
                and evt_cr_serv.inst_id=evt_cur_snd.inst_id
                and evt_cr_serv.inst_id=evt_cur_flsh.inst_id
		order by inst_id
		;
	  dbms_output.put_line ( '---------|-----------|---------|-----------|----------|------------|------------|------------|----------|');
	  dbms_output.put_line ( 'Inst     | CR blk Tx |CR bld tm| CR fls tm | CR snd tm| CUR blk TX | CUR pin tm | CUR fls tm |CUR snd tm|');
	  dbms_output.put_line ( '---------|-----------|---------|-----------|----------|------------|------------|------------|----------|');
	  for i in  1 ..  v_tot_instances
		loop
			l_cr_blks_served := e_cr_blks_serv (i) - b_cr_blks_serv (i);
			l_cur_blks_served := e_cur_blks_serv (i) - b_cur_blks_serv (i);
			dbms_output.put_line ( rpad( e_inst_id (i), 9)  			|| '|' ||
				lpad(to_char(e_cr_blks_serv (i) - b_cr_blks_serv(i)),11) 	|| '|' ||
				(case when l_cr_blks_served > 0  then
   					lpad(to_char(trunc(10*( e_cr_bld_tm(i) - b_cr_bld_tm(i) )/l_cr_blks_served, 2)),9) 	
				 else		
					lpad ('0',9) 						
				 end) 								||'|'|| 
				(case when l_cr_blks_served > 0  then
					lpad(to_char(trunc(10*( e_cr_flsh_tm(i) - b_cr_flsh_tm(i) )/l_cr_blks_served, 2)),11) 
				 else		
					lpad ('0',11) 						
				 end) 								||'|'|| 
				(case when l_cr_blks_served > 0  then
					lpad(to_char(trunc(10*( e_cr_snd_tm(i) - b_cr_snd_tm(i) )/l_cr_blks_served, 2)),10) 
				 else		
					lpad ('0',10) 						
				 end) 								||'|'|| 
				lpad(to_char( e_cur_blks_serv (i) - b_cur_blks_serv (i) ), 12) 	|| '|' ||
				(case when l_cur_blks_served > 0  then
					lpad(to_char(trunc(10*( e_cur_pin_tm(i) - b_cur_pin_tm(i) )/l_cur_blks_served, 2)),11)  
				 else		
					lpad ('0',11) 						
				 end) 								||'|'|| 
				(case when l_cur_blks_served > 0  then
					lpad(to_char(trunc(10*( e_cur_flsh_tm(i) - b_cur_flsh_tm(i) )/l_cur_blks_served, 2)),12) 
				 else		
					lpad ('0',12) 						
				 end) 								||'|'|| 
				(case when l_cur_blks_served > 0  then
					lpad(to_char(trunc(10*( e_cur_snd_tm(i) - b_cur_snd_tm(i) )/l_cur_blks_served, 2)),11)   
				 else		
					lpad ('0',11) 						
				 end) 								||'|'
			);
		end loop;
	  dbms_output.put_line ( '--------------------------------------------------------------------------------------------------------');
end;
/
set verify on 