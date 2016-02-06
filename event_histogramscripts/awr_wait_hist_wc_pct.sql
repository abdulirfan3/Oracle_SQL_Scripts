-- File name:   awr_wait_hist_wc_pct.sql
-- Purpose:     Display historical io latency wait count percentage
--
-- Author:      Vishal Desai
-- Copyright:   TBD
--      
-- Pre req:     Must run awr_iostat_proc.sql as sysdba.  
-- Run as:	    sysdba    
-- Usage:       @awr_wait_hist_wc_pct.sql

set linesize 300
set pages 200
--set verify off
column event_name format a40
accept start_date      prompt 'Please enter start_date(mm/dd/yy)    :'
accept end_date        prompt 'Please enter end_date  (mm/dd/yy)    :'

select snap_id,begin_interval_time from dba_hist_snapshot 
where begin_interval_time>=to_date('&start_date','mm/dd/yy')
and   begin_interval_time<=to_date('&end_date','mm/dd/yy')+1
order by snap_id;

accept ssnap      prompt 'Enter value for start snap_id   :'
accept esnap      prompt 'Enter value for end snap_id     :'
accept event      prompt 'Enter wait event                :'
accept  inst_num  prompt 'Enter instance number for RAC   :'

exec sp_awr_event_hist_wc_pct ('&event',&inst_num,&ssnap,&esnap);

set serveroutput on
set feedback off
begin
if 1 = 1 then
dbms_output.put_line('---------------------------------------------------------------Percent Wait Count-------------------------------------------------------------------------------|' );
dbms_output.put_line('Event                    |Time                |<1    |<2    |<4    |<8    |<16   |<32   |<64   |<128  |<256  |<512  |<1024 |<2048 |<4096 |<8192 |Tot Wait Count |' );
dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------------------------------|' );
end if;
end;
/

set head off
select  rpad(event,25,' ') || '|' ||
        rpad(to_char(t_timestamp,'MM/DD/YY HH24:MI'),20,' ') || '|' ||
		lpad(t_1,6,' ') || '|' ||
		lpad(t_2,6,' ') || '|' ||
		lpad(t_4,6,' ') || '|' ||
		lpad(t_8,6,' ') || '|' ||
		lpad(t_16,6,' ') || '|' ||
		lpad(t_32,6,' ') || '|' ||
		lpad(t_64,6,' ') || '|' ||
		lpad(t_128,6,' ') || '|' ||
		lpad(t_256,6,' ') || '|' ||
		lpad(t_512,6,' ') || '|' ||
		lpad(t_1024,6,' ') || '|' ||
		lpad(t_2048,6,' ') || '|' ||
		lpad(t_4096,6,' ') || '|' ||
		lpad(t_8192,6,' ') || '|' ||
		lpad(tot_wait_count,15,' ') || '|' 
 from 	awr_event_histogram_wc_pct order by t_timestamp;


undefine ssnap
undefine esnap
undefine start_date
undefine end_date
undefine event
undefine inst_num
