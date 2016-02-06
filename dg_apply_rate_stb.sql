select to_char(start_time, 'DD-MON-RR HH24:MI:SS') start_time,
item, round(sofar/1024,2) "MB/Sec"
from v$recovery_progress
where (item='Active Apply Rate' or item='Average Apply Rate');