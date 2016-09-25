-- Check how far we could flashback to
col oldest_flashback_scn for 99999999999999999999
col oldest_flashback_time for a30
select
oldest_flashback_scn,
to_char(oldest_flashback_time, 'DD-MM-YYYY HH24:MI:SS')
from v$flashback_database_log;