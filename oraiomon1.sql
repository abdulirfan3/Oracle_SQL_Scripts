set pages 200
set newpage none
set feed off
set verify off
set echo off
set head off
column seq_ms for 9999
column seq_ct for 9999
column scat_ms for 9999
column scat_ct for 9999
column dpr_ms for 9999
column dpr_ct for 9999
column dpw_ms for 9999
column dpw_ct for 9999
column dprt_ms for 9999
column dprt_ct for 9999
column dpwt_ms for 9999
column dpwt_ct for 9999
column lfpw_ms for 9999
column lfpw_ct for 9999
column prevdprt_ct new_value prevdprt_ct_var
column prevdprt_tm new_value prevdprt_tm_var
column prevdpwt_ct new_value prevdpwt_ct_var
column prevdpwt_tm new_value prevdpwt_tm_var
column prevdpr_ct new_value prevdpr_ct_var
column prevdpr_tm new_value prevdpr_tm_var
column prevdpw_ct new_value prevdpw_ct_var
column prevdpw_tm new_value prevdpw_tm_var
column prevseq_ct new_value prevseq_ct_var
column prevseq_tm new_value prevseq_tm_var
column prevscat_ct new_value prevscat_ct_var
column prevscat_tm new_value prevscat_tm_var
column prevlfpw_ct new_value prevlfpw_ct_var
column prevlfpw_tm new_value prevlfpw_tm_var
column prevsec new_value prevsec_var
select 0 prevsec from dual;
select 0 prevseq_tm from dual;
select 0 prevseq_ct from dual;
select 0 prevscat_ct from dual;
select 0 prevscat_tm from dual;
select 0 prevlfpw_ct from dual;
select 0 prevlfpw_tm from dual;
select 0 prevdprt_ct from dual;
select 0 prevdprt_tm from dual;
select 0 prevdpwt_ct from dual;
select 0 prevdpwt_tm from dual;
select 0 prevdpr_ct from dual;
select 0 prevdpr_tm from dual;
select 0 prevdpw_ct from dual;
select 0 prevdpw_tm from dual;
column prevdprt_ct noprint
column prevdprt_tm noprint
column prevdpwt_ct noprint
column prevdpwt_tm noprint
column prevdpr_ct noprint
column prevdpr_tm noprint
column prevdpw_ct noprint
column prevdpw_tm noprint
column prevseq_ct noprint
column prevseq_tm noprint
column prevscat_ct noprint
column prevscat_tm noprint
column prevlfpw_ct noprint
column prevlfpw_tm noprint
column prevsec noprint
--clear scr
@oraiomon_head.sql

select
        round(seqtm/nullif(seqct,0),0) seq_ms,
        round(seqct/nullif(delta,0),0) seq_ct,
        round(scattm/nullif(scatct,0),0) scat_ms,
        round(scatct/nullif(delta,0),0) scat_ct,
        round(dprtm/nullif(dprct,0),0) dpr_ms,
        round(dprct/nullif(delta,0),0) dpr_ct,
				round(dpwtm/nullif(dpwct,0),0) dpw_ms,
				round(dpwct/nullif(delta,0),0) dpw_ct,
        round(dprttm/nullif(dprtct,0),0) dprt_ms,
        round(dprtct/nullif(delta,0),0) dprt_ct,
				round(dpwttm/nullif(dpwtct,0),0) dpwt_ms,
	   	  round(dpwtct/nullif(delta,0),0) dpwt_ct,
	   	  round(lfpwtm/nullif(lfpwct,0),0) lfpw_ms,
        ceil(lfpwct/nullif(delta,0)) lfpw_ct,
        prevseq_ct, prevscat_ct, prevseq_tm, prevscat_tm, prevsec,prevlfpw_tm,prevlfpw_ct
        , prevdpr_ct, prevdpr_tm , prevdprt_ct, prevdprt_tm , prevdpw_ct, prevdpw_tm
        , prevdpwt_ct, prevdpwt_tm
from
(select
       sum(decode(event,'db file sequential read', round(time_waited_micro/1000) -  &prevseq_tm_var,0)) seqtm,
       sum(decode(event,'db file scattered read',  round(time_waited_micro/1000) - &prevscat_tm_var,0)) scattm,
       sum(decode(event,'log file parallel write',  round(time_waited_micro/1000) - &prevlfpw_tm_var,0)) lfpwtm,
       sum(decode(event,'db file sequential read', round(time_waited_micro/1000) ,0)) prevseq_tm,
       sum(decode(event,'db file scattered read',  round(time_waited_micro/1000) ,0)) prevscat_tm,
       sum(decode(event,'log file parallel write',  round(time_waited_micro/1000) ,0)) prevlfpw_tm,
       sum(decode(event,'db file sequential read', total_waits - &prevseq_ct_var,0)) seqct,
       sum(decode(event,'db file scattered read',  total_waits - &prevscat_ct_var,0)) scatct,
       sum(decode(event,'log file parallel write',  total_waits - &prevlfpw_ct_var,0)) lfpwct,
       sum(decode(event,'db file sequential read', total_waits ,0)) prevseq_ct,
       sum(decode(event,'db file scattered read',  total_waits ,0)) prevscat_ct,
       sum(decode(event,'log file parallel write',  total_waits ,0)) prevlfpw_ct,
       sum(decode(event,'direct path read',  round(time_waited_micro/1000) - &prevdpr_tm_var,0)) dprtm,
       sum(decode(event,'direct path read',  round(time_waited_micro/1000) ,0)) prevdpr_tm,
       sum(decode(event,'direct path read',  total_waits - &prevdpr_ct_var,0)) dprct,
       sum(decode(event,'direct path read',  total_waits ,0)) prevdpr_ct,
       sum(decode(event,'direct path write',  round(time_waited_micro/1000) - &prevdpw_tm_var,0)) dpwtm,
       sum(decode(event,'direct path write',  round(time_waited_micro/1000) ,0)) prevdpw_tm,
       sum(decode(event,'direct path write',  total_waits - &prevdpw_ct_var,0)) dpwct,
       sum(decode(event,'direct path write',  total_waits ,0)) prevdpw_ct,
       sum(decode(event,'direct path write temp',  round(time_waited_micro/1000) - &prevdpwt_tm_var,0)) dpwttm,
       sum(decode(event,'direct path write temp',  round(time_waited_micro/1000) ,0)) prevdpwt_tm,
       sum(decode(event,'direct path write temp',  total_waits - &prevdpwt_ct_var,0)) dpwtct,
       sum(decode(event,'direct path write temp',  total_waits ,0)) prevdpwt_ct,
       sum(decode(event,'direct path read temp',  round(time_waited_micro/1000) - &prevdprt_tm_var,0)) dprttm,
       sum(decode(event,'direct path read temp',  round(time_waited_micro/1000) ,0)) prevdprt_tm,
       sum(decode(event,'direct path read temp',  total_waits - &prevdprt_ct_var,0)) dprtct,
       sum(decode(event,'direct path read temp',  total_waits ,0)) prevdprt_ct,
       to_char(sysdate,'SSSSS')-&prevsec_var delta,
       to_char(sysdate,'SSSSS') prevsec
from
     v$system_event
where
     event in ('db file sequential read',
               'db file scattered read',
               'direct path read temp',
               'direct path write temp',
               'direct path read',
               'direct path write',
               'log file parallel write')
) ;
   