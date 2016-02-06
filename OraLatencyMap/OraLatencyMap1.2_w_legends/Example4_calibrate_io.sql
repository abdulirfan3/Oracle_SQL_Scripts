--
-- This is an example launcher script for OraLatencyMap 
-- The sqlplus script reads from gv$event_histogram data the latency drilldown for the Disk file I/O Calibration read  wait event
-- and displays data as two heatmaps: a Frequency heatmap and an Intensity heatMap
-- This script is intended to be used to measure the latency drilldown for calibrate_io workload 
--
-- The example here below is added for convenience. It shows how to run calibrate_io workload from sql*plus
-- 
/* 
 SET SERVEROUTPUT ON
  DECLARE
   lat  INTEGER;
   iops INTEGER;
   mbps INTEGER;
 BEGIN
    DBMS_RESOURCE_MANAGER.CALIBRATE_IO (10, 100, iops, mbps, lat);
 
    DBMS_OUTPUT.PUT_LINE ('max_iops = ' || iops);
    DBMS_OUTPUT.PUT_LINE ('latency  = ' || lat);
   DBMS_OUTPUT.PUT_LINE ('max_mbps = ' || mbps);
 END;
 /
*/

@@OraLatencyMap_advanced 3 "Disk file I/O Calibration" 11 90 ""

