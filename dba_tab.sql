col table_name format a40
col comments  format a100 

Prompt
Prompt
Prompt Enter value after DBA_, eg. hist or hist_sql
Prompt

SELECT * FROM DICT WHERE TABLE_NAME LIKE upper('DBA_%&look_for%') ORDER BY TABLE_NAME;
