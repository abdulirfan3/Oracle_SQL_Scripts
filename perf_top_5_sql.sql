SELECT 'Physical i/o' type,
       ROUND (100 * NVL (top_disk_read / sum_disk_reads, 0), 2) perct, hash_value,
       sql_id
  FROM (SELECT   disk_reads top_disk_read, hash_value, sql_id
            FROM v$sqlarea
           WHERE disk_reads > 0
        ORDER BY 1 DESC),
       (SELECT SUM (disk_reads) sum_disk_reads
          FROM v$sqlarea
         WHERE disk_reads > 0)
 WHERE ROWNUM < 6
UNION ALL
SELECT 'Logical i/o', ROUND (100 * NVL (top_buff_get / sum_buff_gets, 0), 2) perct,
       hash_value, sql_id
  FROM (SELECT   buffer_gets top_buff_get, hash_value, sql_id
            FROM v$sqlarea
           WHERE buffer_gets > 0
        ORDER BY 1 DESC),
       (SELECT SUM (buffer_gets) sum_buff_gets
          FROM v$sqlarea
         WHERE buffer_gets > 0)
 WHERE ROWNUM < 6
UNION ALL
SELECT 'CPU Time', ROUND (100 * NVL (top_cpu / sum_cpu, 0), 2) perct, hash_value,
       sql_id
  FROM (SELECT   cpu_time top_cpu, hash_value, sql_id
            FROM v$sqlarea
           WHERE cpu_time > 0
        ORDER BY 1 DESC),
       (SELECT SUM (cpu_time) sum_cpu
          FROM v$sqlarea
         WHERE cpu_time > 0)
 WHERE ROWNUM < 6
UNION ALL
SELECT 'Elapsed Time',
       ROUND (100 * NVL (top_elap_time / sum_elap_time, 0), 2) perct, hash_value,
       sql_id
  FROM (SELECT   elapsed_time top_elap_time, hash_value, sql_id
            FROM v$sqlarea
           WHERE elapsed_time > 0
        ORDER BY 1 DESC),
       (SELECT SUM (elapsed_time) sum_elap_time
          FROM v$sqlarea
         WHERE elapsed_time > 0)
 WHERE ROWNUM < 6;
 
