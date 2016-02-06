 SELECT sysdate "TIME_STAMP", vsu.username, vs.sid, vp.spid, vs.sql_id, vst.sql_text, vsu.tablespace,
		 sum_blocks*dt.block_size/1024/1024 usage_mb
	 FROM
	 (
			 SELECT username, sqladdr, sqlhash, sql_id, tablespace, session_addr,
  -- sum(blocks)*8192/1024/1024 "USAGE_MB",
				  sum(blocks) sum_blocks
			 FROM v$sort_usage
			-- HAVING SUM(blocks)> 1000
			 GROUP BY username, sqladdr, sqlhash, sql_id, tablespace, session_addr
	 ) "VSU",
	 v$sqltext vst,
	 v$session vs,
	 v$process vp,
	 dba_tablespaces dt
  WHERE vs.sql_id = vst.sql_id
  -- AND vsu.sqladdr = vst.address
  -- AND vsu.sqlhash = vst.hash_value
	 AND vsu.session_addr = vs.saddr
	 AND vs.paddr = vp.addr
	 AND vst.piece = 0
	 AND dt.tablespace_name = vsu.tablespace
 order by usage_mb;