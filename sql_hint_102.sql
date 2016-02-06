select
     extractvalue(value(t),'.') hint
from
     table(
          select
               xmlsequence(
                    extract(xmltype(other_xml),'/other_xml/outline_data/hint')
               )
          from
               v$sql_plan
          where
               sql_id = '&m_sql_id'
          and     child_number = &m_child_no
          and     other_xml is not null
     )     t
/