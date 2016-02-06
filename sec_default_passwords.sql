-- | PURPOSE  : Checks Oracle created users that still have their default       |
-- |            password.                                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SELECT
    username       "User(s) with Default Password!"
  , account_status "Account Status"
FROM dba_users
WHERE password IN (
    'E066D214D5421CCC'   -- dbsnmp
  , '24ABAB8B06281B4C'   -- ctxsys
  , '72979A94BAD2AF80'   -- mdsys
  , 'C252E8FA117AF049'   -- odm
  , 'A7A32CD03D3CE8D5'   -- odm_mtr
  , '88A2B2C183431F00'   -- ordplugins
  , '7EFA02EC7EA6B86F'   -- ordsys
  , '4A3BA55E08595C81'   -- outln
  , 'F894844C34402B67'   -- scott
  , '3F9FBD883D787341'   -- wk_proxy
  , '79DF7A1BD138CF11'   -- wk_sys
  , '7C9BA362F8314299'   -- wmsys
  , '88D8364765FCE6AF'   -- xdb
  , 'F9DA8977092B7B81'   -- tracesvr
  , '9300C0977D7DC75E'   -- oas_public
  , 'A97282CE3D94E29E'   -- websys
  , 'AC9700FD3F1410EB'   -- lbacsys
  , 'E7B5D92911C831E1'   -- rman
  , 'AC98877DE1297365'   -- perfstat
  , 'D4C5016086B2DC6A'   -- sys
  , 'D4DF7931AB130E37')  -- system
/


