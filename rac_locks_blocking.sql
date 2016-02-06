-- | PURPOSE  : Query all Blocking Locks in the databases. This query will      |
-- |            display both the user(s) holding the lock and the user(s)       |
-- |            waiting for the lock. This script is RAC enabled.               |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET PAGESIZE 9999

COLUMN locking_instance   FORMAT a17   HEAD 'LOCKING|Instance - SID'  JUST LEFT
COLUMN locking_sid        FORMAT a7    HEAD 'LOCKING|SID'             JUST LEFT
COLUMN waiting_instance   FORMAT a17   HEAD 'WAITING|Instance - SID'  JUST LEFT
COLUMN waiting_sid        FORMAT a7    HEAD 'WAITING|SID'             JUST LEFT
COLUMN waiter_lock_type                HEAD 'Waiter Lock Type'        JUST LEFT
COLUMN waiter_mode_req                 HEAD 'Waiter Mode Req.'        JUST LEFT
COLUMN instance_name      FORMAT a8    HEAD 'Instance|Name'           JUST LEFT
COLUMN sid                FORMAT a7    HEAD 'SID'                     JUST LEFT
COLUMN serial_number      FORMAT a7    HEAD 'Serial|Number'           JUST LEFT
COLUMN session_status                  HEAD 'Status'                  JUST LEFT
COLUMN oracle_user        FORMAT a20   HEAD 'Oracle|Username'         JUST LEFT
COLUMN os_username        FORMAT a20   HEAD 'O/S|Username'            JUST LEFT
COLUMN object_owner       FORMAT a15   HEAD 'Object|Owner'            JUST LEFT
COLUMN object_name        FORMAT a20   HEAD 'Object|Name'             JUST LEFT
COLUMN object_type        FORMAT a15   HEAD 'Object|Type'             JUST LEFT

CLEAR BREAKS

prompt 
prompt +----------------------------------------------------------------------------+
prompt | BLOCKING LOCKS                                                             |
prompt +----------------------------------------------------------------------------+
prompt 

SELECT
    ih.instance_name || ' - ' ||  lh.sid        locking_instance
  , iw.instance_name || ' - ' ||  lw.sid        waiting_instance
  , DECODE (   lh.type
             , 'CF', 'Control File'
             , 'DX', 'Distrted Transaction'
             , 'FS', 'File Set'
             , 'IR', 'Instance Recovery'
             , 'IS', 'Instance State'
             , 'IV', 'Libcache Invalidation'
             , 'LS', 'LogStartORswitch'
             , 'MR', 'Media Recovery'
             , 'RT', 'Redo Thread'
             , 'RW', 'Row Wait'
             , 'SQ', 'Sequence #'
             , 'ST', 'Diskspace Transaction'
             , 'TE', 'Extend Table'
             , 'TT', 'Temp Table'
             , 'TX', 'Transaction'
             , 'TM', 'Dml'
             , 'UL', 'PLSQL User_lock'
             , 'UN', 'User Name'
             , 'Nothing-'
           )                                    waiter_lock_type
  , DECODE (   lw.request
             , 0, 'None'
             , 1, 'NoLock'
             , 2, 'Row-Share'
             , 3, 'Row-Exclusive'
             , 4, 'Share-Table'
             , 5, 'Share-Row-Exclusive'
             , 6, 'Exclusive'
             , 'Nothing-'
           )                                    waiter_mode_req
FROM
    gv$lock     lw
  , gv$lock     lh
  , gv$instance iw
  , gv$instance ih
WHERE
   iw.inst_id = lw.inst_id
  AND ih.inst_id = lh.inst_id
  AND lh.id1     = lw.id1
  AND lh.id2     = lw.id2
  AND lh.request = 0
  AND lw.lmode   = 0
  AND (lh.id1, lh.id2) IN ( SELECT id1,id2
                            FROM   gv$lock
                            WHERE  request = 0
                            INTERSECT
                            SELECT id1,id2
                            FROM   gv$lock
                            WHERE  lmode = 0
                          )
ORDER BY
    lh.sid
/


prompt 
prompt +----------------------------------------------------------------------------+
prompt | LOCKED OBJECTS                                                             |
prompt +----------------------------------------------------------------------------+
prompt 

SELECT
    i.instance_name           instance_name
  , RPAD(l.session_id,7)      sid
  , RPAD(s.serial#,7)         serial_number
  , s.status                  session_status
  , l.oracle_username         oracle_user
  , l.os_user_name            os_username
  , o.owner                   object_owner
  , o.object_name             object_name
  , o.object_type             object_type
FROM
    dba_objects       o
  , gv$session        s
  , gv$locked_object  l
  , gv$instance       i
WHERE
      i.inst_id    = l.inst_id
  AND l.inst_id    = s.inst_id
  AND l.session_id = s.sid
  AND o.object_id  = l.object_id
ORDER BY
    l.session_id
/
