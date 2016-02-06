COLUMN sid             FORMAT 99999                HEADING 'Sid'
COLUMN serial#         FORMAT 99999                HEADING 'Serial#'
COLUMN Program         FORMAT a25 word_wrap        HEADING 'Program'
COLUMN pid             FORMAT 99999                HEADING 'Pid'
COLUMN spid            FORMAT 999999               HEADING 'Spid'
COLUMN osuer           FORMAT a10                  HEADING 'OSUser' TRUNC
COLUMN terminal        FORMAT a10 word_wrap        HEADING 'Terminal'
COLUMN machine         FORMAT a25 word_wrap        HEADING 'Machine'
COLUMN logon_time                                  HEADING 'Logon_time'
COLUMN Name            FORMAT a10 word_wrap        HEADING 'Name'
COLUMN Description     FORMAT a25 word_wrap        HEADING 'Description'


select
        A.SID,
        A.SERIAL#,
        A.PROGRAM,
        P.PID,
        P.SPID,
        A.OSUSER,       /* Who Started INSTANCE */
        A.TERMINAL,
        A.MACHINE,
        to_char(A.LOGON_TIME, 'DD-MON-YY')  logon_time,
        B.NAME,
        B.Description
from
        v$session       A,
        v$process       P,
        v$bgprocess     B
where
        A.PADDR=B.PADDR
AND     A.PADDR=P.ADDR
and     A.type='BACKGROUND'
;