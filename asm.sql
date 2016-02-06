--test
  REM ASM views:
REM VIEW            |ASM INSTANCE                                     |DB INSTANCE
REM ----------------------------------------------------------------------------------------------------------
REM V$ASM_DISKGROUP |Describes a disk group (number, name, size       |Contains one row for every open ASM
REM                 |related info, state, and redundancy type)        |disk in the DB instance.
REM V$ASM_CLIENT    |Identifies databases using disk groups           |Contains no rows.
REM                 |managed by the ASM instance.                     |
REM V$ASM_DISK      |Contains one row for every disk discovered       |Contains rows only for disks in the
REM                 |by the ASM instance, including disks that        |disk groups in use by that DB instance.
REM                 |are not part of any disk group.                  |
REM V$ASM_FILE      |Contains one row for every ASM file in every     |Contains rows only for files that are
REM                 |disk group mounted by the ASM instance.          |currently open in the DB instance.
REM V$ASM_TEMPLATE  |Contains one row for every template present in   |Contains no rows.
REM                 |every disk group mounted by the ASM instance.    |
REM V$ASM_ALIAS     |Contains one row for every alias present in      |Contains no rows.
REM                 |every disk group mounted by the ASM instance.    |
REM v$ASM_OPERATION |Contains one row for every active ASM long       |Contains no rows.
REM                 |running operation executing in the ASM instance. |

set wrap off
set lines 155 pages 9999
col "Group Name" for a6    Head "Group|Name"
col "Disk Name"  for a10
col "State"      for a10
col "Type"       for a10   Head "Diskgroup|Redundancy"
col "Total GB"   for 9,990 Head "Total|GB"
col "Free GB"    for 9,990 Head "Free|GB"
col "Imbalance"  for 99.9  Head "Percent|Imbalance"
col "Variance"   for 99.9  Head "Percent|Disk Size|Variance"
col "MinFree"    for 99.9  Head "Minimum|Percent|Free"
col "MaxFree"    for 99.9  Head "Maximum|Percent|Free"
col "DiskCnt"    for 9999  Head "Disk|Count"

prompt
prompt ASM Disk Groups
prompt ===============

SELECT g.group_number  "Group"
,      g.name          "Group Name"
,      g.state         "State"
,      g.type          "Type"
,      g.total_mb/1024 "Total GB"
,      g.free_mb/1024  "Free GB"
,      100*(max((d.total_mb-d.free_mb)/d.total_mb)-min((d.total_mb-d.free_mb)/d.total_mb))/max((d.total_mb-d.free_mb)/d.total_mb) "Imbalance"
,      100*(max(d.total_mb)-min(d.total_mb))/max(d.total_mb) "Variance"
,      100*(min(d.free_mb/d.total_mb)) "MinFree"
,      100*(max(d.free_mb/d.total_mb)) "MaxFree"
,      count(*)        "DiskCnt"
FROM v$asm_disk d, v$asm_diskgroup g
WHERE d.group_number = g.group_number and
d.group_number <> 0 and
d.state = 'NORMAL' and
d.mount_status = 'CACHED'
GROUP BY g.group_number, g.name, g.state, g.type, g.total_mb, g.free_mb
ORDER BY 1;

prompt ASM Disks In Use
prompt ================

col "Group"          for 999
col "Disk"           for 999
col "Header"         for a9
col "Mode"           for a8
col "State"          for a8
col "Created"        for a10          Head "Added To|Diskgroup"
--col "Redundancy"     for a10
--col "Failure Group"  for a10  Head "Failure|Group"
col "Path"           for a19
--col "ReadTime"       for 999999990    Head "Read Time|seconds"
--col "WriteTime"      for 999999990    Head "Write Time|seconds"
--col "BytesRead"      for 999990.00    Head "GigaBytes|Read"
--col "BytesWrite"     for 999990.00    Head "GigaBytes|Written"
col "SecsPerRead"    for 9.000        Head "Seconds|PerRead"
col "SecsPerWrite"   for 9.000        Head "Seconds|PerWrite"

select group_number  "Group"
,      disk_number   "Disk"
,      header_status "Header"
,      mode_status   "Mode"
,      state         "State"
,      create_date   "Created"
--,      redundancy    "Redundancy"
,      total_mb/1024 "Total GB"
,      free_mb/1024  "Free GB"
,      name          "Disk Name"
--,      failgroup     "Failure Group"
,      path          "Path"
--,      read_time     "ReadTime"
--,      write_time    "WriteTime"
--,      bytes_read/1073741824    "BytesRead"
--,      bytes_written/1073741824 "BytesWrite"
,      read_time/reads "SecsPerRead"
,      write_time/writes "SecsPerWrite"
from   v$asm_disk_stat
where header_status not in ('FORMER','CANDIDATE')
order by group_number
,        disk_number
/

Prompt File Types in Diskgroups
Prompt ========================
col "File Type"      for a16
col "Block Size"     for a5    Head "Block|Size"
col "Gb"             for 9990.00
col "Files"          for 99990
break on "Group Name" skip 1 nodup

select g.name                                   "Group Name"
,      f.TYPE                                   "File Type"
,      f.BLOCK_SIZE/1024||'k'                   "Block Size"
,      f.STRIPED
,        count(*)                               "Files"
,      round(sum(f.BYTES)/(1024*1024*1024),2)   "Gb"
from   v$asm_file f,v$asm_diskgroup g
where  f.group_number=g.group_number
group by g.name,f.TYPE,f.BLOCK_SIZE,f.STRIPED
order by 1,2;
clear break

prompt Instances currently accessing these diskgroups
prompt ==============================================
col "Instance" form a8
select c.group_number  "Group"
,      g.name          "Group Name"
,      c.instance_name "Instance"
from   v$asm_client c
,      v$asm_diskgroup g
where  g.group_number=c.group_number
/

prompt Free ASM disks and their paths
prompt ==============================
col "Disk Size"    form a9
select header_status                   "Header"
, mode_status                     "Mode"
, path                            "Path"
, lpad(round(os_mb/1024),7)||'Gb' "Disk Size"
from   v$asm_disk
where header_status in ('FORMER','CANDIDATE')
order by path
/

prompt Current ASM disk operations
prompt ===========================
select *
from   v$asm_operation
/ 