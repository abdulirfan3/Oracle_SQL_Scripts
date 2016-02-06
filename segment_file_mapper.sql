SET PAGESIZE 9999
SET VER      off

COLUMN owner       FORMAT a15         HEADING "Owner"
COLUMN SEGMENT_NAME FORMAT A25
COLUMN bytes       FORMAT 999,999,999 HEADING "Bytes"
Prompt Give TBS name and associated file with TBS

SELECT
    SUBSTR(owner, 1, 20)  "Owner"
  , SUBSTR(segment_name, 1, 32) "Segment_name"
  , segment_type    "Segment_type"
  , HEADER_FILE      "File_id"
  , blocks
  , bytes/1024/1024  "Mbytes"
FROM
  dba_segments
WHERE
  tablespace_name = UPPER('&tbs') and
  HEADER_FILE = '&file_id'
ORDER BY 6
/