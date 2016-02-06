-- | PURPOSE  : Provides a report on the top segments (in bytes) grouped by     |
-- |            Segment Type.                                                   |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET PAGESIZE 9999
SET VERIFY   OFF
SET TAB OFF
BREAK ON segment_type SKIP 2
COMPUTE SUM OF Mbytes ON segment_type

COLUMN segment_type        FORMAT A20                HEADING 'Segment Type'
COLUMN owner               FORMAT A15                HEADING 'Owner'
COLUMN segment_name        FORMAT A30                HEADING 'Segment Name'
COLUMN partition_name      FORMAT A30                HEADING 'Partition Name'
COLUMN tablespace_name     FORMAT A20                HEADING 'Tablespace Name'
--COLUMN Mbytes              FORMAT 9,999,999,999,999  HEADING 'Mbytes'
COLUMN extents             FORMAT 999,999,999        HEADING 'Extents'

SELECT
    a.segment_type      segment_type
  , a.owner             owner
  , a.segment_name      segment_name
--  , a.partition_name    partition_name
  , a.tablespace_name   tablespace_name
  , round(a.bytes/1024/1024)   Mbytes
  , a.extents           extents
FROM
    (select
         b.segment_type
       , b.owner
       , b.segment_name
--       , b.partition_name
       , b.tablespace_name
       , b.bytes
       , b.extents
     from
         dba_segments b
     order by
         b.bytes desc
    ) a
WHERE
    rownum < 101
ORDER BY
    segment_type, bytes desc, owner, segment_name
/
