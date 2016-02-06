create or replace procedure sp_event_histogram_wc (v_event varchar2,v_interval IN number,v_header IN number) is
cursor b_c1 is
select event,wait_time_milli,wait_count from v$event_histogram
where event = v_event;
		   
cursor a_c1 is
select event,wait_time_milli,wait_count from v$event_histogram
where event = v_event;

b_1 		number :=0;
b_2 		number :=0;
b_4 		number :=0;
b_8			number :=0;
b_16 		number :=0;
b_32		number :=0;
b_64 		number :=0;
b_128 		number :=0;
b_256 		number :=0;
b_512 	    number :=0;
b_1024		number :=0;
b_2048		number :=0;
b_4096		number :=0;
b_8192		number :=0;



a_1 		number :=0;
a_2 		number :=0;
a_4 		number :=0;
a_8			number :=0;
a_16 		number :=0;
a_32		number :=0;
a_64 		number :=0;
a_128 		number :=0;
a_256 		number :=0;
a_512 	    number :=0;
a_1024		number :=0;
a_2048		number :=0;
a_4096		number :=0;
a_8192		number :=0;
t_t 		number :=0;
t_1 		number :=0;
t_2 		number :=0;
t_4 		number :=0;
t_8			number :=0;
t_16 		number :=0;
t_32		number :=0;
t_64 		number :=0;
t_128 		number :=0;
t_256 		number :=0;
t_512 	    number :=0;
t_1024		number :=0;
t_2048		number :=0;
t_4096		number :=0;
t_8192		number :=0;

begin



if v_header = 1 then
dbms_output.put_line('---------------------------------------------------------------Percent Wait Count-------------------------------------------------------------------------------|' );
dbms_output.put_line('Event                    |Time                |<1    |<2    |<4    |<8    |<16   |<32   |<64   |<128  |<256  |<512  |<1024 |<2048 |<4096 |<8192 |Tot Wait Count |' );
dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------------------------------|' );
end if;

for b_v1 in b_c1 loop
	if    b_v1.wait_time_milli = 1						            then b_1	  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 2						            then b_2	  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 4						            then b_4	  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 8						            then b_8	  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 16						            then b_16	  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 32						            then b_32	  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 64						            then b_64	  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 128						        then b_128	  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 256					            then b_256  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 512					            then b_512  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 1024					            then b_1024  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 2048					            then b_2048  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 4096					            then b_4096  	:=b_v1.wait_count;
	elsif b_v1.wait_time_milli = 8192					            then b_8192  	:=b_v1.wait_count;
	end if;
end loop;

dbms_lock.sleep(v_interval);

for a_v1 in a_c1 loop
	if    a_v1.wait_time_milli = 1						            then a_1	  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 2						            then a_2	  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 4						            then a_4	  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 8						            then a_8	  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 16						            then a_16	  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 32						            then a_32	  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 64						            then a_64	  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 128						        then a_128	  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 256					            then a_256  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 512					            then a_512	 	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 1024					            then a_1024  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 2048					            then a_2048  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 4096					            then a_4096  	:=a_v1.wait_count;
	elsif a_v1.wait_time_milli = 8192					            then a_8192  	:=a_v1.wait_count;
	end if;
end loop;


t_t     := ((a_1-b_1)+(a_2-b_2)+(a_4-b_4)+(a_8-b_8)+(a_16-b_16)+(a_32-b_32)+(a_64-b_64)+(a_128-b_128)+(a_256-b_256)+(a_512-b_512)+(a_1024-b_1024)+(a_2048-b_2048)+(a_4096-b_4096)+(a_8192-b_8192));


if t_t = 0 then t_t := 1;
end if;

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

dbms_output.put_line (	rpad(v_event,25,' ')        ||
                        '|' || rpad(to_char(sysdate,'MM/DD/YY HH24:MI:SS'),20,' ') ||
                        '|' || lpad(t_1,6,' ') 	    || 
						'|' || lpad(t_2,6,' ') 	    || 
						'|' || lpad(t_4,6,' ') 	    || 
						'|' || lpad(t_8,6,' ')      || 
						'|' || lpad(t_16,6,' ')     ||
						'|' || lpad(t_32,6,' ')     || 
						'|' || lpad(t_64,6,' ')     || 
						'|' || lpad(t_128,6,' ')    || 
						'|' || lpad(t_256,6,' ')    || 
						'|' || lpad(t_512,6,' ')    ||
						'|' || lpad(t_1024,6,' ')   ||
						'|' || lpad(t_2048,6,' ')   || 
						'|' || lpad(t_4096,6,' ')   || 
						'|' || lpad(t_8192,6,' ')   ||
						'|' || lpad(t_t,15,' ')     || '|'
                     );


end;
/

