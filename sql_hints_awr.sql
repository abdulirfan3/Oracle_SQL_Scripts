select
   extractvalue(value(d), '/hint') as outline_hints
   from
   xmltable('/*/outline_data/hint'
   passing (
   select
   xmltype(other_xml) as xmlval
   from
   dba_hist_sql_plan
   where
   sql_id = '&sql_id'
   and plan_hash_value = &plan_hash_value
   and other_xml is not null
   )
   ) d;
