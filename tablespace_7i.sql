 select  a.tablespace_name ts,
              a.file_id,
              sum(b.bytes)/count(*) bytes,
              sum(b.bytes)/count(*) - sum(a.bytes) used,
              sum(a.bytes) free,
              nvl(100-(sum(nvl(a.bytes,0))/(sum(nvl(b.bytes,0))/count(*)))*100,0) pct_used
      from    sys.dba_free_space a,
              sys.dba_data_files b
      where   a.tablespace_name = b.tablespace_name and
             a.file_id = b.file_id
     group   by a.tablespace_name, a.file_id
     /

	 --- with file name
	  select  a.tablespace_name ts,
              a.file_id,
			  b.FILE_NAME,
              sum(b.bytes)/count(*) bytes,
              sum(b.bytes)/count(*) - sum(a.bytes) used,
              sum(a.bytes) free,
              nvl(100-(sum(nvl(a.bytes,0))/(sum(nvl(b.bytes,0))/count(*)))*100,0) pct_used
      from    sys.dba_free_space a,
              sys.dba_data_files b
      where   a.tablespace_name = b.tablespace_name and
             a.file_id = b.file_id
     group   by a.tablespace_name, a.file_id, b.file_name
     ;