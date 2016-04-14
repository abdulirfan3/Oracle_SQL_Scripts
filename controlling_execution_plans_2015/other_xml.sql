select other_xml from v$sql_plan
where sql_id like nvl('&sql_id', sql_id)
and child_number like nvl('&child_number',child_number)
and other_xml is not null
/
