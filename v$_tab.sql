Prompt
Prompt
Prompt Enter value after V$, eg. sql or fla
Prompt

SELECT 
   NAME, 
    TYPE
FROM 
   V$FIXED_TABLE
WHERE 
    upper(NAME) LIKE upper('V$%&look_for%') order by 1;