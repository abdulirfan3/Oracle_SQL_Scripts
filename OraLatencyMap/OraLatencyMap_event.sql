--
-- OraLatencyMap_event, a tool to visualize Oracle event latency using Heat Maps
--
-- Luca.Canali@cern.ch, v1.1, May 2013
--
-- Credits: Brendan Gregg for "Visualizing System Latency", Communications of the ACM, July 2010
--          Tanel Poder (snapper, moats, sqlplus and color), Marcin Przepiorowski (topass)
--
-- Notes: This script needs to be run from sqlplus from a terminal supporting ANSI escape codes. 
--        Tested on 11.2.0.3, Linux. 
--        Run from a privileged user (select on v$event_histogram and execute on dbms_lock.sleep)
--
-- Use: @OraLatencyMap_event <refresh time in sec> "<event name>" 
--      Note: Run from SQL*plus. 
--            Better not use rlwrap when running this, or graphics smoothness will suffer
--
-- Example: @OraLatencyMap_event 3 "log file sync"
--
-- Output: 2 latency heat maps of the given wait event
--         The top map represents the number of waits per second and per latency bucket
--         The bottom map represented the estimated time waited per second and per latency bucket
-- 
--         
-- Related: OraLatencyMap_advanced -> this is the main script for generic investigation of event latency with heat maps
--          OraLatencyMap          -> another script based on OraLatencyMap_advanced 
--          OraLatencyMap_internal -> the slave script where all the computation and visualization is done
--          OraLatencyMap_internal_loop -> the slave script that runs several dozens of iterations of the tool's engine 

@@OraLatencyMap_advanced &1 "&2" 11 90 ""

