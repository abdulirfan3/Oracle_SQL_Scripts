-- | PURPOSE  : Query information information about the control file record     |
-- |            sections.                                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999

COLUMN type           FORMAT           A20   HEADING "Record Section Type"
COLUMN record_size    FORMAT       999,999   HEADING "Record Size|(in bytes)"
COLUMN records_total  FORMAT       999,999   HEADING "Records Allocated"
COLUMN bytes_alloc    FORMAT   999,999,999   HEADING "Bytes Allocated"
COLUMN records_used   FORMAT       999,999   HEADING "Records Used"
COLUMN bytes_used     FORMAT   999,999,999   HEADING "Bytes Used"
COLUMN pct_used       FORMAT           B999  HEADING "% Used"
COLUMN first_index                           HEADING "First Index"
COLUMN last_index                            HEADING "Last Index"
COLUMN last_recid                            HEADING "Last RecID"

break on report
compute sum of records_total on report
compute sum of bytes_alloc   on report
compute sum of records_used  on report
compute sum of bytes_used    on report
compute avg of pct_used      on report

SELECT
    type
  , record_size
  , records_total
  , (records_total * record_size) bytes_alloc
  , records_used
  , (records_used * record_size) bytes_used
  , NVL(records_used/records_total * 100, 0) pct_used
  , first_index
  , last_index
  , last_recid
FROM v$controlfile_record_section
ORDER BY type
/

