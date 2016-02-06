COLUMN owner                                         HEADING 'Owner'            ENTMAP off
COLUMN tablespace_name                               HEADING 'Tablespace Name'  ENTMAP off
COLUMN segment_name                                  HEADING 'Segment Name'     ENTMAP off
COLUMN segment_type                                  HEADING 'Segment Type'     ENTMAP off
COLUMN next_extent       FORMAT 999,999,999,999,999  HEADING 'Next Extent'      ENTMAP off
COLUMN max               FORMAT 999,999,999,999,999  HEADING 'Max. Piece Size'  ENTMAP off
COLUMN sum               FORMAT 999,999,999,999,999  HEADING 'Sum of Bytes'     ENTMAP off
COLUMN extents           FORMAT 999,999,999,999,999  HEADING 'Num. of Extents'  ENTMAP off
COLUMN max_extents       FORMAT 999,999,999,999,999  HEADING 'Max Extents'      ENTMAP off

prompt Segments that cannot extend because of MAXEXTENTS or not enough space
SELECT
    ds.owner              owner
  , ds.tablespace_name    tablespace_name
  , ds.segment_name       segment_name
  , ds.segment_type       segment_type
  , ds.next_extent        next_extent
  , NVL(dfs.max, 0)       max
  , NVL(dfs.sum, 0)       sum
  , ds.extents            extents
  , ds.max_extents        max_extents
FROM 
    dba_segments ds
  , (select
         max(bytes) max
       , sum(bytes) sum
       , tablespace_name
     from
         dba_free_space 
     group by
         tablespace_name
    ) dfs
WHERE
      (ds.next_extent > nvl(dfs.max, 0)
       OR
       ds.extents >= ds.max_extents)
  AND ds.tablespace_name = dfs.tablespace_name (+)
  AND ds.owner NOT IN ('SYS','SYSTEM')
ORDER BY
    ds.owner
  , ds.tablespace_name
  , ds.segment_name;