@@header

/*
* 
*  Author   : Vishal Gupta
*  Purpose  : Displays current transactions sizes
*  Parameter: 1 - Where Clause
* 
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  16-Jul-12  Vishal Gupta  Added the WHERE clause
*  16-Jul-12  Vishal Gupta  Created
*
*/



DEFINE BYTES_FORMAT="999,999"
--DEFINE BYTES_DIVIDER="1024"
--DEFINE BYTES_HEADING="KB"
DEFINE BYTES_DIVIDER="1024/1024"
DEFINE BYTES_HEADING="MB"
--DEFINE BYTES_DIVIDER="1024/1024/1024"
--DEFINE BYTES_HEADING="GB"

UNDEFINE WHERE_CLAUSE
DEFINE WHERE_CLAUSE="&&1"


PROMPT
PROMPT *********************************************
PROMPT * D A T A B A S E   T R A N S A C T I O N S
PROMPT *********************************************

COLUMN xid                      HEADING "XID|Heirarchy"            FORMAT a16 
COLUMN sid                      HEADING "SID|Heirarchy"            FORMAT a10
COLUMN inst_id                  HEADING "I#"                       FORMAT 99 
COLUMN spid                     HEADING "SPID"                     FORMAT a6
COLUMN transaction_start_date   HEADING "Tran StartDate"           FORMAT a18 
COLUMN tran_duration            HEADING "Tran |Duration"           FORMAT a15 
COLUMN transaction_status       HEADING "Tran|Status"              FORMAT a8 
COLUMN space                    HEADING "Space|Tran"               FORMAT a5 
COLUMN recursive                HEADING "Recu|rsive|Tran"          FORMAT a5 
COLUMN noundo                   HEADING "No|Undo|Tran"             FORMAT a4 
COLUMN ptx                      HEADING "Par'l|Tran"               FORMAT a5 
COLUMN used_undo                HEADING "Undo|(&&BYTES_HEADING)"   FORMAT &&BYTES_FORMAT
COLUMN username                 HEADING "UserName"                 FORMAT a20
COLUMN osuser                   HEADING "OS User"                  FORMAT a15 TRUNCATED
COLUMN status                   HEADING "Status"                   FORMAT a8
COLUMN state                    HEADING "Session|State"            FORMAT a12 TRUNCATED
COLUMN logon_time               HEADING "Logon Time"               FORMAT a18
COLUMN MACHINE                  HEADING "Machine"                  FORMAT a20 TRUNCATED
COLUMN process                  HEADING "Process"                  FORMAT a11 
COLUMN program                  HEADING "Program"                  FORMAT a20 TRUNCATED
COLUMN event                    HEADING "Event"                    FORMAT a30 TRUNCATED
--COLUMN last_call_et           HEADING "LastCall|(sec)"             FORMAT 999,999        
COLUMN last_call_et             HEADING "LastCall"                 FORMAT a12
COLUMN sql_child_number         HEADING "SQL|Child|No"             FORMAT 99

COLUMN log_io                   HEADING "Logical|IO"               FORMAT 999,999,999
COLUMN phy_io                   HEADING "Physical|IO"              FORMAT 999,999,999
COLUMN cr_get                   HEADING "Consistent|Gets"          FORMAT 999,999,999



SELECT 
       DECODE(level,1, '' , ' ') 
          || LPAD('> ',(level-1)*5,'|--')  
          || t.xid   xid
     --, t.ptx_xid
     , DECODE(level,1, '' , ' ') 
          || LPAD('> ',(level-1)*5,'|--')  
          || s.sid sid
     , t.inst_id
     , p.spid
     , s.status
     , TO_CHAR(t.start_date,'DD-MON-YY HH24:MI:SS')  transaction_start_date
     , FLOOR(sysdate - t.start_date) || 'd '
       || LPAD(FLOOR(MOD((sysdate - t.start_date) , 1) * 24 ) ,2) || 'h '
       || LPAD(FLOOR(MOD((sysdate - t.start_date) * 24 , 1) * 60 ) ,2) || 'm '
       || LPAD(FLOOR(MOD((sysdate - t.start_date) * 24 * 60 , 1) * 60 ) ,2) || 's ' tran_duration
     , t.status      transaction_status
     , t.space
     , t.recursive
     , t.noundo
     , t.ptx
     , ROUND((t.used_ublk * p.value)/&&BYTES_DIVIDER) used_undo
     , t.log_io
     , t.phy_io
     , t.cr_get
     , s.username
     , s.osuser
     , s.sql_id
     , s.sql_child_number
     , s.program
--     , o.object_name
--     , DECODE(lo.locked_mode,
--                0, 'None',           /* Mon Lock equivalent */
--                1, 'Null',           /* N */
--                2, 'Row-S (SS)',     /* L */
--                3, 'Row-X (SX)',     /* R */
--                4, 'Share',          /* S */
--                5, 'S/Row-X (SSX)',  /* C */
--                6, 'Exclusive',      /* X */
--            TO_CHAR(lo.locked_mode)
--            )  locked_mode
FROM gv$transaction t
     INNER JOIN gv$session s ON t.inst_id = s.inst_id   AND t.ses_addr = s.saddr 
     INNER JOIN gv$process p ON p.inst_id = s.inst_id   AND p.addr = s.paddr
     INNER JOIN v$parameter p ON p.name = 'db_block_size'
--       LEFT OUTER JOIN gv$locked_object lo ON t.inst_id = lo.inst_id 
--                 AND s.sid = lo.session_id 
--                 AND t.xidusn = lo.xidusn 
--                 AND t.xidslot = lo.xidslot 
--                 AND t.xidsqn = lo.xidsqn 
--       LEFT OUTER JOIN dba_objects o ON lo.object_id = o.object_id
WHERE 1=1 and 2=2   
-- had to put AND cluase other when no where clause is passed it was giving following error
-- SP2-0341: line overflow during variable substitution (>3000 characters at line 53)
 &&WHERE_CLAUSE
CONNECT BY NOCYCLE PRIOR t.xid = t.ptx_xid
--ORDER BY transaction_start_date 
;


@@footer