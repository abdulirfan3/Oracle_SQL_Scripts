/* version 1
prompt ************************************
prompt **** ASH OVERALL WAIT PROFILE
prompt ************************************
prompt RR columns are ratio to report

SELECT MIN(sample_time) min_ash_available,sysdate-MIN(sample_time) available_duration FROM v$active_session_history;

select * from (
select NVL(event,'CPU') event,count(*),
round((ratio_to_report(sum(1)) over ()*100),1) rr
from gv$active_session_history
WHERE user_id<>0
AND sample_time<trunc(SYSDATE+1) AND sample_time>trunc(sysdate-1)
group by event
order by 2 desc
) where rownum<10;
 
prompt ************************************
prompt **** ASH I/O by SQL_ID
prompt ************************************
prompt RR columns are ratio to report
 
COLUMN force_matching_signature FOR 999999999999999999999999999
select * from (
select
sql_id ,sql_plan_hash_value,force_matching_signature,
NVL(event,'CPU') Event,
count(*),
round((ratio_to_report(sum(1)) over ()*100),1) rr
from gv$active_session_history
where
1=1
AND wait_class LIKE '%I/O'
--AND event IS null
and user_id<>0
AND sql_id IS NOT NULL
group by
sql_id,sql_plan_hash_value,event,force_matching_signature
order by 5 desc
) where rownum<30;

Prompt
prompt Run sql_wait_on_event_ash script to find SQLID for a paticular wait event
prompt
*/

-- version 2, in use
prompt
accept how_many_min_back prompt "How many minutes do you want to go back? "

prompt ************************************
prompt **** ASH OVERALL WAIT PROFILE
prompt ************************************
prompt RR columns are ratio to report

SELECT MIN(sample_time) min_ash_available,sysdate-MIN(sample_time) available_duration FROM v$active_session_history;


select * from (
select NVL(event,'CPU') event,count(*),
round((ratio_to_report(sum(1)) over ()*100),1) rr
from gv$active_session_history
WHERE user_id<>0
AND SAMPLE_TIME > sysdate - ('&how_many_min_back'/(24*60))
group by event
order by 2 desc
) where rownum<10;
 
prompt ************************************
prompt **** ASH I/O by SQL_ID, Top 10
prompt ************************************
prompt RR columns are ratio to report
 
COLUMN force_matching_signature FOR 999999999999999999999999999
select * from (
select
sql_id ,sql_plan_hash_value,force_matching_signature,
NVL(event,'CPU') Event,
count(*),
round((ratio_to_report(sum(1)) over ()*100),1) rr
from gv$active_session_history
where
1=1
AND SAMPLE_TIME > sysdate - ('&how_many_min_back'/(24*60))
AND wait_class LIKE '%I/O'
--AND event IS null
and user_id<>0
AND sql_id IS NOT NULL
group by
sql_id,sql_plan_hash_value,event,force_matching_signature
order by 5 desc
) where rownum<11;

prompt ************************************
prompt **** ASH DB_TIME by SQL_ID, Top 10
prompt ************************************

select * from (
select sql_id
, count(*) DBTime
, round(count(*)*100/sum(count(*))
over (), 2) pctload
from v$active_session_history
where sample_time > sysdate - ('&how_many_min_back'/(24*60))
and session_type <> 'BACKGROUND'
group by sql_id
order by count(*) desc
) where rownum < 11;

prompt ************************************
prompt **** Wait class breakdown by sqlid/module
prompt **** Can change grouping
prompt ************************************

@ash_top sql_id session_type='FOREGROUND' sysdate-('&how_many_min_back'/(24*60)) sysdate

Prompt
prompt Run sql_wait_on_event_ash script to find SQLID for a paticular wait event
prompt

