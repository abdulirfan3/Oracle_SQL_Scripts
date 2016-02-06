--------------------------------------------------------------------------------
-- WARNING!     Sampling some views like V$SQL, V$OPEN_CURSOR, X$KSMSP in a loop
--              may cause some serious latch contention in your instance.
--
-- Usage:       @sample <column[,column]> <table> <filter condition> <num. samples>
--
-- Examples:    @sample sql_id v$session sid=142 1000 
--              @sample sql_id,event v$session "sid=142 and state='WAITING'" 1000
--              @sample plsql_object_id,plsql_subprogram_id,sql_id v$session sid=142 1000
--
-- File name:   sample.sql
-- Purpose:     Sample any V$ view or X$ table and display aggregated results
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- 	        
--
-- Other:       This script temporarily disables hash and sort merge join to 
--              get NESTED LOOPS join method (this is how the sampling is done)
--
--
/*
NB! I must warn you about sampling any view! While sampling views like V$SESSION, V$PROCESS and V$SESSION_WAIT is safe, there are some which you should not sample, well at least in production. X$KSMSP is first which comes into mind as even a single query against it can grab your shared pool latches for way long time, potentially halting all database activity. Another ones are V$SQL and V$OPEN_CURSOR and V$DB_OBJECT_CACHE and like as traversing through their underlying memory structures (library cache) requires quite a lot of library cache latching so normal user SQL execution could be heavily impacted.

However there’s an easy way to check whether an access to V$ view uses latches or not. You just need to sample some V$ view in your test environment and use instructions from my LatchProfX post for checking the latch usage from another session. Note that LatchProfX doesn’t show KGX mutex activity, so be aware that in Oracle 11g the V$SQL / X$KGLOB traversal is done under exclusive protection of Library Cache mutex, thus sampling those tables frequently is still not a good idea (and you don’t really get much out of sampling them thousands of times per second anyway)
*/              
--------------------------------------------------------------------------------

col sample_msec for 9999999.99

-- the alter session commands should be uncommented
-- if running this script on 10.1.x or earlier as the opt_param hints work on 10.2+

set termout off
--begin
--    begin execute immediate 'alter session set "_optimizer_sortmerge_join_enabled"=false'; exception when others then null; end;
--    begin execute immediate 'alter session set "hash_join_enabled"=false'; exception when others then null; end;
--end;
--/

set termout on

WITH 
    t1 AS (SELECT hsecs FROM v$timer),
    q AS (
        select /*+ ORDERED USE_NL(t) opt_param('_optimizer_sortmerge_join_enabled','false') opt_param('hash_join_enabled','false') NO_TRANSFORM_DISTINCT_AGG */ 
            &1 , count(*) "COUNT", count(distinct r.rn) DISTCOUNT
        from
            (select /*+ no_unnest */ rownum rn from dual connect by level <= &4) r
          , &2 t
        where &3
        group by
            &1
        order by
            "COUNT" desc, &1
    ),
    t2 AS (SELECT hsecs FROM v$timer)
SELECT /*+ ORDERED */
    trunc((t2.hsecs - t1.hsecs) * 10 * q.distcount / &4, 2) sample_msec
  , (t2.hsecs - t1.hsecs) * 10 total_msec
  , ROUND(((t2.hsecs - t1.hsecs) * 10 * q.distcount / &4) / ((t2.hsecs - t1.hsecs) * 10) * 100, 2) percent
  , q.*
FROM
     t1,
     q,
     t2
/

--set termout off
--begin
--    begin execute immediate 'alter session set "_optimizer_sortmerge_join_enabled"=true'; exception when others then null; end;
--    begin execute immediate 'alter session set "hash_join_enabled"=true'; exception when others then null; end;
--end;
--/
set termout on