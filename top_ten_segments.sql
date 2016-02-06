col	owner format a15
col	segment_name format a30
col	segment_type format a15
select  owner
,	segment_name
,	segment_type
,	round(GB,2) GB
from	(
	select	owner
	,	segment_name
	,	segment_type
	,	bytes / 1024 / 1024/1024 "GB"
	from	dba_segments
	order	by bytes desc
	)
where	rownum < 11
;