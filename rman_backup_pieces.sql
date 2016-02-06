-- | PURPOSE  : Provide a listing of all RMAN Backup Pieces.                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999
set tab off

COLUMN bs_key              FORMAT 9999          HEADING 'BS|Key'
COLUMN piece#              FORMAT 99999         HEADING 'Piece|#'
COLUMN copy#               FORMAT 9999          HEADING 'Copy|#'
COLUMN bp_key              FORMAT 9999          HEADING 'BP|Key'
COLUMN status              FORMAT a9            HEADING 'Status'
COLUMN handle              FORMAT a85           HEADING 'Handle'
COLUMN start_time          FORMAT a17           HEADING 'Start|Time'
COLUMN completion_time     FORMAT a17           HEADING 'End|Time'
COLUMN elapsed_seconds     FORMAT 999,999       HEADING 'Elapsed|Seconds'
COLUMN deleted             FORMAT a8            HEADING 'Deleted?'

BREAK ON bs_key

prompt
prompt Available backup pieces contained in the control file.
prompt Includes available and expired backup sets.
prompt 

SELECT
    bs.recid                                            bs_key
  , bp.piece#                                           piece#
  , bp.copy#                                            copy#
  , bp.recid                                            bp_key
  , DECODE(   status
            , 'A', 'Available'
            , 'D', 'Deleted'
            , 'X', 'Expired')                           status
  , handle                                              handle
  , TO_CHAR(bp.start_time, 'mm/dd/yy HH24:MI:SS')       start_time
  , TO_CHAR(bp.completion_time, 'mm/dd/yy HH24:MI:SS')  completion_time
  , bp.elapsed_seconds                                  elapsed_seconds
FROM
    v$backup_set    bs
  , v$backup_piece  bp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
ORDER BY
    bs.recid
  , piece#
/

