@@header

/*
*
*  Author     : Vishal Gupta
*  Purpose    : Display current session's details
*  Parameters : NONE
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  20-Apr-12  Vishal Gupta  Created
*
*/

COLUMN SID                                                        FORMAT 99999
COLUMN PID                                                        FORMAT 999999
COLUMN SPID                                                       FORMAT a6
COLUMN Process                                                    FORMAT a11
COLUMN instance_number        HEADING "I#"                        FORMAT 99
COLUMN serial#                HEADING "Serial#"                   FORMAT 99999
COLUMN instance_name          HEADING "Instance|Name"             FORMAT a9
COLUMN host_name              HEADING "HostName"                  FORMAT a40  TRUNCATE
COLUMN machine                                                    FORMAT a30  TRUNCATE
COLUMN program                                                    FORMAT a20  TRUNCATE

SELECT s.sid
     , i.instance_number
     , p.pid
     , p.spid
     , s.process
     , s.serial#
     , i.instance_name
     , i.host_name
   , s.machine
   , s.program
FROM v$session s
   , (select sid from v$mystat where rownum = 1) m
   , v$instance i
   , v$process p
WHERE s.sid = m.sid
  AND p.addr = s.paddr
@print_line_pivot_output

@@footer
