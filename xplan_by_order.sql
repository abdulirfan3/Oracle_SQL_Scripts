-- @xplan.TO_GET_ORDER.sql 3wzptkw7qxgr1 0
-- @xplan.TO_GET_ORDER.sql sql_id child_id
-- ----------------------------------------------------------------------------------------------
--
-- Script:       xplan.display_cursor.sql
--
-- Author:       Adrian Billington
--               www.oracle-developer.net
--
-- Description:  A free-standing SQL wrapper over DBMS_XPLAN. Provides access to the 
--               DBMS_XPLAN.DISPLAY_CURSOR pipelined function for a given SQL_ID and CHILD_NO.
--
--               The XPLAN wrapper package has one purpose: to include the parent operation ID
--               and an execution order column in the plan output. This makes plan interpretation
--               easier for larger or more complex execution plans. See the following example 
--               for details.
--
-- Example:      DBMS_XPLAN output (format BASIC):
--               ------------------------------------------------
--               | Id  | Operation                    | Name    |
--               ------------------------------------------------
--               |   0 | SELECT STATEMENT             |         |
--               |   1 |  MERGE JOIN                  |         |
--               |   2 |   TABLE ACCESS BY INDEX ROWID| DEPT    |
--               |   3 |    INDEX FULL SCAN           | PK_DEPT |
--               |   4 |   SORT JOIN                  |         |
--               |   5 |    TABLE ACCESS FULL         | EMP     |
--               ------------------------------------------------
--
--               Equivalent XPLAN output (format BASIC):
--               ------------------------------------------------------------
--               | Id  | Pid | Ord | Operation                    | Name    |
--               ------------------------------------------------------------
--               |   0 |     |   6 | SELECT STATEMENT             |         |
--               |   1 |   0 |   5 |  MERGE JOIN                  |         |
--               |   2 |   1 |   2 |   TABLE ACCESS BY INDEX ROWID| DEPT    |
--               |   3 |   2 |   1 |    INDEX FULL SCAN           | PK_DEPT |
--               |   4 |   1 |   4 |   SORT JOIN                  |         |
--               |   5 |   4 |   3 |    TABLE ACCESS FULL         | EMP     |
--               ------------------------------------------------------------
--
-- Usage:        @xplan.display_cursor.sql <sql_id> <cursor_child_number>
--
-- Versions:     This utility will work for all versions of 10g and upwards.
--
-- Required:     1) Access to V$SQL_PLAN
--
-- Notes:        An XPLAN package is also available. This has wrappers for all of the 
--               DBMS_XPLAN pipelined functions, but requires the creation of objects, which
--               might not be allowed.
--
-- Credits:      1) James Padfield for the hierarchical query to order the plan operations. 
--               2) Paul Vale for the suggestion to turn XPLAN.DISPLAY_CURSOR into a standalone
--                  SQL script, including a prototype.
--
-- Disclaimer:   http://www.oracle-developer.net/disclaimer.php
--
-- ----------------------------------------------------------------------------------------------

col plan_table_output format a250
--set lines 150 pages 1000

define si = &1;
define cn = &2;

WITH sql_plan_data AS (
        SELECT  id, parent_id
        FROM    v$sql_plan
        WHERE   sql_id = '&si'
        AND     child_number = &cn
        )
,    hierarchy_data AS (
        SELECT  id, parent_id
        FROM    sql_plan_data
        START   WITH id = 0
        CONNECT BY PRIOR id = parent_id
        ORDER   SIBLINGS BY ID DESC
        )
,    ordered_hierarchy_data AS (
        SELECT id
        ,      parent_id AS pid
        ,      ROW_NUMBER() OVER (ORDER BY ROWNUM DESC) AS oid
        ,      MAX(id) OVER () AS maxid
        FROM   hierarchy_data
        )
,    xplan_data AS (
        SELECT x.plan_table_output
        ,      o.id
        ,      o.pid
        ,      o.oid
        ,      o.maxid  
        FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&si',&cn)) x
        ,      ordered_hierarchy_data o
        WHERE  o.id (+) = CASE
                             WHEN REGEXP_LIKE(x.plan_table_output, '^\|[\* 0-9]+\|')
                             THEN TO_NUMBER(REGEXP_SUBSTR(x.plan_table_output, '[0-9]+'))
                          END
        )
SELECT plan_table_output
FROM   xplan_data
MODEL
   DIMENSION BY (ROWNUM AS r)
   MEASURES (plan_table_output,
             id,
             maxid,
             pid,
             oid,
             GREATEST(MAX(LENGTH(maxid)) OVER () + 3, 6) AS csize,
             CAST(NULL AS VARCHAR2(128)) AS inject)
   RULES SEQUENTIAL ORDER (
          inject[r] = CASE
                         WHEN id[CV(r)+1] = 0
                         OR   id[CV(r)+3] = 0
                         OR   id[CV(r)-1] = maxid[CV(r)-1]
                         THEN RPAD('-', csize[CV()]*2, '-')
                         WHEN id[CV(r)+2] = 0
                         THEN '|' || LPAD('Pid |', csize[CV()]) || LPAD('Ord |', csize[CV()])
                         WHEN id[CV()] IS NOT NULL
                         THEN '|' || LPAD(pid[CV()] || ' |', csize[CV()]) || LPAD(oid[CV()] || ' |', csize[CV()]) 
                      END, 
          plan_table_output[r] = CASE
                                    WHEN inject[CV()] LIKE '---%'
                                    THEN inject[CV()] || plan_table_output[CV()]
                                    WHEN inject[CV()] IS PRESENT
                                    THEN REGEXP_REPLACE(plan_table_output[CV()], '\|', inject[CV()], 1, 2)
                                    ELSE plan_table_output[CV()]
                                 END
         );

undefine si;
undefine cn;
