SET PAGESIZE 9999
set lines 150
set wrap off;
COLUMN sql_text FORMAT a5000 word_wrap
SELECT sq.hash_value, sq.child_number, v.SID, v.sql_id,
       v.status, v.last_call_et, sq.sql_text
  FROM v$sql sq, v$session v
 WHERE sq.hash_value = v.sql_hash_value 
   AND v.SID = '&SID';

set lines 500;
   