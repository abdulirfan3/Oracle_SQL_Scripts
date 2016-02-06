col owner format A12
col object_name format A30
col statistic_name format A30 
col object_type format A10
col value format 999,999,999,999,999,999
col perc format 99.99
undef statistic_name
break on statistic_name
prompt enter value like logical reads, physical writes,db block changes
with  segstats as (
       select * from (
         select inst_id, owner, object_name, object_type , value , 
		rank() over (partition by  inst_id, statistic_name order by value desc ) rnk , statistic_name 
		 from gv$segment_statistics 
          where value >0  and statistic_name like '%'||'&&statistic_name' ||'%'
        ) where rnk <31
       )  , 
sumstats as ( select inst_id, statistic_name, sum(value) sum_value from gv$segment_statistics group by statistic_name, inst_id) 
 select a.inst_id, a.statistic_name, a.owner, a.object_name, a.object_type,a.value,(a.value/b.sum_value)*100 perc
    from segstats a ,   sumstats b 
where a.statistic_name = b.statistic_name
and a.inst_id=b.inst_id
order by a.statistic_name, a.value desc
/

col value format 999,999,999,999,999,999
Prompt Stats for a paticular object
prompt
select STATISTIC_NAME, owner, object_name, object_type, value
from v$segment_statistics
where owner=UPPER('&OWNER')
AND OBJECT_NAME=UPPER('&OBJECT_NAME');
