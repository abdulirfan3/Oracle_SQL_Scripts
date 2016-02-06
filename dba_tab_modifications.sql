REM - I/U/D Counts



    SET lines 250
    SET pages 5000
    col inserts FOR 999,999,999,999
    col updates FOR 999,999,999,999
    col deletes FOR 999,999,999,999
    col T_MEG FOR 999,999,999,999
    col num_rows FOR 999,999,999,999

    col table_name format a35
    col partition_name format a35
    col table_owner format a15
    col last_analyzed  format a20


set trimspool on;

--spool /tmp/dba_tab_modifications_$ORACLE_SID.txt



--
-- standard heading
--
set echo off
set     heading off
column  sortby  noprint
        select  1 sortby, '===============================================================================' from dual
union   select  2 sortby, 'DBA_TAB_MODIFICATIONS I/U/D Counts' from dual
union   select  3 sortby, 'Instance Name    ->  '||name "instancename" from v$database
union   select  4 sortby, 'Instance Host    ->  '||machine from v$session where sid = 1
union   select  5 sortby, 'Current  Time    ->  '||to_char(sysdate, 'MM-DD-YYYY HH24:MI:SS')  from dual
union   select  6 sortby, '===============================================================================' from dual
order   by 1;
set     heading on



set echo off
set     heading off
column  sortby  noprint
        select  1 sortby, '===============================================================================' from dual
union   select  2 sortby, 'Inserts' from dual
union   select  3 sortby, '===============================================================================' from dual
order   by 1;
set     heading on


set linesize 300
    SELECT M.TABLE_OWNER
    , M.TABLE_NAME
    , M.INSERTS
    , M.UPDATES
    , M.DELETES
    , ( M.INSERTS
    + M.UPDATES
    + M.DELETES)
    MODIF
    , T.NUM_ROWS
    , ROUND (
    ( M.INSERTS
    + M.UPDATES
    + M.DELETES)
    / DECODE (T.NUM_ROWS, 0, 1, T.NUM_ROWS)
    * 100
    , 0
    )
    PCT_MODIF
    , ROUND ( S.BYTES / 1024 / 1024, 0) T_MEG
    , TO_CHAR ( T.LAST_ANALYZED, 'dd/mm/yyyy hh24:mi') LAST_ANALYZED
    FROM SYS.DBA_TAB_MODIFICATIONS M
    , DBA_TABLES T
    , DBA_SEGMENTS S
    , DBA_OBJECTS O
    WHERE M.TABLE_OWNER like 'SAP%'
    AND M.TABLE_OWNER = T.OWNER
    AND M.TABLE_NAME = T.TABLE_NAME
    AND M.TABLE_OWNER = S.OWNER
    AND M.TABLE_NAME = SEGMENT_NAME
    AND S.OWNER = O.OWNER
    AND S.SEGMENT_NAME = O.OBJECT_NAME
    AND ROUND (
    ( M.INSERTS
    + M.UPDATES
    + M.DELETES)
    / DECODE (T.NUM_ROWS, 0, 1, T.NUM_ROWS)
    * 100
    , 0
    ) >= 5
    AND rownum < 201
    order by m.inserts  desc;


set echo off
set     heading off
column  sortby  noprint
        select  1 sortby, '===============================================================================' from dual
union   select  2 sortby, 'Updates' from dual
union   select  3 sortby, '===============================================================================' from dual
order   by 1;
set     heading on


    SELECT M.TABLE_OWNER
    , M.TABLE_NAME
    , M.INSERTS
    , M.UPDATES
    , M.DELETES
    , ( M.INSERTS
    + M.UPDATES
    + M.DELETES)
    MODIF
    , T.NUM_ROWS
    , ROUND (
    ( M.INSERTS
    + M.UPDATES
    + M.DELETES)
    / DECODE (T.NUM_ROWS, 0, 1, T.NUM_ROWS)
    * 100
    , 0
    )
    PCT_MODIF
    , ROUND ( S.BYTES / 1024 / 1024, 0) T_MEG
    , TO_CHAR ( T.LAST_ANALYZED, 'dd/mm/yyyy hh24:mi') LAST_ANALYZED
    FROM SYS.DBA_TAB_MODIFICATIONS M
    , DBA_TABLES T
    , DBA_SEGMENTS S
    , DBA_OBJECTS O
    WHERE M.TABLE_OWNER like 'SAP%'
    AND M.TABLE_OWNER = T.OWNER
    AND M.TABLE_NAME = T.TABLE_NAME
    AND M.TABLE_OWNER = S.OWNER
    AND M.TABLE_NAME = SEGMENT_NAME
    AND S.OWNER = O.OWNER
    AND S.SEGMENT_NAME = O.OBJECT_NAME
    AND ROUND (
    ( M.INSERTS
    + M.UPDATES
    + M.DELETES)
    / DECODE (T.NUM_ROWS, 0, 1, T.NUM_ROWS)
    * 100
    , 0
    ) >= 5
    AND rownum < 201
    order by m.updates  desc;



set echo off
set     heading off
column  sortby  noprint
        select  1 sortby, '===============================================================================' from dual
union   select  2 sortby, 'Deletes' from dual
union   select  3 sortby, '===============================================================================' from dual
order   by 1;
set     heading on


    SELECT M.TABLE_OWNER
    , M.TABLE_NAME
    , M.INSERTS
    , M.UPDATES
    , M.DELETES
    , ( M.INSERTS
    + M.UPDATES
    + M.DELETES)
    MODIF
    , T.NUM_ROWS
    , ROUND (
    ( M.INSERTS
    + M.UPDATES
    + M.DELETES)
    / DECODE (T.NUM_ROWS, 0, 1, T.NUM_ROWS)
    * 100
    , 0
    )
    PCT_MODIF
    , ROUND ( S.BYTES / 1024 / 1024, 0) T_MEG
    , TO_CHAR ( T.LAST_ANALYZED, 'dd/mm/yyyy hh24:mi') LAST_ANALYZED
    FROM SYS.DBA_TAB_MODIFICATIONS M
    , DBA_TABLES T
    , DBA_SEGMENTS S
    , DBA_OBJECTS O
    WHERE M.TABLE_OWNER like 'SAP%'
    AND M.TABLE_OWNER = T.OWNER
    AND M.TABLE_NAME = T.TABLE_NAME
    AND M.TABLE_OWNER = S.OWNER
    AND M.TABLE_NAME = SEGMENT_NAME
    AND S.OWNER = O.OWNER
    AND S.SEGMENT_NAME = O.OBJECT_NAME
    AND ROUND (
    ( M.INSERTS
    + M.UPDATES
    + M.DELETES)
    / DECODE (T.NUM_ROWS, 0, 1, T.NUM_ROWS)
    * 100
    , 0
    ) >= 5
    AND rownum < 201
    order by m.deletes  desc;


spool off;
