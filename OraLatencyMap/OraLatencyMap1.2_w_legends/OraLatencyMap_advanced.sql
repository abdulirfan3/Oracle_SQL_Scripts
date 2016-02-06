--
-- OraLatencyMap_advanced, a tool to visualize Oracle event latency using Heat Maps
--
-- Luca.Canali@cern.ch, v1.2, March 2014
--
-- More info: see README file
--
-- Use: @OraLatencyMap_advanced <refresh time in sec> "<event name>" <num cols> <num rows> "additional where clause"
--      Run from SQL*plus. 
--
-- Example: @OraLatencyMap_advanced 5 "db file sequential read" 12 80 "and inst_id=1"
--
-- Output: 2 latency heat maps of the given wait event
--         The top map represents the number of waits per second and per latency bucket
--         The bottom map represented the estimated time waited per second and per latency bucket
-- 

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

