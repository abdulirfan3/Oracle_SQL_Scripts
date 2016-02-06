col OWNER for a20
col FILE# for 999
col BLOCK# for 99999
col BLOCKS for 99999
col start_block# for 99999
col end_block# for 99999
col CORRUPTION_CHANGE# for 999999999999
col SEGMENT_NAME for a25
col PARTITION_NAME for a25
col CORRUPTION_TYPE for a20

prompt
prompt +------------------------------------------------+
prompt | This will only get populated once a backup has |
prompt | ran or if you ran backup check logical - RMAN  |
prompt | pulls data from V$database_block_corruption    |
prompt +------------------------------------------------+
prompt
select instance_name from v$instance
;
select * from v$database_block_corruption order by 1,2,3,4
;

SELECT e.owner, e.segment_type, e.segment_name, e.partition_name, c.file#
       , greatest(e.block_id, c.block#) start_block#
       , least(e.block_id+e.blocks-1, c.block#+c.blocks-1) end_block#
       , least(e.block_id+e.blocks-1, c.block#+c.blocks-1)
       - greatest(e.block_id, c.block#) + 1 blk_corrupt
      , null description
FROM dba_extents e, v$database_block_corruption c
WHERE e.file_id = c.file#
AND e.block_id <= c.block# + c.blocks - 1 AND e.block_id + e.blocks - 1 >= c.block#
UNION
SELECT s.owner, s.segment_type, s.segment_name, s.partition_name, c.file#
       , header_block start_block#
       , header_block end_block#
       , 1 blk_corrupt
       , 'Segment Header' description
FROM dba_segments s, v$database_block_corruption c
WHERE s.header_file = c.file#
AND s.header_block between c.block# and c.block# + c.blocks - 1
UNION
SELECT null owner, null segment_type, null segment_name, null partition_name, c.file#
       , greatest(f.block_id, c.block#) start_block#
       , least(f.block_id+f.blocks-1, c.block#+c.blocks-1) end_block#
       , least(f.block_id+f.blocks-1, c.block#+c.blocks-1)
       - greatest(f.block_id, c.block#) + 1 blk_corrupt
       , 'Free Block' description
FROM dba_free_space f, v$database_block_corruption c
WHERE f.file_id = c.file#
AND f.block_id <= c.block# + c.blocks - 1 AND f.block_id + f.blocks - 1 >= c.block#
order by file#, start_block#
;