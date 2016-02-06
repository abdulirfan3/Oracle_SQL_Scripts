select unique METRIC_NAME from sys.v_$sysmetric_history order by 1;

Prompt
prompt +------------------------------------+
prompt |  Select a Metric name From above   |
prompt |    to get history on last hour     |
Prompt +------------------------------------+
prompt

select  end_time,
        round(value,3) value, METRIC_UNIT
from    sys.v_$sysmetric_history
where   metric_name='&Metric_name'
order by 1;