col datafile_name format a60 word_wrap
prompt GIVE ONE TABLESPACE NAME OR HIT ENTER FOR ALL TABLESAPCE
prompt Also, give file name like, eg.. /oracle/sapdata, sr3, ..
SELECT   t.tablespace_name "Tablespace", 'Datafile' "File Type",
         t.status "Tablespace Status", d.status "File Status",
         ROUND ((d.max_bytes - NVL (f.sum_bytes, 0)) / 1024 / 1024) "Used MB",
         ROUND (NVL (f.sum_bytes, 0) / 1024 / 1024) "Free MB",
         (d.bytes/1024/1024) file_mb,
         (d.maxbytes/1024/1024) MaxMB,
       --  t.initial_extent "Initial Extent", t.next_extent "Next Extent",
       --  t.min_extents "Min Extents", t.max_extents "Max Extents",
        -- t.pct_increase "Pct Increase",
         d.file_name "Datafile_name",
         d.file_id,
		 d.autoextensible
    FROM (SELECT   tablespace_name, file_id, SUM (BYTES) sum_bytes
              FROM dba_free_space
          GROUP BY tablespace_name, file_id) f,
         (SELECT   tablespace_name, file_name, file_id, MAX (BYTES) max_bytes, bytes, maxbytes,
                   status, autoextensible
              FROM dba_data_files
          GROUP BY tablespace_name, file_name, file_id, bytes, maxbytes, status, autoextensible) d,
         dba_tablespaces t
   WHERE t.tablespace_name = d.tablespace_name
     AND f.tablespace_name(+) = d.tablespace_name
     AND f.file_id(+) = d.file_id
     AND t.tablespace_name like upper(nvl('%&tbsp_name%',t.tablespace_name))
     AND d.file_name like nvl('%&file_name%',d.file_name)
	 order by 1;