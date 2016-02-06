@@header

REM 
REM    N O T    F I N I S H E D    Y E T 
REM

/*
*
*  Author     : Vishal Gupta
*  Purpose    : Search for objects
*  Parameters : 1 - owner (% - wildchar, \ - escape char)
*               2 - Object_NAME (% - wildchar, \ - escape char)
*               3 - Object_Type (% - wildchar, \ - escape char)
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  21-Feb-13  Vishal Gupta  Fixed hierarchy when parent is not present
*  16-May-12  Vishal Gupta  Created
*
*/

UNDEFINE owner
UNDEFINE object_name
UNDEFINE object_type

DEFINE owner="&&1"
DEFINE object_name="&&2"
DEFINE object_type="&&3"



COLUMN  _owner           NEW_VALUE owner            NOPRINT
COLUMN  _object_name     NEW_VALUE object_name      NOPRINT
COLUMN  _subobject_name  NEW_VALUE subobject_name   NOPRINT
COLUMN  _object_type     NEW_VALUE object_type      NOPRINT

set term off

SELECT DECODE(UPPER('&&owner'),'','%','&&owner')                   "_owner"
     , DECODE(UPPER('&&object_name'),'','%','&&object_name')       "_object_name"
     , DECODE(UPPER('&&subobject_name'),'','%','&&subobject_name') "_subobject_name"
     , DECODE(UPPER('&&object_type'),'','%','&&object_type')       "_object_type"
FROM DUAL
;

SELECT SUBSTR(UPPER('&&owner'), 1 , CASE INSTR('&&owner','.') WHEN 0 THEN LENGTH ('&&owner') ELSE INSTR('&&owner','.') - 1 END) "_owner"
     , CASE 
           WHEN INSTR('&&owner','.') != 0 THEN SUBSTR(UPPER('&&owner'),INSTR('&&owner','.')+1) 
           ELSE DECODE(UPPER('&&object_name'),'','%',UPPER('&&object_name')) 
       END    "_object_name"
     , CASE  
            WHEN INSTR('&&owner','.') != 0 THEN DECODE(UPPER('&&object_name'),'','%',UPPER('&&object_name')) 
            ELSE DECODE(UPPER('&&object_type'),'','%',UPPER('&&object_type'))        
       END  "_object_type"
FROM DUAL
;

set term on



PROMPT 
PROMPT ***************************************************************************************************
PROMPT * D E P E N D E N C Y
PROMPT * 
PROMPT * Input Parameters 
PROMPT *    - Owner      = '&&owner'
PROMPT *    - ObjectName = '&&object_name'
PROMPT *    - ObjectType = '&&object_type'
PROMPT ***************************************************************************************************
 

 
set pages 1000

COLUMN hierarchy                 HEADING "Hierarchy"                       FORMAT a70
COLUMN hierarchy_parent          HEADING "Hierarchy (Parents)"             FORMAT a60
COLUMN hierarchy_children        HEADING "Hierarchy (Children)"            FORMAT a60
COLUMN type                      HEADING "ObjectType"                      FORMAT a20
COLUMN referenced_type           HEADING "ObjectType"                      FORMAT a20
COLUMN status                    HEADING "Status"                          FORMAT a10
COLUMN last_ddl_time             HEADING "LastDDLTime"                     FORMAT a18
COLUMN last_specification_change HEADING "Last|Specification|Change"       FORMAT a18
COLUMN created                   HEADING "Created"                         FORMAT a18
COLUMN dependency_type           HEADING "DepType"                         FORMAT a7
COLUMN last_analyzed             HEADING "LastAnalyzed"                    FORMAT a18
COLUMN num_rows                  HEADING "NumRows"                         FORMAT 999,999,999,99


/*

SELECT LPAD('> ',(level-1)*5 ,'|---') ||  d.owner || '.' || d.name hierarchy_parent
     , d.type
     , o.status
     , TO_CHAR(o.last_ddl_time,'DD-MON-YY HH24:MI:SS') last_ddl_time
     , TO_CHAR(o.created,'DD-MON-YY HH24:MI:SS')  created
     , d.dependency_type
  FROM dba_dependencies d
     , dba_objects o
 WHERE d.owner = o.owner
   AND d.name  = o.object_name
   AND d.type  = o.object_type
 CONNECT BY NOCYCLE PRIOR d.owner = d.referenced_owner
                AND PRIOR d.name  = d.referenced_name
                AND PRIOR DECODE(d.type,'MATERIALIZED VIEW','TABLE',d.type)  = DECODE(d.referenced_type,'MATERIALIZED VIEW','TABLE',d.referenced_type)
START WITH d.referenced_owner LIKE '&&owner'       ESCAPE '\'
       AND d.referenced_name  LIKE '&&object_name' ESCAPE '\'
       AND d.referenced_type  LIKE '&&object_type' ESCAPE '\'
;


SELECT LPAD('> ',(level-1)*5 ,'|---') ||  d.referenced_owner || '.' || d.referenced_name hierarchy_children
     , d.referenced_type
     , o.status
     , TO_CHAR(o.last_ddl_time,'DD-MON-YY HH24:MI:SS') last_ddl_time
     , TO_CHAR(o.created,'DD-MON-YY HH24:MI:SS')  created
     , d.dependency_type
  FROM dba_dependencies d
     , dba_objects o
 WHERE d.referenced_owner = o.owner
   AND d.referenced_name  = o.object_name
   AND d.referenced_type  = o.object_type
 CONNECT BY NOCYCLE  d.owner = PRIOR d.referenced_owner
                AND  d.name  = PRIOR d.referenced_name
                AND  DECODE(d.type,'MATERIALIZED VIEW','TABLE',d.type)  = PRIOR DECODE(d.referenced_type,'MATERIALIZED VIEW','TABLE',d.referenced_type)
START WITH d.owner LIKE '&&owner'       ESCAPE '\'
       AND d.name  LIKE '&&object_name' ESCAPE '\'
       AND d.type  LIKE '&&object_type' ESCAPE '\'
;
*/

WITH parent as 
(
SELECT /*+ no_merge */
       level hlevel
     , d.owner
     , d.name
     , d.type
     , o.status
     , o.last_ddl_time
     , o.timestamp
     , o.created
     , d.dependency_type
  FROM dba_dependencies d
     , dba_objects o
 WHERE d.owner = o.owner
   AND d.name  = o.object_name
   AND d.type  = o.object_type
 CONNECT BY NOCYCLE PRIOR d.owner = d.referenced_owner
                AND PRIOR d.name  = d.referenced_name
                AND PRIOR DECODE(d.type,'MATERIALIZED VIEW','TABLE',d.type)  = DECODE(d.referenced_type,'MATERIALIZED VIEW','TABLE',d.referenced_type)
START WITH d.referenced_owner LIKE '&&owner'       ESCAPE '\'
       AND d.referenced_name  LIKE '&&object_name' ESCAPE '\'
       AND d.referenced_type  LIKE '&&object_type' ESCAPE '\'
)
, parent_level as
   (SELECT  NVL(min(hlevel),0) min_parent_level
          , NVL(max(hlevel),1) max_parent_level 
    from parent)
, children as
(
SELECT /*+ no_merge */ 
       level + max_parent_level  hlevel
     , d.referenced_owner
     , d.referenced_name
     , d.referenced_type
     , o.status
     , o.last_ddl_time
     , o.timestamp
     , o.created
     , d.dependency_type
  FROM dba_dependencies d
     , dba_objects o
     , parent_level
 WHERE d.referenced_owner = o.owner
   AND d.referenced_name  = o.object_name
   AND d.referenced_type  = o.object_type
 CONNECT BY NOCYCLE  d.owner = PRIOR d.referenced_owner
                AND  d.name  = PRIOR d.referenced_name
                -- For materialized views dependency view show dependency on underlying MV table.
                AND  DECODE(d.type,'MATERIALIZED VIEW','TABLE',d.type)  = PRIOR DECODE(d.referenced_type,'MATERIALIZED VIEW','TABLE',d.referenced_type)
START WITH d.owner LIKE '&&owner'       ESCAPE '\'
       AND d.name  LIKE '&&object_name' ESCAPE '\'
       AND d.type  LIKE '&&object_type' ESCAPE '\'
)
, hierarchy as 
(
SELECT /*+ no_merge */ --LPAD('-',(p.hlevel-1) * 4 ,'|---') ||  p.owner || '.' || p.name hierarchy
       p.hlevel
     , p.owner
     , p.name object_name
     , p.type
     , p.status
     , p.last_ddl_time
     , p.timestamp
     , p.created
     , p.dependency_type
  FROM parent p 
UNION ALL
SELECT /*+ no_merge */ 
       --LPAD('-', (min_parent_level ) * 4 ,'|---') ||  o.owner || '.' || o.object_name
    min_parent_level 
     , o.owner
     , o.object_name
     , o.object_type
     , o.status
     , o.last_ddl_time
     , o.timestamp
     , o.created
     , ''
  FROM dba_objects o
     , parent_level
 WHERE o.owner            LIKE '&&owner'       ESCAPE '\'
       AND o.object_name  LIKE '&&object_name' ESCAPE '\'
UNION ALL
SELECT /*+ no_merge */ -- LPAD('-',(c.hlevel-1)*4 ,'|---') ||  c.referenced_owner || '.' || c.referenced_name hierarchy
       c.hlevel
     , c.referenced_owner
     , c.referenced_name
     , c.referenced_type     type
     , c.status                
     , c.last_ddl_time
     , c.timestamp
     , c.created
     , c.dependency_type
 FROM children c
)
SELECT LPAD('-',(h.hlevel-1)*4 ,'|---') ||  h.owner || '.' || h.object_name hierarchy
     , h.type
     , h.status
     , TO_CHAR(h.last_ddl_time,'DD-MON-YY HH24:MI:SS')      last_ddl_time
     , TO_CHAR(TO_DATE(h.timestamp,'YYYY-MM-DD HH24:MI:SS'),'DD-MON-YY HH24:MI:SS') last_specification_change
     , TO_CHAR(h.created,'DD-MON-YY HH24:MI:SS')            created
     , h.dependency_type
     , TO_CHAR(t.last_analyzed,'DD-MON-YY HH24:MI:SS')      last_analyzed
  , t.num_rows
  FROM hierarchy h
       LEFT OUTER JOIN dba_tables t ON t.owner = h.owner AND t.table_name = h.object_name AND h.type = 'TABLE'
;

@@footer
