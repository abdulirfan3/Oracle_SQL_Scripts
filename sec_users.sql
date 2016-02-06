-- | PURPOSE  : Lists all users in the database including their default and     |
-- |            temporary tablespaces.                                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET VERIFY   off

COLUMN username              FORMAT a15    HEAD 'Username'
COLUMN account_status        FORMAT a17    HEAD 'Status'
COLUMN expiry_date                         HEAD 'Expire Date'
COLUMN default_tablespace    FORMAT a25    HEAD 'Default Tbs.'
COLUMN temporary_tablespace  FORMAT a10    HEAD 'Temp Tbs.'
COLUMN created                             HEAD 'Created On'
COLUMN profile               FORMAT a10    HEAD 'Profile'
COLUMN sysdba                FORMAT a6     HEAD 'SYSDBA'
COLUMN sysoper               FORMAT a7     HEAD 'SYSOPER'

SELECT distinct
    a.username                                       username
  , a.account_status                                 account_status
  , TO_CHAR(a.expiry_date, 'DD-MON-YYYY HH24:MI:SS') expiry_date
  , a.default_tablespace                             default_tablespace
  , a.temporary_tablespace                           temporary_tablespace
  , TO_CHAR(a.created, 'DD-MON-YYYY HH24:MI:SS')     created
  , a.profile                                        profile
  , DECODE(p.sysdba,'TRUE', 'TRUE','')               sysdba
  , DECODE(p.sysoper,'TRUE','TRUE','')               sysoper
FROM
    dba_users       a
  , v$pwfile_users  p
WHERE
    p.username (+) = a.username 
ORDER BY username
/
