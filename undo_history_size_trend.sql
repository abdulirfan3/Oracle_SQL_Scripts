set pages 30
select begin_time, end_time, (undoblks * (select value from v$parameter where name='db_block_size'))/1024/1024 undo_Mbytes from v$undostat order by begin_time;
set pages 9999;