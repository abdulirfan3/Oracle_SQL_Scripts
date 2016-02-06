@@header

/*
*
*  Author     : Vishal Gupta
*  Purpose    : Display Statistics of a table (including part, sub-par, ind, ind-part, ind-subpart)
*  Parameters : 1 - SQLId
*               2 - SQL Child Number
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  01-Oct-12  Vishal Gupta  Created
*
*
*/


/************************************
*  INPUT PARAMETERS
************************************/
UNDEFINE sql_id
UNDEFINE child_number

DEFINE sql_id="&&1"
DEFINE child_number="&&2"


COLUMN  _child_number             NEW_VALUE child_number             NOPRINT

set term off
SELECT DECODE('&&child_number','','0','&&child_number')          "_child_number"
FROM DUAL;
set term on


PROMPT
PROMPT ***********************************************************************
PROMPT *  O B J E C T     S T A T I S T I C S ( For a SQLId)
PROMPT *
PROMPT *  Input Parameters 
PROMPT *  - SQL Id       = '&&sql_id'
PROMPT *  - Child Number = '&&child_number'
PROMPT ***********************************************************************

COLUMN object_name             HEADING "TableName"                FORMAT a50
COLUMN Object_type             HEADING "Object|Type"              FORMAT a6
COLUMN stale_stats             HEADING "Stale|Stats"              FORMAT a5
COLUMN stattype_locked         HEADING "Locked|Stats"             FORMAT a5
COLUMN last_analyzed           HEADING "LastAnalyzed"             FORMAT a18
COLUMN user_stats              HEADING "U|s|e|r"                  FORMAT a1  TRUNCATE
COLUMN sample_size             HEADING "SampleSize"               FORMAT 9,999,999,999
COLUMN num_rows                HEADING "RowCount"                 FORMAT 9,999,999,999
COLUMN blocks                  HEADING "Blocks"                   FORMAT 9,999,999,999
COLUMN Size_MB                 HEADING "Size(MB)"                 FORMAT 9,999,999,999

WITH objects AS
(
   SELECT /*+ NO_MERGE LEADING (sp)  */ 
         DISTINCT 
          o.owner
        , o.object_name
        , o.subobject_name
        , o.object_type
        , sp.partition_id
     FROM gv$sql_plan sp
        , dba_objects o
   WHERE sp.object#      = o.object_id
     AND sp.sql_id       = '&&sql_id'
     AND sp.child_number = '&&child_number'
     AND sp.object_type IS NOT NULL
)
,stats AS
(
   SELECT /*+ NO_MERGE LEADING(o)  */
          s.owner 
          || '.' || s.table_name 
          || NVL2(s.partition_name,':' || s.partition_name, '')
          || NVL2(s.subpartition_name,':' || s.subpartition_name, '')
          object_name
        , o.object_type
        , s.stale_stats
        , s.stattype_locked
        , s.last_analyzed
        , s.sample_size
        , s.num_rows
        , s.blocks
        , (seg.bytes)/1024/1024 Size_MB
     FROM objects o
          JOIN dba_tab_statistics s ON  o.owner = s.owner 
                                    AND o.object_name = s.table_name 
                                    AND NVL(s.partition_name,'%')   LIKE NVL(o.subobject_name,'%') 
                                    AND NVL(s.partition_position,0) LIKE NVL(o.partition_id,0)
          JOIN dba_segments seg  ON  seg.owner = o.owner 
                                 AND seg.segment_name = o.object_name 
                               --AND seg.segment_type = o.object_type 
                                 AND NVL(o.subobject_name,'%') LIKE NVL(seg.partition_name,'%')
                                 AND NVL(s.partition_position,0) = NVL(o.partition_id,0)
    WHERE s.table_name NOT LIKE 'BIN$%'
      AND s.table_name NOT LIKE '%==%'
   UNION ALL
   SELECT /*+ NO_MERGE LEADING(o)  */
           s.owner 
          || '.' || s.index_name 
          || NVL2(s.partition_name,':' || s.partition_name, '')
          || NVL2(s.subpartition_name,':' || s.subpartition_name, '')
          object_name
        , o.object_type
        , s.stale_stats
        , s.stattype_locked
        , s.last_analyzed
        , s.sample_size
        , s.num_rows
        , s.leaf_blocks blocks
        , (seg.bytes)/1024/1024 Size_MB
     FROM objects o
          JOIN dba_ind_statistics s ON  o.owner  = s.owner
                                    AND o.object_name = s.index_name
                                    AND NVL(o.subobject_name,'%') = NVL(s.partition_name,'%')
          JOIN dba_segments seg     ON  seg.owner = o.owner
                                    AND seg.segment_name = o.object_name
                                   -- AND seg.segment_type = o.object_type
                                    AND NVL(seg.partition_name,'%') = NVL(o.subobject_name,'%')
    WHERE s.table_name NOT LIKE 'BIN$%'
      AND s.index_name NOT LIKE 'BIN$%'
      AND s.table_name NOT LIKE '%==%'
      AND s.index_name NOT LIKE '%==%'
)
SELECT    object_name
        , object_type
        , stale_stats
              , stattype_locked
        , to_char(s.last_analyzed,'DD-MON-YY HH24:MI:SS') last_analyzed
        , sample_size
        , num_rows
        , blocks
        , Size_MB
  FROM stats s
ORDER BY s.last_analyzed ASC
;



@@footer
