col last_refresh format a20
select	owner
,	mview_name
,	to_char(last_refresh_date, 'dd/mm/yy hh24:mi') last_refresh
from	dba_mviews
order by owner, last_refresh
;