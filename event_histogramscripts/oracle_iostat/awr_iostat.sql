-- File name:   awr_iostat.sql
-- Purpose:     Display historical io statistics from v$sysstat
--
-- Author:      Vishal Desai
-- Copyright:   TBD
--      
-- Pre req:     Must run awr_iostat_proc.sql as sysdba.  
-- Run as:	    sysdba    
-- Usage:       @awr_iostat

set linesize 200
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

exec awr_iostat (&ssnap,&esnap);

set serveroutput on
set feedback off
begin
if 1 = 1 then
dbms_output.put_line('-Timestamp-|--Tot IOPS-------|-APPL IOPS-------|------TYPE-------------|--Total MBPS--|--APPL MBPS---|---------Type MBPS-----------|' );
dbms_output.put_line('-----------|-----------------------------------------------------------------------------------------------------------------------|' );
dbms_output.put_line('-----------|RD   |WR   |Tot  |RD   |WR   |Tot  |RD   |RD   |WR   |WR   |RD  |WR  |Tot |RD  |WR  |Tot |Cac |DR  |DR  |Cac |DR  |DR  |' );
dbms_output.put_line('-----------|IOPS |IOPS |IOPS |IOPS |IOPS |IOPS |1BLK |MBRC |1BLK |MBRC |MBPS|MBPS|MBPS|MBPS|MBPS|MBPS|RD  |RD  |RDTM|WR  |WR  |WRTM|' );
dbms_output.put_line('-----------------------------------------------------------------------------------------------------------------------------------|' );
end if;
end;
/

set head off
select  to_char(t_timestamp,'MM/DD HH24:MI') || '|' ||
		lpad(t_triops,5,' ') || '|' ||
		lpad(t_twiops,5,' ') || '|' ||
		lpad(t_ttiops,5,' ') || '|' ||
		lpad(t_ariops,5,' ') || '|' ||
		lpad(t_awiops,5,' ') || '|' ||
		lpad(t_atiops,5,' ') || '|' ||
		lpad(t_sbrq,5,' ') || '|' ||
		lpad(t_mbrq,5,' ') || '|' ||
		lpad(t_sbwq,5,' ') || '|' ||
		lpad(t_mbwq,5,' ') || '|' ||
		lpad(t_trmbps,4,' ') || '|' ||
		lpad(t_twmbps,4,' ') || '|' ||
		lpad(t_ttmbps,4,' ') || '|' ||
		lpad(t_armbps,4,' ') || '|' ||
		lpad(t_awmbps,4,' ') || '|' ||
		lpad(t_atmbps,4,' ') || '|' ||
		lpad(t_cr,4,' ') || '|' ||
		lpad(t_dr,4,' ') || '|' ||
		lpad(t_tr,4,' ') || '|' ||
		lpad(t_cw,4,' ') || '|' ||
		lpad(t_dw,4,' ') || '|' ||
		lpad(t_tw,4,' ') || '|' 
 from 	sys.awr_iostat_tab order by t_timestamp;

undefine ssnap
undefine esnap
