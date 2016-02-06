SELECT
TO_CHAR(ASH.SAMPLE_TIME, 'YYYY-MM-DD HH24:MI:SS')
SAMPLE_TIME,
ASH.SESSION_ID,
ASH.EVENT,
ASH.SEQ#,
ASH.WAIT_CLASS,
ASH.WAIT_TIME,
ASH.SESSION_STATE,
ASH.TIME_WAITED,
ASH.BLOCKING_SESSION_STATUS,
ASH.BLOCKING_SESSION,
ASH.SQL_ID,
ASH.PROGRAM,
ASH.MODULE,
ASH.DELTA_TIME,
O.OBJECT_NAME,
S.SQL_TEXT
FROM
DBA_HIST_ACTIVE_SESS_HISTORY ASH,
DBA_HIST_SQLTEXT S,
DBA_OBJECTS O
WHERE
ASH.SQL_ID = S.SQL_ID (+) AND
ASH.CURRENT_OBJ# = O.OBJECT_ID (+) AND
-- CAN ADD EVENT IF LIKE
--ASH.EVENT like 'enq: TX - row lock contention' AND
ASH.SAMPLE_TIME BETWEEN
TO_TIMESTAMP('2013-02-12 01:00:00', 'yyyy-mm-dd hh24:mi:ss') AND
TO_TIMESTAMP('2013-02-12 08:59:40', 'yyyy-mm-dd hh24:mi:ss') AND
ASH.SESSION_STATE = 'WAITING'
ORDER BY
SAMPLE_TIME;

--- sql for specific machine and time frame
SELECT DISTINCT sql_id
FROM
        (
                SELECT  sql_id     ,
                        sample_time,
                        machine    ,
                        program    ,
                        module     ,
                        action
                FROM    dba_hist_active_sess_history
                WHERE   sample_time BETWEEN '04-DEC-12 09.00.00.000 PM' AND '04-DEC-12 11.00.00.000 PM'
                        AND machine='usoak521'
        )