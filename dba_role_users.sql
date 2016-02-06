COLUMN grantee        FORMAT a25   HEADING 'Grantee'        
COLUMN granted_role   FORMAT a30   HEADING 'Granted Role'   
COLUMN admin_option   FORMAT a40   HEADING 'Admin. Option?'  
COLUMN default_role   FORMAT a40   HEADING 'Default Role?'   

SELECT
    grantee       grantee
  ,  granted_role   granted_role
  ,  admin_option   admin_option
  , default_role   default_role
FROM
    dba_role_privs
WHERE
    granted_role = 'DBA'
ORDER BY
    grantee
  , granted_role;