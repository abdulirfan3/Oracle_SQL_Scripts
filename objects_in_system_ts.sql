set lines 500
prompt
prompt +----------------------------------------------------------------------------+
prompt |          - USERS WITH DEFAULT TABLESPACE - (SYSTEM) -                      |
prompt +----------------------------------------------------------------------------+    
prompt
COLUMN username                 FORMAT a15    HEADING 'Username'                ENTMAP off
COLUMN default_tablespace       FORMAT a15   HEADING 'Default Tablespace'      ENTMAP off
COLUMN temporary_tablespace     FORMAT a15   HEADING 'Temporary Tablespace'    ENTMAP off
COLUMN created                  FORMAT a25    HEADING 'Created'                 ENTMAP off
COLUMN account_status           FORMAT a20    HEADING 'Account Status'          ENTMAP off

SELECT
    username              username
  , default_tablespace                 default_tablespace
  ,  temporary_tablespace             temporary_tablespace
  , TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS')   created
  , DECODE(   account_status
            , 'OPEN'
            ,  account_status 
            ,  account_status ) account_status
FROM
    dba_users
WHERE
    default_tablespace = 'SYSTEM'
ORDER BY
    username;

prompt
prompt +----------------------------------------------------------------------------+
prompt |          - Users With Default Temporary Tablespace - (SYSTEM) -            |
prompt +----------------------------------------------------------------------------+    
prompt
COLUMN username                 FORMAT a15    HEADING 'Username'                ENTMAP off
COLUMN default_tablespace       FORMAT a15   HEADING 'Default Tablespace'      ENTMAP off
COLUMN temporary_tablespace     FORMAT a15   HEADING 'Temporary Tablespace'    ENTMAP off
COLUMN created                  FORMAT a25    HEADING 'Created'                 ENTMAP off
COLUMN account_status           FORMAT a20    HEADING 'Account Status'          ENTMAP off

SELECT
    username              username
  , default_tablespace                 default_tablespace
  ,  temporary_tablespace             temporary_tablespace
  , TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS')   created
  , DECODE(   account_status
            , 'OPEN'
            ,  account_status 
            ,  account_status ) account_status
FROM
    dba_users
WHERE
    temporary_tablespace = 'SYSTEM'
ORDER BY
    username;
    
    
   
prompt
prompt +----------------------------------------------------------------------------+
prompt |          - OBJECTS IN THE SYSTEM TABLESPACE -                              |
prompt +----------------------------------------------------------------------------+    
prompt
COLUMN owner               FORMAT a15                   HEADING 'Owner'           ENTMAP off
COLUMN segment_name        FORMAT a25                  HEADING 'Segment Name'    ENTMAP off
COLUMN segment_type        FORMAT a15                   HEADING 'Type'            ENTMAP off
COLUMN tablespace_name     FORMAT a15                  HEADING 'Tablespace'      ENTMAP off
COLUMN bytes               FORMAT 999,999,999,999,999   HEADING 'Bytes|Alloc'     ENTMAP off
COLUMN extents             FORMAT 999,999,999,999,999   HEADING 'Extents'         ENTMAP off
COLUMN max_extents         FORMAT 999,999,999,999,999   HEADING 'Max|Ext'         ENTMAP off
COLUMN initial_extent      FORMAT 999,999,999,999,999   HEADING 'Initial|Ext'     ENTMAP off
COLUMN next_extent         FORMAT 999,999,999,999,999   HEADING 'Next|Ext'        ENTMAP off
COLUMN pct_increase        FORMAT 999,999,999,999,999   HEADING 'Pct|Inc'         ENTMAP off

BREAK ON report

SELECT
    owner
  , segment_name
  , segment_type
  , tablespace_name
  , bytes
  , extents
  , initial_extent
  , next_extent
  , pct_increase
FROM
    dba_segments
WHERE
      owner NOT IN ('SYS','SYSTEM')
  AND tablespace_name = 'SYSTEM'
ORDER BY
    owner
  , segment_name
  , extents DESC;        