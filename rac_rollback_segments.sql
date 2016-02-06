-- | PURPOSE  : Reports rollback statistic information including name, shrinks, |
-- |            wraps, size and optimal size. This script is RAC enabled.       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET PAGESIZE 9999

COLUMN instance_name  FORMAT a8               HEADING 'Instance'
COLUMN roll_name      FORMAT a18              HEADING 'Rollback Name'
COLUMN tablespace     FORMAT a11              HEADING 'Tablspace'
COLUMN in_extents     FORMAT a20              HEADING 'Init/Next Extents'
COLUMN m_extents      FORMAT a10              HEADING 'Min/Max Extents'
COLUMN status         FORMAT a8               HEADING 'Status'
COLUMN wraps          FORMAT 999              HEADING 'Wraps' 
COLUMN shrinks        FORMAT 999              HEADING 'Shrinks'
COLUMN opt            FORMAT 999,999,999,999  HEADING 'Opt. Size'
COLUMN bytes          FORMAT 999,999,999,999  HEADING 'Bytes'
COLUMN extents        FORMAT 999              HEADING 'Extents'

BREAK ON instance_name SKIP 2
COMPUTE SUM label 'Total: ' OF bytes ON instance_name

SELECT
    i.instance_name                           instance_name
  , a.owner || '.' || a.segment_name          roll_name
  , a.tablespace_name                         tablespace
  , TO_CHAR(a.initial_extent) || ' / ' ||
    TO_CHAR(a.next_extent)                    in_extents
  , TO_CHAR(a.min_extents)    || ' / ' ||
    TO_CHAR(a.max_extents)                    m_extents
  , a.status                                  status
  , b.bytes                                   bytes
  , b.extents                                 extents
  , d.shrinks                                 shrinks
  , d.wraps                                   wraps
  , d.optsize                                 opt
FROM
                gv$instance       i
    INNER JOIN  gv$rollstat       d   ON (i.inst_id      = d.inst_id)
    INNER JOIN  sys.undo$         c   ON (d.usn          = c.us#)
    INNER JOIN  dba_rollback_segs a   ON (a.segment_name = c.name)
    INNER JOIN  dba_segments      b   ON (a.segment_name = b.segment_name)
ORDER BY instance_name, a.segment_name
/
