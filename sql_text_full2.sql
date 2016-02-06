SELECT   sql_text
    FROM v$sqltext_with_newlines
   WHERE sql_id=('&SQL_ID')
ORDER BY piece;