COLUMN profile          format A20      heading Profile
COLUMN resource_name                    heading 'Resource:'
COLUMN limit            format A15      heading Limit
BREAK on profile
SELECT   PROFILE, resource_name, LIMIT
    FROM sys.dba_profiles
ORDER BY PROFILE;
