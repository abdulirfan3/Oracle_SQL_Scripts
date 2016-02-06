-- | PURPOSE  : Provide a summary report of all files (and file metadata)       |
-- |            information for all ASM disk groups.                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE  9999
SET VERIFY    off

COLUMN disk_group_name        FORMAT a20                  HEAD 'Disk Group Name'
COLUMN file_name              FORMAT a30                  HEAD 'File Name'
COLUMN bytes                  FORMAT 9,999,999,999,999    HEAD 'Bytes'
COLUMN space                  FORMAT 9,999,999,999,999    HEAD 'Space'
COLUMN type                   FORMAT a18                  HEAD 'File Type'
COLUMN redundancy             FORMAT a12                  HEAD 'Redundancy'
COLUMN striped                FORMAT a8                   HEAD 'Striped'
COLUMN creation_date          FORMAT a20                  HEAD 'Creation Date'

break on report on disk_group_name skip 1
compute sum label ""              of bytes space on disk_group_name
compute sum label "Grand Total: " of bytes space on report

SELECT
    g.name               disk_group_name
  , a.name               file_name
  , f.bytes              bytes
  , f.space              space
  , f.type               type
  , TO_CHAR(f.creation_date, 'DD-MON-YYYY HH24:MI:SS')  creation_date
FROM
    v$asm_file f JOIN v$asm_alias     a USING (group_number, file_number)
                 JOIN v$asm_diskgroup g USING (group_number)
WHERE
    system_created = 'Y'
ORDER BY
    g.name
  , file_number
/


