-- | PURPOSE  : Provide a summary report of all disks contained within all ASM  |
-- |           disk groups along with their performance metrics.                |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE  9999
SET VERIFY    off

COLUMN disk_group_name    FORMAT a20               HEAD 'Disk Group Name'
COLUMN disk_path          FORMAT a20               HEAD 'Disk Path'
COLUMN reads              FORMAT 999,999,999       HEAD 'Reads'
COLUMN writes             FORMAT 999,999,999       HEAD 'Writes'
COLUMN read_errs          FORMAT 999,999           HEAD 'Read|Errors'
COLUMN write_errs         FORMAT 999,999           HEAD 'Write|Errors'
COLUMN read_time          FORMAT 999,999,999       HEAD 'Read|Time'
COLUMN write_time         FORMAT 999,999,999       HEAD 'Write|Time'
COLUMN bytes_read         FORMAT 999,999,999,999   HEAD 'Bytes|Read'
COLUMN bytes_written      FORMAT 999,999,999,999   HEAD 'Bytes|Written'

break on report on disk_group_name skip 2

compute sum label ""              of reads writes read_errs write_errs read_time write_time bytes_read bytes_written on disk_group_name
compute sum label "Grand Total: " of reads writes read_errs write_errs read_time write_time bytes_read bytes_written on report

SELECT
    a.name                disk_group_name
  , b.path                disk_path
  , b.reads               reads
  , b.writes              writes
  , b.read_errs           read_errs 
  , b.write_errs          write_errs
  , b.read_time           read_time
  , b.write_time          write_time
  , b.bytes_read          bytes_read
  , b.bytes_written       bytes_written
FROM
    v$asm_diskgroup a JOIN v$asm_disk b USING (group_number)
ORDER BY
    a.name
/


