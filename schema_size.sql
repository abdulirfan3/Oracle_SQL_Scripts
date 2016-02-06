ACCEPT owner prompt 'Enter owner name or hit enter to search all user : '
Prompt
prompt +------------------------------------+
prompt |   Size of MB/GB are rounded to 2   |
Prompt +------------------------------------+

select owner, 
       round(sum(bytes/1024/1024),2)MB
,      round(sum(bytes/1024/1024/1024),2)GB
from dba_segments 
Where 
owner like upper(nvl('%&owner%',owner))
group by owner;