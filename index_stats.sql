ACCEPT owner prompt 'Enter owner name : '
ACCEPT TABLE_NAME prompt 'Enter TABLE NAME : '

COLUMN owner                   format a8            heading "Owner"
COLUMN index_name              format a25           heading "Index"
COLUMN status                  format a7            heading "Status"
COLUMN blevel                  format 9999          heading " Tree| Level"
COLUMN leaf_blocks             format 999,999,999   heading " Leaf| Blk"
COLUMN distinct_keys           format 999,999,999   heading " # Keys"
COLUMN avg_leaf_blocks_per_key format 9999          heading " Avg| Leaf Blocks| Key"
COLUMN avg_data_blocks_per_key format 9999          heading " Avg| Data Blocks| Key"
COLUMN clustering_factor       format 999,999,999,999        heading " Cluster| Factor"
COLUMN num_rows                format 999,999,999,999   heading " Number| Rows"
COLUMN sample_size             format 999,999,999,999   heading " Sample| Size"
COLUMN last_analyzed                                heading " Analysis| Date"

SELECT   owner,TABLE_NAME, index_name, index_type, status, blevel, leaf_blocks, distinct_keys,
         avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor,
         num_rows, sample_size, last_analyzed
    FROM dba_indexes
   WHERE owner LIKE UPPER ('&owner')
     AND TABLE_NAME LIKE UPPER ('&TABLE_NAME')
     AND num_rows > 0
ORDER BY 1, 2;