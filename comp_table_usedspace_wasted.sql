prompt
prompt This script relies on collecting good stats
prompt
SELECT
SUBSTR(TABLE_NAME, 1, 21) TABLE_NAME,
ROUND(BLOCKS * (8000 - 23 * INI_TRANS) * (1 - PCT_FREE / 100) / 1000000, 0) GROSS_MB,
ROUND((AVG_ROW_LEN + 1) * NUM_ROWS / 1000000, 0) USED_MB,
ROUND((BLOCKS * (8000 - 23 * INI_TRANS) * (1 - PCT_FREE / 100) - (AVG_ROW_LEN + 1) * NUM_ROWS) / 1000000) "WASTED_MB"
FROM DBA_TABLES
WHERE
NUM_ROWS IS NOT NULL AND
OWNER = upper('&owner') AND
table_name = upper('&tbl_name')
ORDER BY 4 DESC
/
