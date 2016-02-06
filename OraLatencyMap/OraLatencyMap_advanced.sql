--
-- OraLatencyMap_advanced, a tool to visualize Oracle event latency using Heat Maps
--
-- Luca.Canali@cern.ch, v1.1, May 2013
--
-- Credits: Brendan Gregg for "Visualizing System Latency", Communications of the ACM, July 2010
--          Tanel Poder (snapper, moats, sqlplus and color), Marcin Przepiorowski (topass)
--
--
-- Notes: This script needs to be run from sqlplus from a terminal supporting ANSI escape codes. 
--        Tested on 11.2.0.3, Linux. 
--        Run from a privileged user (select on v$event_histogram and execute on dbms_lock.sleep)
--
-- Use: @OraLatencyMap_event <refresh time in sec> "<event name>" <num cols> <num rows> "additional where clause"
--      Note: Run from SQL*plus. 
--            Better not use rlwrap when running this, or graphics smoothness will suffer
--
-- Example: @OraLatencyMap_advanced 5 "db file sequential read" 12 80 "and inst_id=1"
--
-- Output: 2 latency heat maps of the given wait event
--         The top map represents the number of waits per second and per latency bucket
--         The bottom map represented the estimated time waited per second and per latency bucket
-- 
--         
-- Related: OraLatencyMap_event    -> another script based on OraLatencyMap_advanced 
--          OraLatencyMap          -> another script based on OraLatencyMap_advanced 
--          OraLatencyMap_internal -> the slave script where all the computation and visualization is done
--          OraLatencyMap_internal_loop -> the slave script that runs several dozens of iterations of the tool's engine 


set lines 2000
set pages 100
set feedback off
set verify off
set heading off
set long 100000
set longchunksize 100000

var var_dump_wait_count  clob
var var_dump_time_waited clob
var var_screen clob

var var_dump_latest_wait_count varchar2(1000)
var var_dump_latest_time_waited varchar2(1000)
var var_dump_latest_time_sec number

var var_number_iterations number

begin
  :var_number_iterations :=0;
  :var_dump_wait_count :='';
  :var_dump_time_waited :='';
end;
/

define sleep_interval=&1
define wait_event='&2'
define num_bins=&3
define num_rows=&4
define instance_filter_clause='&5'

prompt OraLatencyMap collecting first datapoints, please wait.
prompt Note: this tool requires a terminal supporting ANSI escape code (examples: xterm, putty)

--The actual code is in the OraLatencyMap_internal script. 
--The script below is used as a workaround to call OraLatencyMap_internal multiple times and simulate a for-loop

@@OraLatencyMap_internal_loop

