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