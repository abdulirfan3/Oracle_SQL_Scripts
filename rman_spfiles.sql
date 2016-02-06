-- | CLASS    : Recovery Manager                                                |
-- | PURPOSE  : Provide a listing of automatically backed up SPFILEs.           |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999

COLUMN bs_key                 FORMAT 9999     HEADING 'BS|Key'
COLUMN piece#                 FORMAT 99999    HEADING 'Piece|#'
COLUMN copy#                  FORMAT 9999     HEADING 'Copy|#'
COLUMN bp_key                 FORMAT 9999     HEADING 'BP|Key'
COLUMN spfile_included        FORMAT a11      HEADING 'SPFILE|Included?'
COLUMN completion_time        FORMAT a20      HEADING 'Completion|Time'
COLUMN status                 FORMAT a9       HEADING 'Status'
COLUMN handle                 FORMAT a65      HEADING 'Handle'

BREAK ON bs_key


prompt
prompt Available automatic SPFILE files within all available (and expired) backup sets.
prompt 

SELECT
    bs.recid                                               bs_key
  , bp.piece#                                              piece#
  , bp.copy#                                               copy#
  , bp.recid                                               bp_key
  , sp.spfile_included                                     spfile_included
  , TO_CHAR(bs.completion_time, 'DD-MON-YYYY HH24:MI:SS')  completion_time
  , DECODE(   status
            , 'A', 'Available'
            , 'D', 'Deleted'
            , 'X', 'Expired')                              status
  , handle                                                 handle
FROM
    v$backup_set                                           bs
  , v$backup_piece                                         bp
  ,  (select distinct
          set_stamp
        , set_count
        , 'YES'     spfile_included
      from v$backup_spfile)                                sp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
  AND bs.set_stamp = sp.set_stamp
  AND bs.set_count = sp.set_count
ORDER BY
    bs.recid
  , piece#
/
