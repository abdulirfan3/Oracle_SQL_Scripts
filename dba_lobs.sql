SELECT TABLE_NAME, owner, segment_name, tablespace_name
FROM   dba_lobs
WHERE  segment_name = '&Segment_name';