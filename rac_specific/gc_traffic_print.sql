set serveroutput on size 100000
set lines 120 pages 100
REM --------------------------------------------------------------------------------------------------
REM Author: Riyaj Shamsudeen @OraInternals, LLC
REM         www.orainternals.com
REM
REM Functionality: This script is to print GC timing for the past few minutes. 
REM **************
REM   
REM Source  : GV$ views
REM
REM Note : 1. Keep window 160 columns for better visibility.
REM
REM Exectution type: Execute from sqlplus or any other tool.  Modify sleep as needed. Default is 60 seconds
REM
REM Parameters: Modify the script to use correct parameters. Search for PARAMS below.
REM No implied or explicit warranty
REM
REM Please send me an email to rshamsud@orainternals.com for any question..
REM  NOTE   1. Querying gv$ tables when there is a GC performance issue is not exactly nice. So, don't run this too often.
REM         2. Until 11g, gv statistics did not include PQ traffic.
REM         3. Of course, this does not tell any thing about root cause :-)
REM @ copyright :  www.orainternals.com
REM Version 		Change
REM ----------		--------------------------------------------------------------
REM 1.21		Modified to handle zero divisor condition.
REM --------------------------------------------------------------------------------------------------
PROMPT
PROMPT
PROMPT  gc_traffic_print.sql v1.21 by Riyaj Shamsudeen @orainternals.com
PROMPT
PROMPT  ...Calculating GC Rx and Tx timing and blocks..
PROMPT  ...Default collection period is 60 seconds.... Please wait for at least 60 seconds...
PROMPT
PROMPT Column key:
PROMPT ==========
PROMPT   CR block RX    : GC CR blocks received
PROMPT   CR time        : Average GC CR receive time
PROMPT   CUR blocks RX  : GC CUR blocks received
PROMPT   CUR time       : Average GC CuR receive time
PROMPT   CR blocks TX   : GC CR blocks transmitted
PROMPT   CUR blocks TX  : GC CUR blocks transmitted
PROMPT   tot blocks     : Sum of transmitted + received for both CR and CUR traffic
PROMPT
set lines 160 pages 100
set verify off
undef sleep
declare
	type number_table   is table of number       index by binary_integer;
	b_inst_id  number_table ;
	b_cr_blks_serv  number_table ;
	b_cr_blks_recv  number_table ;
	b_cr_tm_recv    number_table ;

	b_cur_blks_serv  number_table ;
	b_cur_blks_recv  number_table ;
	b_cur_tm_recv    number_table ;
	b_tot_blocks     number_table ;
	e_inst_id  number_table ;
	e_cr_blks_serv  number_table ;
	e_cr_blks_recv  number_table ;
	e_cr_tm_recv    number_table ;

	e_cur_blks_serv  number_table ;
	e_cur_blks_recv  number_table ;
	e_cur_tm_recv    number_table ;
	e_tot_blocks     number_table ;
	v_ver number;

	v_tot_instances number;
	
	v_cr_blks_serv  varchar2(256); 
	v_cr_blks_recv    varchar2(256);
	v_cur_blks_serv  varchar2(256); 
	v_cur_blks_recv   varchar2(256);
	v_cr_blks_rcv_time varchar2(256);
	v_cur_blks_rcv_time varchar2(256);
	l_sleep number;
	
begin
	  select count(*) into v_tot_instances from gv$instance;
	  select to_number(substr(banner, instr(banner, 'Release ')+8,2)) ver into v_ver from v$version where rownum=1;
	  if (v_ver  <=9) then
		v_cr_blks_serv :='global cache cr blocks served';
		v_cr_blks_recv := 'global cache cr blocks received';
		v_cur_blks_serv := 'global cache current blocks served';
	  	v_cur_blks_recv := 'global cache current blocks served';
		v_cr_blks_rcv_time :='global cache cr block receive time';
		v_cur_blks_rcv_time := 'global cache current block receive time';
	  else 
		v_cr_blks_serv :='gc cr blocks served';
		v_cr_blks_recv := 'gc cr blocks received';
		v_cur_blks_serv := 'gc current blocks served';
	  	v_cur_blks_recv := 'gc current blocks received';
		v_cr_blks_rcv_time :='gc cr block receive time';
		v_cur_blks_rcv_time := 'gc current block receive time';
	  end if;
		
          select 
                evt_cr_recv.inst_id,
   		evt_cr_serv.value cr_blks_serv,
   		evt_cr_recv.value cr_blks_recv, evt_cr_tm.value cr_tm_recv   ,
   		evt_cur_serv.value cur_blks_serv,
   		evt_cur_recv.value cur_blks_recv, evt_cur_tm.value cur_tm_recv,
		evt_cr_serv.value + evt_cr_recv.value + evt_cur_serv.value + evt_cur_recv.value tot_blocks
	    bulk collect into 
		b_inst_id, b_cr_blks_serv ,b_cr_blks_recv ,b_cr_tm_recv ,
		b_cur_blks_serv, b_cur_blks_recv, b_cur_tm_recv , b_tot_blocks
            from 
		gv$sysstat evt_cr_tm, 
		gv$sysstat evt_cr_recv,
		gv$sysstat evt_cur_tm, 
		gv$sysstat evt_cur_recv,
		gv$sysstat evt_cr_serv,
		gv$sysstat evt_cur_serv
	   where
    		    evt_cr_recv.name = v_cr_blks_recv
		and evt_cr_serv.name = v_cr_blks_serv
		and evt_cur_recv.name =v_cur_blks_recv
		and evt_cur_serv.name =v_cur_blks_serv
		and evt_cr_tm.name =v_cr_blks_rcv_time
		and evt_cur_tm.name =v_cur_blks_rcv_time
                and evt_cr_tm.inst_id=evt_cr_recv.inst_id
                and evt_cr_tm.inst_id=evt_cur_tm.inst_id
                and evt_cr_tm.inst_id=evt_cur_recv.inst_id
                and evt_cr_tm.inst_id=evt_cr_serv.inst_id
                and evt_cr_tm.inst_id=evt_cur_serv.inst_id
		order by inst_id
		;
	  select nvl ('&sleep',60) into l_sleep from dual;
	  dbms_lock.sleep(l_sleep);
          select 
                evt_cr_recv.inst_id,
   		evt_cr_serv.value cr_blks_serv,
   		evt_cr_recv.value cr_blks_recv, evt_cr_tm.value cr_tm_recv   ,
   		evt_cur_serv.value cur_blks_serv,
   		evt_cur_recv.value cur_blks_recv, evt_cur_tm.value cur_tm_recv,
		evt_cr_serv.value + evt_cr_recv.value + evt_cur_serv.value + evt_cur_recv.value tot_blocks
	    bulk collect into 
		e_inst_id, e_cr_blks_serv ,e_cr_blks_recv ,e_cr_tm_recv ,
		e_cur_blks_serv, e_cur_blks_recv, e_cur_tm_recv , e_tot_blocks
            from 
		gv$sysstat evt_cr_tm, 
		gv$sysstat evt_cr_recv,
		gv$sysstat evt_cur_tm, 
		gv$sysstat evt_cur_recv,
		gv$sysstat evt_cr_serv,
		gv$sysstat evt_cur_serv
	   where
    		    evt_cr_recv.name = v_cr_blks_recv
		and evt_cr_serv.name = v_cr_blks_serv
		and evt_cur_recv.name =v_cur_blks_recv
		and evt_cur_serv.name =v_cur_blks_serv
		and evt_cr_tm.name =v_cr_blks_rcv_time
		and evt_cur_tm.name =v_cur_blks_rcv_time
                and evt_cr_tm.inst_id=evt_cr_recv.inst_id
                and evt_cr_tm.inst_id=evt_cur_tm.inst_id
                and evt_cr_tm.inst_id=evt_cur_recv.inst_id
                and evt_cr_tm.inst_id=evt_cr_serv.inst_id
                and evt_cr_tm.inst_id=evt_cur_serv.inst_id
		order by inst_id
		;
	  dbms_output.put_line ( '---------|--------------|---------|----------------|----------|---------------|---------------|-------------|');
	  dbms_output.put_line ( 'Inst     | CR blocks Rx | CR time |  CUR blocks Rx | CUR time |  CR blocks Tx | CUR blocks Tx |Tot blocks   |');
	  dbms_output.put_line ( '---------|--------------|---------|----------------|----------|---------------|---------------|-------------|');
	  for i in  1 ..  v_tot_instances
		loop
			dbms_output.put_line ( rpad( e_inst_id (i), 9)  				|| '|' ||  
				lpad(to_char(e_cr_blks_recv (i) - b_cr_blks_recv(i)),14) 		|| '|' || 
				( case  when (e_cr_blks_recv (i) - b_cr_blks_recv (i)) >0 then
				   lpad(to_char(trunc(10*( e_cr_tm_recv(i) - b_cr_tm_recv(i) )/(e_cr_blks_recv (i) - b_cr_blks_recv (i)), 2)),9) 
				  else
				   lpad('0',9) 
				  end ) 								|| '|' || 
				lpad(to_char( e_cur_blks_recv (i) - b_cur_blks_recv (i) ), 16) 		|| '|' ||  
				( case  when (e_cur_blks_recv (i) - b_cur_blks_recv (i)) >0 then
				   lpad(to_char(trunc(10*( e_cur_tm_recv(i) - b_cur_tm_recv(i) )/(e_cur_blks_recv (i) - b_cur_blks_recv (i)), 2)),10) 
				  else
				   lpad('0',10) 
				  end ) 								|| '|' || 
				lpad(to_char(e_cr_blks_serv (i) - b_cr_blks_serv (i) ),15) 		|| '|' || 
  				lpad(to_char( e_cur_blks_serv (i) - b_cur_blks_serv (i) ), 15) 		|| '|' || 
				lpad(to_char( e_tot_blocks (i) - b_tot_blocks (i) ) ,13) 		|| '|'
			);
		end loop;
	  dbms_output.put_line ( '---------|--------------|---------|----------------|----------|---------------|---------------|-------------|');
end;
/
set verify on
