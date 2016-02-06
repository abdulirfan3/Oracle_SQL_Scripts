-- | PURPOSE  : Provide a listing of automatically backed up control files.     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999

COLUMN bs_key                 FORMAT 9999     HEADING 'BS|Key'
COLUMN piece#                 FORMAT 99999    HEADING 'Piece|#'
COLUMN copy#                  FORMAT 9999     HEADING 'Copy|#'
COLUMN bp_key                 FORMAT 9999     HEADING 'BP|Key'
COLUMN controlfile_included   FORMAT a11      HEADING 'Controlfile|Included?'
COLUMN completion_time        FORMAT a20      HEADING 'Completion|Time'
COLUMN status                 FORMAT a9       HEADING 'Status'
COLUMN handle                 FORMAT a65      HEADING 'Handle'

BREAK ON bs_key


prompt
prompt Available automatic control files within all available (and expired) backup sets.
prompt 

SELECT
    bs.recid                                               bs_key
  , bp.piece#                                              piece#
  , bp.copy#                                               copy#
  , bp.recid                                               bp_key
  , DECODE(   bs.controlfile_included
            , 'NO', '-'
            , bs.controlfile_included)                     controlfile_included
  , TO_CHAR(bs.completion_time, 'DD-MON-YYYY HH24:MI:SS')  completion_time
  , DECODE(   status
            , 'A', 'Available'
            , 'D', 'Deleted'
            , 'X', 'Expired')                              status
  , handle                                                 handle
FROM
    v$backup_set    bs
  , v$backup_piece  bp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
  AND bs.controlfile_included != 'NO'
ORDER BY
    bs.recid
  , piece#
/
