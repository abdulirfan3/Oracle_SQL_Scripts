-- | PURPOSE  : Provide a summary report of all files (and file metadata)       |
-- |            information for all ASM disk groups customized for Oracle 10g.  |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE  9999
SET VERIFY    off

COLUMN full_alias_path        FORMAT a63                  HEAD 'File Name'
COLUMN system_created         FORMAT a8                   HEAD 'System|Created?'
COLUMN bytes                  FORMAT 9,999,999,999,999    HEAD 'Bytes'
COLUMN space                  FORMAT 9,999,999,999,999    HEAD 'Space'
COLUMN type                   FORMAT a18                  HEAD 'File Type'
COLUMN redundancy             FORMAT a12                  HEAD 'Redundancy'
COLUMN striped                FORMAT a8                   HEAD 'Striped'
COLUMN creation_date          FORMAT a20                  HEAD 'Creation Date'
COLUMN disk_group_name        noprint

BREAK ON report ON disk_group_name SKIP 1

compute sum label ""              of bytes space on disk_group_name
compute sum label "Grand Total: " of bytes space on report

SELECT
    CONCAT('+' || disk_group_name, SYS_CONNECT_BY_PATH(alias_name, '/')) full_alias_path
  , bytes
  , space
  , NVL(LPAD(type, 18), '<DIRECTORY>')  type
  , creation_date
  , disk_group_name
  , LPAD(system_created, 4) system_created
FROM
    ( SELECT
          g.name               disk_group_name
        , a.parent_index       pindex
        , a.name               alias_name
        , a.reference_index    rindex
        , a.system_created     system_created
        , f.bytes              bytes
        , f.space              space
        , f.type               type
        , TO_CHAR(f.creation_date, 'DD-MON-YYYY HH24:MI:SS')  creation_date
      FROM
          v$asm_file f RIGHT OUTER JOIN v$asm_alias     a USING (group_number, file_number)
                                   JOIN v$asm_diskgroup g USING (group_number)
    )
WHERE type IS NOT NULL
START WITH (MOD(pindex, POWER(2, 24))) = 0
    CONNECT BY PRIOR rindex = pindex
/
