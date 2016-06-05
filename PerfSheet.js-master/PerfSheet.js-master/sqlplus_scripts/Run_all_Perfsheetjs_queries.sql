--
-- Run_all_Perfsheetjs_queries.sql - this is part of PerfSheetjs. It is a wrapper script to the AWR extraction queries
-- Luca Canali, last modified Jan 2016
--

-- Usage:
--   Run the script from sql*plus connected as a priviledged user (need to be able to read AWR tables)
--   Can run it over sql*net from client machine or locally on db server
--   Customize the file perfsheet4_definitions.sql before running this, in particular define there the interval of analysis
--

@@Perfsheetjs_query_AWR_sysmetric.sql
@@Perfsheetjs_query_AWR_sysstat.sql
@@Perfsheetjs_query_AWR_system_event.sql
@@Perfsheetjs_query_AWR_top3_waitevent_and_CPU.sql

exit
