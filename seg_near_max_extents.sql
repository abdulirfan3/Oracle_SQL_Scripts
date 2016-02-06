COLUMN owner                                          HEADING 'Owner'             ENTMAP off
COLUMN tablespace_name   FORMAT a30                   HEADING 'Tablespace name'   ENTMAP off
COLUMN segment_name      FORMAT a30                   HEADING 'Segment Name'      ENTMAP off
COLUMN segment_type      FORMAT a20                   HEADING 'Segment Type'      ENTMAP off
COLUMN bytes             FORMAT 999,999,999,999,999   HEADING 'Size (in bytes)'   ENTMAP off
COLUMN next_extent       FORMAT 999,999,999,999,999   HEADING 'Next Extent Size'  ENTMAP off
COLUMN pct_increase                                   HEADING '% Increase'        ENTMAP off
COLUMN extents           FORMAT 999,999,999,999,999   HEADING 'Num. of Extents'   ENTMAP off
COLUMN max_extents       FORMAT 999,999,999,999,999   HEADING 'Max Extents'       ENTMAP off
COLUMN pct_util          FORMAT 99.99                 HEADING '% Utilized'        ENTMAP off

SELECT 
    owner
  , tablespace_name
  , segment_name
  , segment_type
  , bytes
  , next_extent
  , pct_increase
  , extents
  , max_extents
  ,  ROUND((extents/max_extents)*100, 2)    pct_util
FROM
    dba_segments
WHERE
      extents > max_extents/2
  AND max_extents != 0
ORDER BY
    (extents/max_extents) DESC;