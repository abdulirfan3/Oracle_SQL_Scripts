accept sql_id -
       prompt 'Enter value for sql_id: ' -
       default 'X0X0X0X0'
accept child_no -
       prompt 'Enter value for child_no: '
accept category -
       prompt 'Enter value for category: ' -
       default 'DEFAULT'
accept force_matching -
       prompt 'Enter value for force_matching: ' -
       default 'false'

@rg_sqlprof1 '&sql_id' &child_no '&category' '&force_matching'
undef sql_id
undef child_no
undef category
undef force_matching
