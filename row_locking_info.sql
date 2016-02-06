@blocking_locks.sql

prompt
prompt
prompt Enter value for SID that is being blocked(not the blocker)
select row_wait_obj#,
       row_wait_file#,
       row_wait_block#,
       row_wait_row#
from v$session 
where sid = '&sid';

col OBJECT_NAME format a40
select owner, object_type, object_name, data_object_id
from dba_objects
where object_id = '&row_wait_obj';

prompt
prompt  Enter Values as following to find the exact row causing the locking issue
prompt
prompt  1. owner 
prompt  2. table name 
prompt  3. data_object_id
prompt  4. relative file ID 
prompt  5. block ID (ROW_WAIT_BLOCK)
prompt  6. row Number (ROW_WAIT_ROW)
prompt

select *
from &1..&2
where rowid =
        dbms_rowid.rowid_create (
                rowid_type      =>  1, 
                object_number   => &3,
                relative_fno    => &4,
                block_number    => &5,
                row_number      => &6
        )
/

/*
-- dose the same thing as above but only needs SID and calculates the rowid
select
    owner||'.'||object_name||':'||nvl(subobject_name,'-') obj_name,
    dbms_rowid.rowid_create (
        1,
        o.data_object_id,
        row_wait_file#,
        row_wait_block#,
        row_wait_row#
    ) row_id
from v$session s, dba_objects o
where sid = &sid
   and o.data_object_id = s.row_wait_obj#;
   */
