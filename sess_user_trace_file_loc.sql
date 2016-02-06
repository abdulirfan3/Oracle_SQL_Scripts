-- | PURPOSE  : Oracle writes TRACE to the directory based on the value of your |
-- |            "user_dump_dest" parameter in init.ora file. The trace files    |
-- |            use the "System Process ID" as part of the file name to ensure  |
-- |            a unique file for each user session. The following query helps  |
-- |            the DBA to determine where the TRACE files will be written and  |
-- |            the name of the file it would create for its particular         |
-- |            session.                                                        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999

COLUMN "Trace File Path" FORMAT a65 HEADING 'Your tracefile with path is:'

SELECT
    a.trace_path || ' > ' || b.trace_file "Trace File Path"
FROM
    (  SELECT value trace_path 
       FROM   v$parameter 
       WHERE  name='user_dump_dest'
    ) a
  , (  SELECT c.instance || '_ora_' || spid ||'.trc' TRACE_FILE 
       FROM   v$process,
              (SELECT LOWER(instance) instance FROM v$thread)  c
       WHERE  addr = ( SELECT paddr 
                       FROM v$session 
                       WHERE audsid = ( SELECT userenv('SESSIONID') 
                                        FROM dual
                                      )
                     )
    ) b
/
