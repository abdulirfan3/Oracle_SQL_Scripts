-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_current_user_transactions.sql                              |
-- | CLASS    : Session Management                                              |
-- | PURPOSE  : List table locking and current user transactions information.   |



SET PAGESIZE 9999

COLUMN sid              FORMAT 99999    HEADING 'SID'
COLUMN oracle_username  FORMAT a14      HEADING 'Oracle User'  JUSTIFY right
COLUMN logon_time       FORMAT a18      HEADING 'Login Time'   JUSTIFY right
COLUMN owner            FORMAT a10      HEADING 'Owner'        JUSTIFY right
COLUMN object_type      FORMAT a10      HEADING 'Type'         JUSTIFY right
COLUMN object_name      FORMAT a25      HEADING 'Objext Name'  JUSTIFY right
COLUMN locked_mode      FORMAT a11      HEADING 'Locked Mode'


prompt 
prompt +----------------------------------------------------+
prompt | Table Locking Information                          |
prompt +----------------------------------------------------+

SELECT
    a.session_id                    sid
  , lpad(a.oracle_username,14)      oracle_username
  , lpad(TO_CHAR(
           c.logon_time,'mm/dd/yy hh24:mi:ss'
         ),
         18
    ) logon_time
  , lpad(b.owner,10)                owner
  , lpad(b.object_type,10)          object_type
  , lpad(b.object_name,25)          object_name
  , lpad(DECODE(a.locked_mode
             , 0, 'None'
             , 1, 'Null'
             , 2, 'Row-S'
             , 3, 'Row-X'
             , 4, 'Share'
             , 5, 'S/Row-X'
             , 6, 'Exclusive'), 11) locked_mode
FROM
    v$locked_object a
  , dba_objects b
  , v$session c
WHERE
      a.object_id  = b.object_id
  AND a.session_id = c.sid
ORDER BY
    b.owner
  , b.object_type
  , b.object_name
/

Prompt 
Prompt +----------------------------------------------------+
Prompt | User Transactions Information                      |
Prompt +----------------------------------------------------+


COLUMN sid                     FORMAT 99999            HEADING 'SID'
COLUMN serial_id               FORMAT 99999999         HEADING 'Serial ID'
COLUMN session_status          FORMAT a9               HEADING 'Status'          JUSTIFY right
COLUMN oracle_username         FORMAT a14              HEADING 'Oracle User'     JUSTIFY right
COLUMN os_username             FORMAT a12              HEADING 'O/S User'        JUSTIFY right
COLUMN os_pid                  FORMAT 9999999          HEADING 'O/S PID'         JUSTIFY right
COLUMN trnx_start_time         FORMAT a18              HEADING "Trnx Start Time" JUSTIFY right
COLUMN current_time            FORMAT a18              HEADING "Current Time"
COLUMN elapsed_time            FORMAT 999999999.99     HEADING "Elapsed(mins)"
COLUMN undo_name               FORMAT a9               HEADING "Undo Name"       JUSTIFY right
COLUMN number_of_undo_records  FORMAT 999,999,999,999  HEADING "# Undo Records"
COLUMN used_undo_blks          FORMAT     999,999,999  HEADING "Used Undo Blks" 
COLUMN used_undo_size          FORMAT 999,999,999,999  HEADING  "Used Undo Size"
COLUMN logical_io_blks         FORMAT     999,999,999  HEADING  "Logical I/O (Blks)"
COLUMN logical_io_size         FORMAT 999,999,999,999  HEADING  "Logical I/O (Bytes)" 
COLUMN physical_io_blks        FORMAT     999,999,999  HEADING  "Physical I/O (Blks)"
COLUMN physical_io_size        FORMAT 999,999,999,999  HEADING  "Physical I/O (Bytes)"
COLUMN session_program         FORMAT a26        HEADING 'Session Program' TRUNC

SELECT
    s.sid                                     sid
  , lpad(s.status,9)                          session_status
  , lpad(s.username,14)                       oracle_username
  , lpad(p.spid,7)                            os_pid
  , lpad(TO_CHAR(TO_DATE(b.start_time,'mm/dd/yy hh24:mi:ss')
           ,'mm/dd/yy hh24:mi:ss'
        )
       , 18
    )  trnx_start_time
  , ROUND(60*24*(sysdate-to_date(b.start_time,'mm/dd/yy hh24:mi:ss')),2)        elapsed_time
  , lpad(c.segment_name,9)                    undo_name
  , b.used_urec                               number_of_undo_records
  , b.used_ublk * d.value                     used_undo_size
  , b.log_io*d.value                          logical_io_size
  , b.phy_io*d.value                          physical_io_size
  , s.program                                 session_program
FROM
    v$session         s
  , v$transaction     b
  , dba_rollback_segs c
  , v$parameter       d
  , v$process         p
WHERE
      b.ses_addr = s.saddr
  AND b.xidusn   = c.segment_id
  AND d.name     = 'db_block_size'
  AND p.ADDR     = s.PADDR
ORDER BY 1
/
