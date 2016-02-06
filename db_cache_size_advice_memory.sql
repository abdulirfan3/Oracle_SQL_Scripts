COLUMN name format a7
COLUMN block_size format 99,999 heading "Block|Size"
COLUMN size_for_estimate format 999,999,999,999 heading "Size|For|Estimate"
COLUMN size_factor format 99.99 heading "Size|Factor"
COLUMN estd_physical_reads format 999,999,999,999,999 heading "Estimated|Physical|Reads|(Smaller|is Better)"
COLUMN estd_physical_read_factor format 99.99 heading "Estimated|Physical|Read|Factor|(Smaller|is Better)"

SELECT   NAME, block_size, size_for_estimate, size_factor,
         estd_physical_reads, estd_physical_read_factor,
         estd_physical_read_time
    FROM v$db_cache_advice
   WHERE NAME = 'DEFAULT'
ORDER BY size_for_estimate;