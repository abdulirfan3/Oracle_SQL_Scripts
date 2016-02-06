-- | PURPOSE  : List all temporary tablespaces and details about the actual     |
-- |            sort segment. The statistics that come from the v$sort_segment  |
-- |            view depicts the true space within the temporary segment at     |
-- |            this current time.                                              |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN tablespace_name           FORMAT a14               HEAD 'Tablespace|Name'          JUST right
COLUMN temp_segment_name         FORMAT a8                HEAD 'Segment|Name'             JUST right
COLUMN current_users             FORMAT 9,999             HEAD 'Current|Users'            JUST right
COLUMN total_temp_segment_size   FORMAT 999,999,999,999   HEAD 'Total Temp|Segment Size'  JUST right
COLUMN currently_used_bytes      FORMAT 999,999,999,999   HEAD 'Currently|Used Bytes'     JUST right
COLUMN pct_used                  FORMAT 999               HEAD 'Pct.|Used'                JUST right
COLUMN extent_hits               FORMAT 999,999           HEAD 'Extent|Hits'              JUST right
COLUMN max_size                  FORMAT 999,999,999,999   HEAD 'Max|Size'                 JUST right
COLUMN max_used_size             FORMAT 999,999,999,999   HEAD 'Max Used|Size'            JUST right
COLUMN max_sort_size             FORMAT 999,999,999,999   HEAD 'Max Sort|Size'            JUST right
COLUMN free_requests             FORMAT 999               HEAD 'Free|Requests'            JUST right

prompt 
prompt +==================================================================================+
prompt | Segment Name            : The segment name is a concatenation of the             |
prompt |                           SEGMENT_FILE (File number of the first extent)         |
prompt |                           and the                                                |
prompt |                           SEGMENT_BLOCK (Block number of the first extent)       |  
prompt | Current Users           : Number of active users of the segment                  |
prompt | Total Temp Segment Size : Total size of the temporary segment in bytes           |
prompt | Currently Used Bytes    : Bytes allocated to active sorts                        |
prompt | Extent Hits             : Number of times an unused extent was found in the pool |
prompt | Max Size                : Maximum number of bytes ever used                      |
prompt | Max Used Size           : Maximum number of bytes used by all sorts              |
prompt | Max Sort Size           : Maximum number of bytes used by an individual sort     |
prompt | Free Requests           : Number of requests to deallocate                       |
prompt +==================================================================================+

BREAK ON tablespace_name ON report
COMPUTE SUM OF current_users            ON report
COMPUTE SUM OF total_temp_segment_size  ON report
COMPUTE SUM OF currently_used_bytes     ON report
COMPUTE SUM OF currently_free_bytes     ON report
COMPUTE SUM OF extent_hits              ON report
COMPUTE SUM OF max_size                 ON report
COMPUTE SUM OF max_used_size            ON report
COMPUTE SUM OF max_sort_size            ON report
COMPUTE SUM OF free_requests            ON report

SELECT 
    a.tablespace_name             tablespace_name
  , 'SYS.'          || 
    a.segment_file  ||
    '.'             || 
    a.segment_block               temp_segment_name
  , a.current_users               current_users
  , (a.total_blocks*b.value)      total_temp_segment_size
  , (a.used_blocks*b.value)       currently_used_bytes
  , TRUNC(ROUND((a.used_blocks/a.total_blocks)*100))    pct_used
  , a.extent_hits                 extent_hits
  , (a.max_blocks*b.value)        max_size
  , (a.max_used_blocks*b.value)   max_used_size
  , (a.max_sort_blocks *b.value)  max_sort_size
  , a.free_requests               free_requests
FROM
    v$sort_segment                  a
  , (select value from v$parameter
     where name = 'db_block_size')  b
/

