-- | PURPOSE  : Provide a summary report of all template information for all    |
-- |            ASM disk groups.                                                |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE  9999
SET VERIFY    off

COLUMN disk_group_name        FORMAT a20           HEAD 'Disk Group Name'
COLUMN entry_number           FORMAT 999           HEAD 'Entry Number'
COLUMN redundancy             FORMAT a12           HEAD 'Redundancy'
COLUMN stripe                 FORMAT a8            HEAD 'Stripe'
COLUMN system                 FORMAT a6            HEAD 'System'
COLUMN template_name          FORMAT a30           HEAD 'Template Name'

break on report on disk_group_name skip 1

SELECT
    b.name                                           disk_group_name
  , a.entry_number                                   entry_number
  , a.redundancy                                     redundancy
  , a.stripe                                         stripe
  , a.system                                         system
  , a.name                                           template_name
FROM
    v$asm_template a JOIN v$asm_diskgroup b USING (group_number)
ORDER BY
    b.name
  , a.entry_number
/

