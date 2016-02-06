-- | PURPOSE  : Provide a summary report of all dynamic components as part of   |
-- |            Oracle's ASMM configuration.                                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE  9999
SET VERIFY    off

COLUMN component             FORMAT a24              HEAD 'Component Name'
COLUMN current_size          FORMAT 9,999,999,999    HEAD 'Current Size'
COLUMN min_size              FORMAT 9,999,999,999    HEAD 'Min Size'
COLUMN max_size              FORMAT 9,999,999,999    HEAD 'Max Size'
COLUMN user_specified_size   FORMAT 9,999,999,999    HEAD 'User Specified|Size'
COLUMN oper_count            FORMAT 9,999            HEAD 'Oper.|Count'
COLUMN last_oper_type        FORMAT a10              HEAD 'Last Oper.|Type'
COLUMN last_oper_mode        FORMAT a10              HEAD 'Last Oper.|Mode'
COLUMN last_oper_time        FORMAT a20              HEAD 'Last Oper.|Time'
COLUMN granule_size          FORMAT 9,999,999        HEAD 'Granule Size'

SELECT
    component
  , current_size
  , min_size
  , max_size
  , user_specified_size
  , oper_count
  , last_oper_type
  , last_oper_mode
  , TO_CHAR(last_oper_time, 'DD-MON-YYYY HH24:MI:SS') last_oper_time
  , granule_size
FROM
    v$sga_dynamic_components
ORDER BY
    component DESC
/

