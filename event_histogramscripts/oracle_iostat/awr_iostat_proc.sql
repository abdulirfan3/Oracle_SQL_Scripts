drop table awr_iostat_tab;

create table awr_iostat_tab(
t_timestamp timestamp,
t_triops number(10,2),
t_twiops number(10,2), 
t_ttiops number(10,2), 
t_ariops number(10,2),
t_awiops number(10,2), 
t_atiops number(10,2), 
t_sbrq number(10,2), 
t_mbrq number(10,2),
t_sbwq number(10,2),
t_mbwq number(10,2),
t_trmbps number(10,2), 
t_twmbps number(10,2), 
t_ttmbps number(10,2), 
t_armbps number(10,2),
t_awmbps number(10,2),
t_atmbps number(10,2), 
t_cr number(10,2),
t_dr number(10,2),
t_tr number(10,2), 
t_cw number(10,2),
t_dw number(10,2),
t_tw number(10,2)) tablespace users;

grant select on awr_iostat_tab to public;

create or replace procedure awr_iostat (v_ssnap IN number,v_esnap IN number) is
cursor s_c1 is select begin_interval_time,snap_id from dba_hist_snapshot
where snap_id>=v_ssnap and snap_id <=v_esnap order by snap_id;

type b_c1 is ref cursor;
c_v1 b_c1;
b_v1 c_v1%type;

b_snapid number;
b_stat_name varchar2(100);
b_value number;

/*cursor b_c1 is
select snap_id,stat_name,value from dba_hist_sysstat a, dba_hist_snapshot b
where stat_name in ('physical read total IO requests',
	       'physical write total IO requests',
	       'redo writes',
           'physical read IO requests',
           'physical write IO requests',
	       'physical read total multi block requests',
	       'physical write total multi block requests',
	       'physical read total bytes',
           'physical write total bytes',
           'redo size',
           'physical read bytes',
           'physical write bytes',
		   'physical reads cache',
		   'physical reads direct',
		   'physical reads direct temporary tablespace',
		   'physical writes from cache',
		   'physical writes direct',
		   'physical writes direct temporary tablespace')
and			snap_id=;
*/
		   
b_prtir 	number;
b_pwtir 	number;
b_rw 		number;
b_prir 		number;
b_pwir 		number;
b_prtmbr	number;
b_pwtmbr 	number;
b_prtb 		number;
b_pwtb 		number;
b_rs 	    number;
b_prb		number;
b_pwb		number;
b_prc		number;
b_prd		number;
b_prdtt		number;
b_pwc		number;
b_pwd		number;
b_pwdtt		number;
b_interval timestamp;

a_prtir 	number;	
a_pwtir 	number;	
a_rw 		number;
a_prir 		number;
a_pwir 		number;
a_prtmbr	number;	
a_pwtmbr 	number;	
a_prtb 		number;
a_pwtb 		number;
a_rs 	    number;	
a_prb		number;
a_pwb		number;
a_prc		number;
a_prd		number;
a_prdtt		number;
a_pwc		number;
a_pwd		number;
a_pwdtt		number;
a_interval timestamp;

t_triops 	number;	-- Total Read IOPS 
t_twiops 	number;	--Total Write IOPS 
t_ttiops	number; --Total IOPS 
t_ariops    number; --App Read IOPS
t_awiops 	number; --App Write IOPS 
t_atiops	number; --App total IOPS 
t_sbrq      number; --Single block read request 
t_mbrq  	number;	--Multi block read request 
t_sbwq  	number;	--Single block write request
t_mbwq 		number; --Multi block write reqeust 
t_trmbps	number; --Total READ MBPS 
t_twmbps    number;	--Total Writes MBPS 
t_ttmbps	number;--Total MBPS 
t_armbps	number;--App Read MBPS 
t_awmbps	number;--App Write MBPS 
t_atmbps    number;--App Total MBPS 
t_cr		number;
t_dr		number;
t_tr		number;
t_cw		number;
t_dw		number;
t_tw		number;
v_interval number;

blksize number;

i number := 0;

begin

execute immediate 'truncate table awr_iostat_tab';
select value into blksize
from v$parameter
where name = 'db_block_size';

for s_v1 in s_c1 loop
--close c_v1;
	open c_v1 for 	select snap_id,stat_name,value from dba_hist_sysstat
					where stat_name in ('physical read total IO requests',
				   'physical write total IO requests',
				   'redo writes',
				   'physical read IO requests',
				   'physical write IO requests',
				   'physical read total multi block requests',
				   'physical write total multi block requests',
				   'physical read total bytes',
				   'physical write total bytes',
				   'redo size',
				   'physical read bytes',
				   'physical write bytes',
				   'physical reads cache',
				   'physical reads direct',
				   'physical reads direct temporary tablespace',
				   'physical writes from cache',
				   'physical writes direct',
				   'physical writes direct temporary tablespace')
				   and snap_id = s_v1.snap_id;
	loop
	fetch c_v1 into b_snapid,b_stat_name,b_value;
    exit when c_v1%notfound;
	
	 
		if    i = 0 then
			b_interval := s_v1.begin_interval_time;
			if    b_stat_name = 'physical read total IO requests'            then b_prtir  	:=b_value;
			elsif b_stat_name = 'physical write total IO requests' 			then b_pwtir 	:=b_value;
			elsif b_stat_name = 'redo writes'   	       					then b_rw		:=b_value;
			elsif b_stat_name = 'physical read IO requests'                  then b_prir		:=b_value;
			elsif b_stat_name = 'physical write IO requests'                 then b_pwir		:=b_value;
			elsif b_stat_name = 'physical read total multi block requests'   then b_prtmbr	:=b_value;
			elsif b_stat_name = 'physical write total multi block requests'  then b_pwtmbr	:=b_value;
			elsif b_stat_name = 'physical read total bytes'               	then b_prtb		:=b_value;
			elsif b_stat_name = 'physical write total bytes'                 then b_pwtb		:=b_value;
			elsif b_stat_name = 'redo size'                            	    then b_rs 		:=b_value;
			elsif b_stat_name = 'physical read bytes'                        then b_prb		:=b_value;
			elsif b_stat_name = 'physical write bytes'                       then b_pwb		:=b_value;
			elsif b_stat_name = 'physical reads cache'						then b_prc		:=b_value;
			elsif b_stat_name = 'physical reads direct'						then b_prd		:=b_value;
			elsif b_stat_name = 'physical reads direct temporary tablespace' then b_prdtt	:=b_value;
			elsif b_stat_name = 'physical writes from cache'					then b_pwc		:=b_value;
			elsif b_stat_name = 'physical writes direct'						then b_pwd		:=b_value;
			elsif b_stat_name = 'physical writes direct temporary tablespace' then b_pwdtt	:=b_value;
			end if;
			--dbms_output.put_line('abc' || b_snapid ||' '|| a_interval || ' ' || b_interval || ' '|| i );
		else
			a_interval :=  s_v1.begin_interval_time;
			select ((extract(hour from (a_interval-b_interval))*3600)+ 
			        (extract(minute from (a_interval-b_interval))*60)+
					(extract(second from (a_interval-b_interval)*60))
				   )
 			into v_interval from dual;
			--dbms_output.put_line(b_snapid ||' '|| a_interval || ' ' || b_interval || ' ' || ' ' || v_interval || ' ' || i);
			if    b_stat_name = 'physical read total IO requests'            then a_prtir  	:=b_value;
			elsif b_stat_name = 'physical write total IO requests' 			then a_pwtir 	:=b_value;
			elsif b_stat_name = 'redo writes'   	       						then a_rw		:=b_value;
			elsif b_stat_name = 'physical read IO requests'                  then a_prir		:=b_value;
			elsif b_stat_name = 'physical write IO requests'                 then a_pwir		:=b_value;
			elsif b_stat_name = 'physical read total multi block requests'   then a_prtmbr	:=b_value;
			elsif b_stat_name = 'physical write total multi block requests'  then a_pwtmbr	:=b_value;
			elsif b_stat_name = 'physical read total bytes'               	then a_prtb		:=b_value;
			elsif b_stat_name = 'physical write total bytes'                 then a_pwtb		:=b_value;
			elsif b_stat_name = 'redo size'                            	    then a_rs 		:=b_value;
			elsif b_stat_name = 'physical read bytes'                        then a_prb		:=b_value;
			elsif b_stat_name = 'physical write bytes'                       then a_pwb		:=b_value;
			elsif b_stat_name = 'physical reads cache'						then a_prc		:=b_value;
			elsif b_stat_name = 'physical reads direct'						then a_prd		:=b_value;
			elsif b_stat_name = 'physical reads direct temporary tablespace' then a_prdtt	:=b_value;
			elsif b_stat_name = 'physical writes from cache'					then a_pwc		:=b_value;
			elsif b_stat_name = 'physical writes direct'						then a_pwd		:=b_value;
			elsif b_stat_name = 'physical writes direct temporary tablespace' then a_pwdtt	:=b_value;
			end if;
		end if;
			--IOPS--
			
	end loop;
	
	if i >0  then
			t_triops := round(((a_prtir - b_prtir)/(1*v_interval)));					-- Total Read IOPS 
			t_twiops := round((((a_pwtir + a_rw) - (b_pwtir + b_rw))/(1*v_interval)));	--Total Write IOPS 
			t_ttiops := round((t_triops + t_twiops));							--Total IOPS 
			t_ariops := round(((a_prir - b_prir)/(1*v_interval)));    					--App Read IOPS
			t_awiops := round((((a_pwir + a_rw) - (b_pwir + b_rw))/(1*v_interval)));	--App Write IOPS 
			t_atiops := round((t_ariops + t_awiops),1);          					--App total IOPS 
			t_sbrq   := round((((a_prtir - a_prtmbr) - (b_prtir - b_prtmbr))/(1*v_interval)));    --Single block read request 
			t_mbrq   := round(((a_prtmbr - b_prtmbr)/(1*v_interval)));					--Multi block read request 
			t_sbwq   := round((((a_pwtir - a_pwtmbr) - (b_pwtir - b_pwtmbr))/(1*v_interval)));  --Single block write request
			t_mbwq 	 := round(((a_pwtmbr - b_pwtmbr)/(1*v_interval)));					--Multi block write reqeust 

			--MBPS--
			t_trmbps := round((a_prtb - b_prtb)/(1024*1024*v_interval));		--Total READ MBPS 
			t_twmbps := round(((a_pwtb + a_rs) - (b_pwtb + b_rs))/(1024*1024*v_interval));     	--Total Writes MBPS 
			t_ttmbps := t_trmbps + t_twmbps;											--Total MBPS 
			t_armbps := round((a_prb - b_prb)/(1024*1024*v_interval));					--App Read MBPS 
			t_awmbps := round(((a_pwb + a_rs) - (b_pwb + b_rs))/(1024*1024*v_interval));		--App Write MBPS 
			t_atmbps := t_armbps + t_awmbps;			    							--App Total MBPS 
			t_cr	 := round(((a_prc - b_prc)*blksize)/(1024*1024*v_interval));
			t_tr	 := round(((a_prdtt - b_prdtt)*blksize)/(1024*1024*v_interval));
			t_dr	 := round(((a_prd - b_prd)*blksize)/(1024*1024*v_interval))-t_tr;
			t_cw	 := round(((a_pwc - b_pwc)*blksize)/(1024*1024*v_interval));
			t_tw     := round(((a_pwdtt - b_pwdtt)*blksize)/(1024*1024*v_interval));
			t_dw	 := round(((a_pwd - b_pwd)*blksize)/(1024*1024*v_interval))-t_tw;
			
			insert into awr_iostat_tab values (a_interval,t_triops,t_twiops,t_ttiops,t_ariops,t_awiops,t_atiops,t_sbrq,t_mbrq,t_sbwq,t_mbwq,t_trmbps,t_twmbps,t_ttmbps,t_armbps,t_awmbps,t_atmbps,t_cr,t_dr, t_tr,t_cw,t_dw,t_tw);
			commit;
	end if;
			
	if i >0 then
	b_prtir 	:=	a_prtir ;
	b_pwtir 	:=	a_pwtir ;
	b_rw 		:=	a_rw ;
	b_prir 		:=	a_prir; 
	b_pwir 		:=	a_pwir ;
	b_prtmbr	:=	a_prtmbr;
	b_pwtmbr 	:=	a_pwtmbr ;
	b_prtb 		:=	a_prtb ;
	b_pwtb 		:=	a_pwtb ;
	b_rs 		:=	a_rs ;
	b_prb		:=	a_prb;
	b_pwb		:=	a_pwb;
	b_prc		:=	a_prc;
	b_prd		:=	a_prd;
	b_prdtt		:=	a_prdtt;
	b_pwc		:=	a_pwc;
	b_pwd		:=	a_pwd;
	b_pwdtt		:=	a_pwdtt;
	b_interval  :=  a_interval;
	end if;
	--close c_v1;
	i :=  i + 1;
end loop;
end;
/

/*

Total Read IOPS = physical read total IO requests
Total Write IOPS = physical write total IO requests + redo writes(lgwr)
Total IOPS = physical read total IO requests + physical write total IO requests + redo writes(lgwr)

App Read IOPS = physical read IO requests
App Write IOPS = physical write IO requests + redo writes(lgwr) 
App total IOPS = physical read IO requests + physical write IO requests + redo writes(lgwr)

Single block read request = physical read total IO requests - physical read total multi block requests
Multi block read request = physical read total multi block requests
Single block write request = physical write total IO requests - physical write total multi block requests
Multi block write reqeust = physical write total multi block requests

Total READ MBPS = physical read total bytes
Total Writes MBPS = physical write total bytes + redo size(lgwr)
Total MBPS = physical read total bytes + physical write total bytes + redo size(lgwr)

App Read MBPS = physical read bytes
App Write MBPS = physical write bytes + redo size
App Total MBPS = physical read bytes + physical write bytes + redo size

Breakdown by type like buffer cache direct or temporary direct

Cache reads = physical reads cache * blksize
Direct reads = physical reads direct * blksize - temp reads
Temp reads = physical reads direct temporary tablespace  * blksize

Cache writes = physical writes from cache * blksize
Direct writes = physical writes direct * blksize - temp writes
Temp writes = physical writes direct temporary tablespace  * blksize

--SRVR read IOPS = physical read IO requests
--SRVR read MBPS = physical reads

--DBWR+SRVR write IOPS = physical write IO requests(dbwr+srvr)
--DBWR+SRVR write MBPS = physical writes(dbwr+srvr)

--LGWR write IOPS = redo writes
--LGWR write MBPS = redo size

physical read bytes: 						Total size in bytes of all disk reads by application activity (and not other instance activity) only.
--physical read flash cache hits: 			Total number of reads from flash cache instead of disk
physical read IO requests:		 			Number of read requests for application activity (mainly buffer cache and direct load operation) which read one or more database blocks per request. This is a subset of "physical read total IO requests" statistic.

physical read total bytes:			 		Total size in bytes of disk reads by all database instance activity including application reads, backup and recovery, and other utilities. The difference between this value and "physical read bytes" gives the total read size in bytes by non-application workload.
physical read total IO requests:	 		Number of read requests which read one or more database blocks for all instance activity including application, backup and recovery, and other utilities. The difference between this value and "physical read total multi block requests" gives the total number of single block read requests.
physical read total multi block requests:	Total number of Oracle instance read requests which read in two or more database blocks per request for all instance activity including application, backup and recovery, and other utilities.

physical reads:								Total number of data blocks read from disk. This value can be greater than the value of "physical reads direct" plus "physical reads cache" as reads into process private buffers also included in this statistic.
physical reads cache:	 					Total number of data blocks read from disk into the buffer cache. This is a subset of "physical reads" statistic.
physical reads direct:	 					Number of reads directly from disk, bypassing the buffer cache. For example, in high bandwidth, data-intensive operations such as parallel query, reads of disk blocks bypass the buffer cache to maximize transfer rates and to prevent the premature aging of shared data blocks resident in the buffer cache.
physical reads direct temporary tablespace  


physical write bytes: 						Total size in bytes of all disk writes from the database application activity (and not other kinds of instance activity).
physical write IO requests:					Number of write requests for application activity (mainly buffer cache and direct load operation) which wrote one or more database blocks per request.
physical write total bytes:					Total size in bytes of all disk writes for the database instance including application activity, backup and recovery, and other utilities. The difference between this value and "physical write bytes" gives the total write size in bytes by non-application workload.
physical write total IO requests:			Number of write requests which wrote one or more database blocks from all instance activity including application activity, backup and recovery, and other utilities. The difference between this stat and "physical write total multi block requests" gives the number of single block write requests.
physical write total multi block requests:	Total number of Oracle instance write requests which wrote two or more blocks per request to the disk for all instance activity including application activity, recovery and backup, and other utilities.

physical writes:							Total number of data blocks written to disk. This statistics value equals the sum of "physical writes direct" and "physical writes from cache" values.
physical writes direct:						Number of writes directly to disk, bypassing the buffer cache (as in a direct load operation)
physical writes from cache:					Total number of data blocks written to disk from the buffer cache. This is a subset of "physical writes" statistic.
physical writes direct temporary tablespace


*/

