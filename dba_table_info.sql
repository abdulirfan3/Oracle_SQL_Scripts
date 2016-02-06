-- | PURPOSE  : Prompt the user for a schema and and table name then query all  |
-- |            metadata about the table.                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999
SET VERIFY   OFF
SET FEEDBACK OFF
SET LONG 9000

-- +----------------------------------------------------------------------------+
-- | PROMPT USER FOR SCHEMA AND TABLE                                           |
-- +----------------------------------------------------------------------------+

ACCEPT sch prompt 'Enter Schema (i.e. SCOTT) : '
ACCEPT tab prompt 'Enter Table  (i.e. EMP) : '


PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | TABLE INFORMATION                                                          |
PROMPT +----------------------------------------------------------------------------+

COLUMN owner               FORMAT A15                HEADING "Owner"
COLUMN table_name          FORMAT A30                HEADING "Table Name"
COLUMN tablespace_name     FORMAT A28                HEADING "Tablespace"
COLUMN last_analyzed       FORMAT A20                HEADING "Last Analyzed"
COLUMN num_rows            FORMAT 999,999,999        HEADING "# of Rows"

SELECT
    owner
  , table_name
  , tablespace_name
  , TO_CHAR(last_analyzed, 'DD-MON-YYYY HH24:MI:SS') last_analyzed
  , num_rows
FROM
    dba_tables
WHERE
      owner      = UPPER('&sch')
  AND table_name = UPPER('&tab')
/

PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | OBJECT INFORMATION                                                         |
PROMPT +----------------------------------------------------------------------------+

COLUMN object_id                                     HEADING "Object ID"
COLUMN data_object_id                                HEADING "Data Object ID"
COLUMN created             FORMAT A20                HEADING "Created"
COLUMN last_ddl_time       FORMAT A20                HEADING "Last DDL"
COLUMN status                                        HEADING "Status"

SELECT
    object_id
  , data_object_id
  , TO_CHAR(created, 'DD-MON-YYYY HH24:MI:SS')        created
  , TO_CHAR(last_ddl_time, 'DD-MON-YYYY HH24:MI:SS')  last_ddl_time
  , status
FROM
    dba_objects
WHERE
      owner       = UPPER('&sch')
  AND object_name = UPPER('&tab')
  AND object_type = 'TABLE'
/

PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | SEGMENT INFORMATION                                                        |
PROMPT +----------------------------------------------------------------------------+

COLUMN segment_type                                  HEADING "Segment Type"
COLUMN bytes               FORMAT 9,999,999,999,999  HEADING "Bytes"
COLUMN extents             FORMAT 999,999,999        HEADING "Extents"
COLUMN initial_extent      FORMAT 999,999,999,999    HEADING "Initial|Extent"
COLUMN next_extent         FORMAT 999,999,999,999    HEADING "Next|Extent"
COLUMN min_extents         FORMAT 999                HEADING "Min|Extents"
COLUMN max_extents         FORMAT 9,999,999,999      HEADING "Max|Extents"
COLUMN pct_increase        FORMAT 999.00             HEADING "Pct|Increase"
COLUMN freelists                                     HEADING "Free|Lists"
COLUMN freelist_groups                               HEADING "Free|List Groups"

SELECT 
    segment_type     segment_type
  , bytes/1024/1024  Mbytes
  , extents          extents
  , initial_extent   initial_extent
  , next_extent      next_extent
  , min_extents      min_extents
  , max_extents      max_extents
  , pct_increase     pct_increase
  , freelists        freelists
  , freelist_groups  freelist_groups
FROM
    dba_segments
WHERE
      owner        = UPPER('&sch')
  AND segment_name = UPPER('&tab')
/


PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | COLUMNS                                                                    |
PROMPT +----------------------------------------------------------------------------+

COLUMN column_name         FORMAT A20                HEADING "Column Name"
COLUMN data_type           FORMAT A25                HEADING "Data Type"
COLUMN nullable            FORMAT A13                HEADing "Null?"

SELECT
    column_name
  , DECODE(nullable, 'Y', ' ', 'NOT NULL') nullable
  , DECODE(data_type
               , 'RAW',      data_type || '(' ||  data_length || ')'
               , 'CHAR',     data_type || '(' ||  data_length || ')'
               , 'VARCHAR',  data_type || '(' ||  data_length || ')'
               , 'VARCHAR2', data_type || '(' ||  data_length || ')'
               , 'NUMBER', NVL2(   data_precision
                                 , DECODE(    data_scale
                                            , 0
                                            , data_type || '(' || data_precision || ')'
                                            , data_type || '(' || data_precision || ',' || data_scale || ')'
                                   )
                                 , data_type)
               , data_type
    ) data_type
FROM
    dba_tab_columns
WHERE
      owner      = UPPER('&sch')
  AND table_name = UPPER('&tab')
ORDER BY
    column_id
/


PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | INDEXES                                                                    |
PROMPT +----------------------------------------------------------------------------+

COLUMN index_name          FORMAT A40                HEADING "Index Name"
COLUMN column_name         FORMAT A30                HEADING "Column Name"
COLUMN column_length                                 HEADING "Column Length"

BREAK ON index_name SKIP 1

SELECT 
    index_owner || '.' || index_name  index_name
  , column_name
  , column_length
FROM
    dba_ind_columns
WHERE
      table_owner  = UPPER('&sch')
  AND table_name   = UPPER('&tab')
ORDER BY
    index_name
  , column_position
/


PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | CONSTRAINTS                                                                |
PROMPT | UNCOMMENT THIS SECTION FROM THE SCRIPT TO GET THE INFO ABOUT CONST         |
PROMPT +----------------------------------------------------------------------------+
PROMPT
/*
COLUMN constraint_name     FORMAT A18                HEADING "Constraint Name"
COLUMN constraint_type     FORMAT A11                HEADING "Constraint|Type"
COLUMN search_condition    FORMAT A15                HEADING "Search Condition"
COLUMN r_constraint_name   FORMAT A20                HEADING "R / Constraint Name"
COLUMN delete_rule         FORMAT A11                HEADING "Delete Rule"
COLUMN status                                        HEADING "Status"

BREAK ON constraint_name ON constraint_type

SELECT 
    a.constraint_name
  , DECODE(a.constraint_type
             , 'P', 'Primary Key'
             , 'C', 'Check'
             , 'R', 'Referential'
             , 'V', 'View Check'
             , 'U', 'Unique'
             , a.constraint_type
    ) constraint_type
  , b.column_name
  , a.search_condition
  , NVL2(a.r_owner, a.r_owner || '.' ||  a.r_constraint_name, null) r_constraint_name
  , a.delete_rule
  , a.status
FROM 
    dba_constraints  a
  , dba_cons_columns b
WHERE
      a.owner            = UPPER('&sch')
  AND a.table_name       = UPPER('&tab')
  AND a.constraint_name  = b.constraint_name
  AND b.owner            = UPPER('&sch')
  AND b.table_name       = UPPER('&tab')
ORDER BY
    a.constraint_name
  , b.position
/

*/

PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | PARTITIONS (TABLE)                                                         |
PROMPT +----------------------------------------------------------------------------+

COLUMN partition_name                                HEADING "Partition Name"
COLUMN column_name         FORMAT A20                HEADING "Column Name"
COLUMN tablespace_name     FORMAT A28                HEADING "Tablespace"
COLUMN composite           FORMAT A9                 HEADING "Composite"
COLUMN subpartition_count                            HEADING "Sub. Part.|Count"
COLUMN logging             FORMAT A7                 HEADING "Logging"
COLUMN high_value          FORMAT A13                HEADING "High Value" TRUNC

BREAK ON partition_name

SELECT
    a.partition_name
  , b.column_name
  , a.tablespace_name
  , a.composite
  , a.subpartition_count
  , a.logging
FROM 
    dba_tab_partitions    a
  , dba_part_key_columns  b
WHERE
      a.table_owner        = UPPER('&sch')
  AND a.table_name         = UPPER('&tab')
  AND RTRIM(b.object_type) = 'TABLE'
  AND b.owner              = a.table_owner
  AND b.name               = a.table_name
ORDER BY
    a.partition_position
  , b.column_position
/


PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | PARTITIONS (INDEX)                                                         |
PROMPT +----------------------------------------------------------------------------+

COLUMN index_name              FORMAT A25                HEADING "Index Name"
COLUMN partitioning_type       FORMAT A9                 HEADING "Type"
COLUMN partition_count         FORMAT 99999              HEADING "Part.|Count"
COLUMN partitioning_key_count  FORMAT 99999              HEADING "Part.|Key Count"
COLUMN locality                FORMAT A8                 HEADING "Locality"
COLUMN alignment               FORMAT A12                HEADING "Alignment"

SELECT
    a.owner || '.' || a.index_name   index_name
  , b.column_name
  , a.partitioning_type
  , a.partition_count
  , a.partitioning_key_count
  , a.locality
  , a.alignment
FROM 
    dba_part_indexes      a
  , dba_part_key_columns  b
WHERE
      a.owner              = UPPER('&sch')
  AND a.table_name         = UPPER('&tab')
  AND RTRIM(b.object_type) = 'INDEX'
  AND b.owner              = a.owner
  AND b.name               = a.index_name
ORDER BY
    a.index_name
  , b.column_position
/



PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | TRIGGERS                                                                   |
PROMPT +----------------------------------------------------------------------------+

COLUMN trigger_name            FORMAT A25                HEADING "Trigger Name"
COLUMN trigger_type            FORMAT A18                HEADING "Type"
COLUMN triggering_event        FORMAT A9                 HEADING "Trig.|Event"
COLUMN referencing_names       FORMAT A65                HEADING "Referencing Names" newline
COLUMN when_clause             FORMAT A65                HEADING "When Clause" newline
COLUMN trigger_body            FORMAT A65                HEADING "Trigger Body" newline

SELECT
    owner || '.' || trigger_name  trigger_name
  , trigger_type
  , triggering_event
  , status
  , referencing_names
  , when_clause
  , trigger_body
FROM
    dba_triggers
WHERE
      table_owner = UPPER('&sch')
  AND table_name  = UPPER('&tab')
ORDER BY
     trigger_name
/


SET PAGESIZE 9999
SET VERIFY   OFF
SET FEEDBACK ON
