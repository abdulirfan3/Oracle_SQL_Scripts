COLUMN segment_name FORMAT A24
COLUMN segment_type FORMAT A24
 
SELECT *
   FROM   dba_extents
   WHERE
          file_id = &file_no
   AND
          ( &block_value BETWEEN block_id AND ( block_id + blocks ) )
/