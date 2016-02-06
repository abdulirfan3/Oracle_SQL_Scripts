-- | PURPOSE  : Report on all User Sessions.                                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999

COLUMN max_sess_allowed  FORMAT 999,999       JUSTIFY r HEADING 'Max sessions allowed'
COLUMN num_sessions      FORMAT 999,999,999   JUSTIFY r HEADING 'Number of sessions'
COLUMN pct_utl           FORMAT a19           JUSTIFY r HEADING 'Percent Utilization'
COLUMN username          FORMAT a15           JUSTIFY r HEADING 'Oracle User'
COLUMN num_user_sess     FORMAT 999,999       JUSTIFY r HEADING 'Number of Logins'
COLUMN count_a           FORMAT 999,999       JUSTIFY r HEADING 'Active Logins'
COLUMN count_i           FORMAT 999,999       JUSTIFY r HEADING 'Inactive Logins'

SET verify off

SELECT
    TO_NUMBER(a.value)         max_sess_allowed
  , TO_NUMBER(count(*))        num_sessions
  , LPAD(ROUND((count(*)/a.value)*100,0) || '%', 19)  pct_utl
FROM 
    v$session    b
  , v$parameter  a
WHERE 
    a.name = 'sessions'
GROUP BY 
    a.value;

break on report
compute sum of num_user_sess count_a count_i on report

SELECT
    lpad(nvl(sess.username, '[B.G. Process]'), 15) username
  , count(*) num_user_sess
  , nvl(act.count, 0)   count_a
  , nvl(inact.count, 0) count_i
FROM 
    v$session sess
  , (SELECT    count(*) count, nvl(username, '[B.G. Process]') username
     FROM      v$session
     WHERE     status = 'ACTIVE'
     GROUP BY  username)   act
  , (SELECT    count(*) count, nvl(username, '[B.G. Process]') username
     FROM      v$session
     WHERE     status = 'INACTIVE'
     GROUP BY  username) inact
WHERE
         nvl(sess.username, '[B.G. Process]') = act.username (+)
     and nvl(sess.username, '[B.G. Process]') = inact.username (+)
GROUP BY 
    sess.username
  , act.count
  , inact.count;

