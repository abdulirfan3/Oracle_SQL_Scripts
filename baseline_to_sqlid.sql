prompt 
prompt
prompt Needs to be run as sys
prompt or have execute permission on dbms_crypto package
prompt
prompt
set serveroutput on;
declare
v_sqlid VARCHAR2(13);
v_num number;
BEGIN
dbms_output.put_line('SQL_ID       '||' '|| 'PLAN_HASH_VALUE' || ' ' || 'SQL_HANDLE                    ' || ' ' || 'PLAN_NAME');
dbms_output.put_line('-------------'||' '|| '---------------' || ' ' || '------------------------------' || ' ' || '--------------------------------');
for a in (select sql_handle, plan_name, trim(substr(g.PLAN_TABLE_OUTPUT,instr(g.PLAN_TABLE_OUTPUT,':')+1)) plan_hash_value, sql_text
                 from (select t.*, c.sql_handle, c.plan_name, c.sql_text from dba_sql_plan_baselines c, table(dbms_xplan.DISPLAY_SQL_PLAN_BASELINE(c.sql_handle, c.plan_name)) t
                 where c.sql_handle = '&sql_handle') g
                 where PLAN_TABLE_OUTPUT like 'Plan hash value%') loop
    v_num := to_number(sys.UTL_RAW.reverse(sys.UTL_RAW.SUBSTR(sys.dbms_crypto.hash(src => UTL_I18N.string_to_raw(a.sql_text || chr(0),'AL32UTF8'), typ => 2),9,4)) || sys.UTL_RAW.reverse(sys.UTL_RAW.SUBSTR(sys.dbms_crypto.hash(src => UTL_I18N.string_to_raw(a.sql_text || chr(0),'AL32UTF8'), typ => 2),13,4)),RPAD('x', 16, 'x'));
    v_sqlid := '';
    FOR i IN 0 .. FLOOR(LN(v_num) / LN(32))
    LOOP
        v_sqlid := SUBSTR('0123456789abcdfghjkmnpqrstuvwxyz',FLOOR(MOD(v_num / POWER(32, i), 32)) + 1,1) || v_sqlid;
    END LOOP;
    dbms_output.put_line(v_sqlid ||' ' || rpad(a.plan_hash_value,15) || ' ' || rpad(a.sql_handle,30) ||  ' ' || rpad(a.plan_name,30));
end loop;
end;
/