-- | PURPOSE  : Provide a summary report of all clients making use of this ASM  |
-- |            instance.                                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE  9999
SET VERIFY    off

COLUMN disk_group_name        FORMAT a20           HEAD 'Disk Group Name'
COLUMN instance_name          FORMAT a20           HEAD 'Instance Name'
COLUMN db_name                FORMAT a9            HEAD 'Database Name'
COLUMN status                 FORMAT a12           HEAD 'Status'

break on report on disk_group_name skip 1

SELECT
    a.name              disk_group_name
  , c.instance_name     instance_name
  , c.db_name           db_name
  , c.status            status
FROM
    v$asm_diskgroup a JOIN v$asm_client c USING (group_number)
ORDER BY
    a.name;


