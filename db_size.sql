Prompt
Prompt  ============================================================
Prompt  |Shows sum of datafile (dose not include temp/redo/control)|
Prompt  ============================================================
set timi off;

select round(sum(bytes)/1024/1024/1024,2) "Total_GB" from dba_data_files;
SELECT round(SUM(bytes)/1024/1024/1024,2) "Used_GB" FROM dba_segments;

set timi on;