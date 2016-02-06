COLUMN sql_text FORMAT a120 word_wrap
SELECT sq.hash_value, sq.child_number, v.SID,
       v.status, v.last_call_et, sq.sql_text
  FROM v$sql sq, v$session v
 WHERE sq.hash_value = v.sql_hash_value 
   AND v.sid = '&SID';
   -- AND sq.hash_value = '&hash_value';