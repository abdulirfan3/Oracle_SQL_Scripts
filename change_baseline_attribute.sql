prompt
prompt First list all baseline present in the system then change attribute
prompt
@BASELINE_INFO


prompt
prompt
prompt Attributes that can be changed are
prompt enabled(yes or no), fixed(yes or no), autopurge(yes or no), plan_name, description
prompt
prompt
declare
myplan pls_integer;
begin
myplan:=DBMS_SPM.ALTER_SQL_PLAN_BASELINE (sql_handle=>'&sql_handle',plan_name=>'&plan_name',attribute_name=>'&what_attribute_to_change',attribute_value=>'&attribute_value');
end;
/
