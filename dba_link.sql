COLUMN owner        FORMAT a15    HEADING 'Owner'          
COLUMN db_link      FORMAT a25    HEADING 'DB Link Name'    
COLUMN username     format a15    HEADING 'Username'       
COLUMN host         format a130 trunc HEADING 'Host'            
COLUMN created      FORMAT a20    HEADING 'Created'         

SELECT
     owner   owner
  , db_link
  , username
  , TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS')  created
  , host 
FROM dba_db_links
ORDER BY owner, db_link;