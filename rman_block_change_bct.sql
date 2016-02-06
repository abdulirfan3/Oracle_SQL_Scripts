col filename format a50
select status, bytes/1024/1024 "SIZE_MB", filename from v$block_change_tracking;

Prompt
prompt +---------------------------------------+
prompt | % read for backup where incremntal > 0|
Prompt +---------------------------------------+
prompt
select file#,
                   avg(datafile_blocks),
                    avg(blocks_read),
                    avg(blocks_read/datafile_blocks) * 100 as "% read for backup"
          from   v$backup_datafile
          where  incremental_level > 0
             and  used_change_tracking = 'YES'
          group  by file#
          order  by file#;


Prompt
prompt +------------------------------------+
prompt | Enter a datafile number to check if|
prompt |   BCTF was used and other info     |
Prompt +------------------------------------+
prompt
col bct_use format a10
select completion_time,file#, datafile_blocks, blocks_read, blocks blocked_backed, INCREMENTAL_LEVEL,
used_change_tracking "BCT_USE", blocks_read READ,  
round((blocks_read/datafile_blocks) * 100,2) "%READ",  
blocks WRTN, round((blocks/datafile_blocks)*100,2) "%WRTN"
from v$backup_datafile 
where file#='&file_numb' order by 1;

