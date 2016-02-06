set long 1000

set pagesize 1000

select text from dba_views where owner=upper('&owner') and view_name=upper('&view_name');
set pages 50;
