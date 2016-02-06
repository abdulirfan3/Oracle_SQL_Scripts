set heading off;
set echo off;
Set pages 999;
set long 90000;
prompt
Prompt +--------------------------------+
Prompt +      Enter tablespace name     +
Prompt +--------------------------------+
prompt

select dbms_metadata.get_ddl('TABLESPACE',upper('&tbsp'))
from dual;
set heading on;