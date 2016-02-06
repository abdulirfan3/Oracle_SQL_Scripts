-- | PURPOSE  : Provide a summary report of all alias definitions contained     |
-- |            within all ASM disk groups.                                     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET PAGESIZE  9999
SET VERIFY    off

COLUMN disk_group_name        FORMAT a20         HEAD 'Disk Group Name'
COLUMN alias_name             FORMAT a30         HEAD 'Alias Name'
COLUMN file_number                               HEAD 'File|Number'
COLUMN file_incarnation                          HEAD 'File|Incarnation'
COLUMN alias_index                               HEAD 'Alias|Index'
COLUMN alias_incarnation                         HEAD 'Alias|Incarnation'
COLUMN parent_index                              HEAD 'Parent|Index'
COLUMN reference_index                           HEAD 'Reference|Index'
COLUMN alias_directory        FORMAT a10         HEAD 'Alias|Directory?'
COLUMN system_created         FORMAT a8          HEAD 'System|Created?'

break on report on disk_group_name skip 1

SELECT
    g.name               disk_group_name
  , a.name               alias_name
  , a.file_number        file_number
  , a.file_incarnation   file_incarnation
  , a.alias_index        alias_index
  , a.alias_incarnation  alias_incarnation
  , a.parent_index       parent_index
  , a.reference_index    reference_index
  , a.alias_directory    alias_directory
  , a.system_created     system_created
FROM
    v$asm_alias a JOIN v$asm_diskgroup g USING (group_number)
ORDER BY
    g.name
  , a.file_number
/

