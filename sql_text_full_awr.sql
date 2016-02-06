set heading off;
set long 200000
select sql_text from dba_hist_sqltext
where  sql_id='&SQL_ID'
;
set heading on;