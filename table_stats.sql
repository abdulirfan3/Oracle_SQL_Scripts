UNDEF OWNER_NAME
UNDEF TABLE_NAME
COLUMN owner             format a20 wrap           heading "Table|Owner"
COLUMN table_name        format a20 wrap           heading "Table|Name"
COLUMN Tablespace_name   format a20 wrap           heading "Tablespace|Name"
COLUMN num_rows          format 999,999,999,999          Heading "Numer|Of|Rows"
COLUMN blocks            format 999,999,999          Heading "Numer|Of|Blocks"
COLUMN empty_blocks      format 999,999,999          Heading "Numer|Of|Empty|Blocks"
COLUMN avg_row_len       format 999,999,999          Heading "Average|Row|Length"
COLUMN sample_size       format 999,999,999,999                Heading "Sample|Size"
COLUMN last_analyzed     heading "Date|Last|Analyzed"
SELECT   owner, table_name, tablespace_name, num_rows, blocks, empty_blocks,
         avg_row_len, sample_size, last_analyzed
    FROM dba_tables
   WHERE owner like upper(nvl('%&OWNER_NAME%',owner))
     AND table_name=upper('&TABLE_NAME')
ORDER BY owner, table_name;