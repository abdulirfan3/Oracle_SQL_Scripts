set serveroutput on size 100000
set lines 120 pages 100
REM --------------------------------------------------------------------------------------------------
REM Author: Riyaj Shamsudeen @OraInternals, LLC
REM         www.orainternals.com
REM
REM Functionality: This script is to print changes at event level. Very useful for RAC troubleshooting
REM **************
REM
REM Source  : GV$ views
REM
REM Note : 1. Keep window 160 columns for better visibility.
REM
REM Exectution type: Execute from sqlplus or any other tool.  Modify sleep as needed. Default is 60 seconds
REM
REM Parameters: Modify the script to use correct parameters. 
REM No implied or explicit warranty
REM
REM Please send me an email to rshamsud@orainternals.com for any question..
REM  NOTE   1. Querying gv$ tables when there is a GC performance issue is not exactly nice. So, don't run this too often.
REM         2. Of course, this does not tell any thing about root cause :-) Yet another tool to probe deeper
REM @ copyright :  www.orainternals.com
REM --------------------------------------------------------------------------------------------------
PROMPT
PROMPT
PROMPT  gc_event_histogram.sql v1.0 by Riyaj Shamsudeen @orainternals.com
PROMPT
PROMPT  Default collection period is sleep seconds. Please wait..
undef sleep    
undef event
set verify off
declare
        type t_key_array is table of varchar2(64) index by binary_integer;
	type t_wait_count   is table of number       index by varchar2(64);
	b_wait_count  t_wait_count ;
	e_wait_count  t_wait_count ;
        key_array  t_key_array;
        i number :=1;
        v_tot_instances number;
	v_ver number;
	function get_token( the_list  varchar2, the_index number, delim     varchar2 := '~')
 		  return    varchar2
	is
   		start_pos number;
   		end_pos   number;
	begin
   		if the_index = 1 then 
			start_pos := 1;
   		else
       			start_pos := instr(the_list, delim, 1, the_index - 1);
       			if start_pos = 0 then
           			return null;
       			else
           			start_pos := start_pos + length(delim);
       			end if;
   		end if;
   		end_pos := instr(the_list, delim, start_pos, 1);
   		if end_pos = 0 then
       			return substr(the_list, start_pos);
   		else
       			return substr(the_list, start_pos, end_pos - start_pos);
   		end if;
	end get_token;
begin
	  select count(*) into v_tot_instances from gv$instance;
	  select to_number(substr(banner, instr(banner, 'Release ')+8,2)) ver into v_ver from v$version where rownum=1;
          for c1 in ( select event, inst_id,wait_time_milli, wait_count from gv$event_histogram where event like '%&&event%'
		order by inst_id, event,wait_time_milli  )
          loop
              key_array(i) := c1.event ||'~'||c1.inst_id ||'~'||c1.wait_time_milli;
              b_wait_count(c1.event ||'~'||c1.inst_id ||'~'||c1.wait_time_milli) := c1.wait_count ;
	      i := i+1;
          end loop;
	  dbms_lock.sleep(&&sleep);
          for c1 in ( select event, inst_id,wait_time_milli, wait_count from gv$event_histogram where event like '%&&event%')
          loop
              e_wait_count(c1.event ||'~'||c1.inst_id ||'~'||c1.wait_time_milli) := c1.wait_count ;
	 --     dbms_output.put_line ( e_wait_count(c1.event ||'~'||c1.inst_id ||'~'||c1.wait_time_milli)  );
          end loop;
	 --      dbms_output.put_line (i ||' '||j || ' ' || key_array(j));
	  dbms_output.put_line ( '---------|-----------------------|----------------|----------|');
	  dbms_output.put_line ( 'Inst id  | Event                 |wait time milli |wait cnt  |');
	  dbms_output.put_line ( '---------|-----------------------|----------------|----------|');
          for j in 1 .. i-1
	  loop
	  dbms_output.put_line ( rpad(get_token(key_array (j) ,2,'~'),9) || '|' || 
				 rpad(get_token(key_array (j) ,1,'~'),23) || '|' || 
				 lpad(get_token(key_array (j) ,3,'~'),16) || '|' || 
				 lpad((e_wait_count(key_array(j)) - b_wait_count(key_array(j))), 10) ||'|' ); 
	       -- e_wait_count (key_array(j))
               --dbms_output.put_line (' Wait cnt ' || key_array(j) || '  '|| e_wait_count (key_array(j)) - b_wait_count(key_array(j)));
          end loop;
	  dbms_output.put_line ( '---------|-----------------------|----------------|----------|');
end;
/