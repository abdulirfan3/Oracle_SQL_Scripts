select
extractvalue(value(d), '/hint') as outline_hints
from
xmltable('/outline_data/hint'
passing (
select
xmltype(comp_data) as xmlval
from
sys.sqlobj$data sod, sys.sqlobj$ so
where so.signature = sod.signature
and so.plan_id = sod.plan_id
and comp_data is not null
and name = '&baseline_plan_name'
)
) d;