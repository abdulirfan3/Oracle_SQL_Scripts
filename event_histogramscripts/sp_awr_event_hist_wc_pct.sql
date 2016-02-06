drop table awr_event_histogram_wc_pct;

create table awr_event_histogram_wc_pct(
event varchar2(64),
t_timestamp timestamp,
tot_wait_count number,
t_1 number(10,2),
t_2 number(10,2), 
t_4 number(10,2), 
t_8 number(10,2),
t_16 number(10,2), 
t_32 number(10,2), 
t_64 number(10,2), 
t_128 number(10,2),
t_256 number(10,2),
t_512 number(10,2),
t_1024 number(10,2), 
t_2048 number(10,2), 
t_4096 number(10,2), 
t_8192 number(10,2)) tablespace users;

grant select on awr_event_histogram_wc_pct to public;

create or replace procedure sp_awr_event_hist_wc_pct (v_event in varchar2,v_instance in number,v_ssnap IN number,v_esnap IN number) is
cursor s_c1 is select begin_interval_time,snap_id from dba_hist_snapshot
where instance_number=v_instance and snap_id>=v_ssnap and snap_id <=v_esnap order by snap_id;

type b_c1 is ref cursor;
c_v1 b_c1;
b_v1 c_v1%type;

b_snapid number;
b_wait_time_milli varchar2(100);
b_wait_count number;

		   
b_1 		number;
b_2 		number;
b_4 		number;
b_8			number;
b_16 		number;
b_32		number;
b_64 		number;
b_128 		number;
b_256 		number;
b_512 	    number;
b_1024		number;
b_2048		number;
b_4096		number;
b_8192		number;
b_interval timestamp;


a_1 		number;
a_2 		number;
a_4 		number;
a_8			number;
a_16 		number;
a_32		number;
a_64 		number;
a_128 		number;
a_256 		number;
a_512 	    number;
a_1024		number;
a_2048		number;
a_4096		number;
a_8192		number;
a_interval timestamp;

t_t 		number;
t_1 		number;
t_2 		number;
t_4 		number;
t_8			number;
t_16 		number;
t_32		number;
t_64 		number;
t_128 		number;
t_256 		number;
t_512 	    number;
t_1024		number;
t_2048		number;
t_4096		number;
t_8192		number;

v_interval number;


i number := 0;

begin

execute immediate 'truncate table awr_event_histogram_wc_pct';


for s_v1 in s_c1 loop
	open c_v1 for 	select snap_id,wait_time_milli,wait_count from dba_hist_event_histogram
					where instance_number=v_instance
					and   event_name=v_event
				    and snap_id = s_v1.snap_id;
				   --and inst_id=(select inst_id from gv$instance where instance_name= (select instance_name from v$instance));
	loop
	fetch c_v1 into b_snapid,b_wait_time_milli,b_wait_count;
    exit when c_v1%notfound;
	
		if    i = 0 then
			b_interval := s_v1.begin_interval_time;
			if  	  b_wait_time_milli = 1						            then b_1	  	:=b_wait_count;
				elsif b_wait_time_milli = 2						            then b_2	  	:=b_wait_count;
				elsif b_wait_time_milli = 4						            then b_4	  	:=b_wait_count;
				elsif b_wait_time_milli = 8						            then b_8	  	:=b_wait_count;
				elsif b_wait_time_milli = 16						        then b_16	  	:=b_wait_count;
				elsif b_wait_time_milli = 32						        then b_32	  	:=b_wait_count;
				elsif b_wait_time_milli = 64						        then b_64	  	:=b_wait_count;
				elsif b_wait_time_milli = 128						        then b_128	  	:=b_wait_count;
				elsif b_wait_time_milli = 256					            then b_256  	:=b_wait_count;
				elsif b_wait_time_milli = 512					            then b_512  	:=b_wait_count;
				elsif b_wait_time_milli = 1024					            then b_1024  	:=b_wait_count;
				elsif b_wait_time_milli = 2048					            then b_2048  	:=b_wait_count;
				elsif b_wait_time_milli = 4096					            then b_4096  	:=b_wait_count;
				elsif b_wait_time_milli = 8192					            then b_8192  	:=b_wait_count;
			end if;
		else
			a_interval :=  s_v1.begin_interval_time;
			select ((extract(hour from (a_interval-b_interval))*3600)+ 
			        (extract(minute from (a_interval-b_interval))*60)+
					(extract(second from (a_interval-b_interval)*60))
				   )
 			into v_interval from dual;

			if  	  b_wait_time_milli = 1						            then a_1	  	:=b_wait_count;
				elsif b_wait_time_milli = 2						            then a_2	  	:=b_wait_count;
				elsif b_wait_time_milli = 4						            then a_4	  	:=b_wait_count;
				elsif b_wait_time_milli = 8						            then a_8	  	:=b_wait_count;
				elsif b_wait_time_milli = 16						        then a_16	  	:=b_wait_count;
				elsif b_wait_time_milli = 32						        then a_32	  	:=b_wait_count;
				elsif b_wait_time_milli = 64						        then a_64	  	:=b_wait_count;
				elsif b_wait_time_milli = 128						        then a_128	  	:=b_wait_count;
				elsif b_wait_time_milli = 256					            then a_256  	:=b_wait_count;
				elsif b_wait_time_milli = 512					            then a_512  	:=b_wait_count;
				elsif b_wait_time_milli = 1024					            then a_1024  	:=b_wait_count;
				elsif b_wait_time_milli = 2048					            then a_2048  	:=b_wait_count;
				elsif b_wait_time_milli = 4096					            then a_4096  	:=b_wait_count;
				elsif b_wait_time_milli = 8192					            then a_8192  	:=b_wait_count;
			end if;
		end if;
			--IOPS--
			
	end loop;
	
	if i >0  then
		t_t     := (a_1-b_1)+(a_2-b_2)+(a_4-b_4)+(a_8-b_8)+(a_16-b_16)+(a_32-b_32)+(a_64-b_64)+(a_128-b_128)+(a_256-b_256)+(a_512-b_512)+(a_1024-b_1024)+(a_2048-b_2048)+(a_4096-b_4096)+(a_8192-b_8192);
		if t_t = 0 then 
		insert into awr_event_histogram_wc_pct values (v_event,a_interval,t_t,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
		commit;
		else
		t_1 	:= round((a_1    - b_1)*100/t_t);
		t_2 	:= round((a_2    - b_2)*100/t_t);
		t_4 	:= round((a_4    - b_4)*100/t_t);
		t_8 	:= round((a_8    - b_8)*100/t_t);
		t_16 	:= round((a_16   - b_16)*100/t_t);
		t_32 	:= round((a_32   - b_32)*100/t_t);
		t_64 	:= round((a_64   - b_64)*100/t_t);
		t_128 	:= round((a_128  - b_128)*100/t_t);
		t_256 	:= round((a_256  - b_256)*100/t_t);
		t_512 	:= round((a_512  - b_512)*100/t_t);
		t_1024 	:= round((a_1024 - b_1024)*100/t_t);
		t_2048 	:= round((a_2048 - b_2048)*100/t_t);
		t_4096 	:= round((a_4096 - b_4096)*100/t_t);
		t_8192 	:= round((a_8192 - b_8192)*100/t_t);	
		insert into awr_event_histogram_wc_pct values (v_event,a_interval,t_t,t_1,t_2,t_4,t_8,t_16,t_32,t_64,t_128,t_256,t_512,t_1024,t_2048,t_4096,t_8192);
		commit;
	end if;
	end if;
			
	if i >0 then
	b_1 		:=	a_1 ;
	b_2 		:=	a_2 ;
	b_4 		:=	a_4 ;
	b_8 		:=	a_8; 
	b_16		:=	a_16 ;
	b_32		:=	a_32;
	b_64 		:=	a_64 ;
	b_128		:=	a_128 ;
	b_256 		:=	a_256 ;
	b_512 		:=	a_512 ;
	b_1024		:=	a_1024;
	b_2048		:=	a_2048;
	b_4096		:=	a_4096;
	b_8192		:=	a_8192;
	b_interval  :=  a_interval;
	end if;
	--close c_v1;
	i :=  i + 1;
end loop;
end;
/


