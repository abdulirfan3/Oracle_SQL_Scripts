--
--   TOPAAS
--   Copyright: Marcin Przepiorowski - All rights reserved.
--
-- Special thanks go to Tanel Poder and Adrian Billington for idea of real time screen refresh in SQL*Plus window and PL/SQL collection based on internal Oracle package.
--
-- Usage:
-- runtopaas is displaying Oracle Average Active Session calculated based on v$session samples
-- This tool is using two scripts:
-- runtopaas.sql - is a main script to parse run attributes and specify a run environment for topaas.sql script. It is calling topaas.sql 100 times 
-- topaas.sql - is sampling v$session every 1 s for time specified in refresh rate parameters and keep it in PL/SQL collection 
--              At the end AAS (divided into 3 sections: CPU, Disk I/O and other) is calculated and displayed on screen. 
--              In addition to that AAS results are added to bind variables together with sample time.
--              When topaas.sql is called next time it is reading data from bind variables and it allow it to have history of AAS from past and display 
--              it on screen. Default configuration allow to display 100 data point
--
-- Usage:
-- Change SQL*Plus window / screen terminal to 45 characters height and 150 characters wide
-- Run in SQL*Plus window:
-- 
-- @runtopaas.sql aas:<refresh rate>  - it will specify refresh rate (ex. 15 s) and with 100 samples it allow to keep 25 min of AAS in SQL*Plus window.
--                                      If script will be started again after 100 cycles or after user break in this same session it will still be able to display historical data
-- @runtopaas.sql aas:<refresh rate>:reset - like above but historical data are cleared
-- @runtopaas.sql aas:<refresh rate>:<max aas> - like above but maximum value of AAS (y axis) is set by user
-- @runtopaas.sql aas:<refresh rate>:<max aas>:reset - like above but historical data are cleared

-- RUN RUNTOPAAS.SQL NOT THIS SCRIPT

 declare
 type type_lines is table of varchar2(200) index by pls_integer;
 lines type_lines;
 
 screen_hight number := 40;
 axe_y_hight number := 20;
 y_offset number := 4;
 no_disp_samples number := 80;
 maxrun number; -- := 10;
 cpu_count number;
 
 procedure shift_data is
 begin
  if (instr(:on_cpu,',',1,no_disp_samples)>0) then
     :on_cpu := substr(:on_cpu,instr(:on_cpu,',',1,1)+1);
     :user_io:= substr(:user_io,instr(:user_io,',',1,1)+1);
     :other:= substr(:other,instr(:other,',',1,1)+1);
     :aas_time := substr(:aas_time,instr(:aas_time,',',1,1)+1);
  end if;
 end;
 
 procedure fill_lines(line varchar2) is
    aassize number;
 begin
    aassize := length(line);
    if (aassize > 0) then
        for j in 1+y_offset..screen_hight+y_offset loop
            if  ((j<=aassize+y_offset) and (j<=axe_y_hight+y_offset)) then
                lines(j) := lines(j) || substr(line,j-y_offset,1);
            else 
                lines(j) := lines(j) || ' ';        
            end if;
        end loop;
    else
        for j in 1+y_offset..screen_hight+y_offset loop
            lines(j) := lines(j) || ' ';        
        end loop;
    end if;
 end; -- fill_lines
 
 procedure create_x_axe is
 begin 
    lines(y_offset) := '             ' || lpad('-',no_disp_samples,'-');
 end create_x_axe;
 
 procedure create_y_axe(maxaas number) is
 y_cpu number;
 tick number;
 ytick number;
 begin
    
    tick := (axe_y_hight / maxaas);
    --y_cpu := cpu_count*axe_y_hight/maxaas+y_offset;
    y_cpu := cpu_count*tick+y_offset;
    --dbms_output.put_line(' tick - ' || tick);
    if (tick <= 1) then
        ytick := 3;
    else 
        ytick := tick;
    end if;
    --dbms_output.put_line(' ytick - ' || ytick);
    for j in 1+y_offset..axe_y_hight+y_offset loop
      --lines(j) := lines(j) || '            |';
      if (mod((j-y_offset),round(ytick)) = 0) then 
        lines(j) :=  '  ' || to_char((j-y_offset)/tick,'99999') || '    |' || lines(j) ;
      else 
        lines(j) := '            |' || lines(j);
      end if;     
    end loop;
    --lines(axe_y_hight+2) := '  ' || to_char(maxaas,'99999') || substr(lines(axe_y_hight+2), length(to_char(maxaas,'99999'))+1+2);
    lines(axe_y_hight+2+y_offset) := '  ' || to_char(maxaas,'99999');
    lines(axe_y_hight+3+y_offset) := '   Max AAS   ';
    lines(axe_y_hight+5+y_offset) := '   Refresh rate / Column size ' || :refresh || ' sec';
    if (trunc(y_cpu) <= axe_y_hight+y_offset) then
        lines(trunc(y_cpu)) := 'cpu' || substr(lines(trunc(y_cpu)), 4);
    end if;
 end; -- create_y_axe
 
 
 procedure reset_lines is
 begin
    for i in 1..screen_hight+y_offset loop
       lines(i) := ''; 
    end loop;
 end reset_lines;   
 
 procedure sash (sleep number, refresh_rate number) is 
  start_time date;
  g_aas sys.dbms_debug_vc2coll := new sys.dbms_debug_vc2coll();
  g_cats sys.dbms_debug_vc2coll := new sys.dbms_debug_vc2coll('ON CPU','Disk','Other');

 begin
  for i in 1..refresh_rate loop
      for f in (select case wait_class 
        when 'Other' then 'Other' 
        when 'Application' then 'Other'
        when 'Configuration' then 'Other' 
        when 'Administrative' then 'Other' 
        when 'Concurrency' then 'Other' 
        when 'Commit' then 'Other' 
        when 'Network' then 'Other' 
        when 'User I/O' then 'Disk' 
        when 'System I/O' then 'Disk' 
        when 'Scheduler' then 'Other' 
        when 'Cluster' then 'Other' 
        when 'Queueing' then 'Other'
        when 'ON CPU' then 'ON CPU'
        end  wait_class,
        cnt
        from (select decode(WAIT_TIME,0,wait_class,'ON CPU') wait_class, count(*) cnt from v$session where nvl(wait_class,'on cpu') <> 'Idle' and sid != (select distinct sid from v$mystat) group by decode(WAIT_TIME,0,wait_class,'ON CPU'))
      ) loop
        g_aas.extend(1);
        g_aas(g_aas.count) := f.wait_class || ',' || f.cnt;
        --dbms_output.put_line(f.wait_class || ',' || f.cnt);
      end loop;
      dbms_lock.sleep(sleep);
  end loop;
  
  for r in (select g.column_value wait_class, nvl(cnt,0) cnt, (sum(nvl(cnt,0)) over ())/15 aas from (
            select substr(t.column_value,0,instr(t.column_value,',',1,1)-1) wait_class, sum(substr(t.column_value,instr(t.column_value,',',1,1)+1)) cnt 
            from table(cast(g_aas as sys.dbms_debug_vc2coll)) t
            group by substr(t.column_value,0,instr(t.column_value,',',1,1)-1)
            ) t, table(cast(g_cats as sys.dbms_debug_vc2coll)) g where t.wait_class(+) = g.column_value
            ) loop
    --dbms_output.put_line('Summary ' || r.wait_class || '-' || r.cnt || ' ass - ' || r.aas);
        case r.wait_class 
            when 'ON CPU' then :on_cpu := :on_cpu || nvl(to_char(r.cnt/(refresh_rate*sleep),'9999.99'),0) || ',';
            when 'Disk' then :user_io := :user_io || nvl(to_char(r.cnt/(refresh_rate*sleep),'9999.99'),0) || ',';
            when 'Other' then :other := :other || nvl(to_char(r.cnt/(refresh_rate*sleep),'9999.99'),0) || ',';
        end case;
  end loop;
  :aas_time:=   :aas_time || to_char(sysdate,'HH24:MI:SS') || ',';
 end sash;
 
 procedure read_data(maxaas in out number) is 
 aas varchar2(1000);
-- maxaas number := 10;
 runmax number := 1; 
 x_axe_tick varchar2(1000) := '             ';
 x_axe_time varchar2(1000) := '             ';
 tick number;
 begin
   
   for r in
   ( select on_cpu_item, user_io_item, aas_time_item, other_item, l, max(other_item+on_cpu_item + user_io_item) over () maxaas from (
       select substr
            ( :on_cpu
            , case when level = 1 then 0 else instr(:on_cpu,',',1,level-1) + 1 end
            , instr(:on_cpu,',',1,level) - case when level = 1 then 1 else instr(:on_cpu,',',1,level-1) + 1 end
            ) on_cpu_item,
            substr
            ( :other
            , case when level = 1 then 0 else instr(:other,',',1,level-1) + 1 end
            , instr(:other,',',1,level) - case when level = 1 then 1 else instr(:other,',',1,level-1) + 1 end
            ) other_item,
            substr
            ( :user_io
            , case when level = 1 then 0 else instr(:user_io,',',1,level-1) + 1 end
            , instr(:user_io,',',1,level) - case when level = 1 then 1 else instr(:user_io,',',1,level-1) + 1 end
            ) user_io_item,            
            substr
            ( :aas_time
            , case when level = 1 then 0 else instr(:aas_time,',',1,level-1) + 1 end
            , instr(:aas_time,',',1,level) - case when level = 1 then 1 else instr(:aas_time,',',1,level-1) + 1 end
            ) aas_time_item,
            level l
       from dual
    connect by INSTR(:user_io, ',', 1, LEVEL)>0
    )
   )
   loop
     tick := (axe_y_hight/greatest(r.maxaas, cpu_count));
     if (:usermax is not null) then 
	runmax:=:usermax;
     else
	runmax:=r.maxaas;
     end if;
     --tick := (axe_y_hight/greatest(4, cpu_count));
     --runmax:=4;
     --dbms_output.put_line('read_data tick ' || tick);  
     --dbms_output.put_line('read_data axe_y_hight ' || axe_y_hight);  
     --dbms_output.put_line('read_data r.maxaas' || r.maxaas);  
     --aas := lpad('#',r.on_cpu_item*axe_y_hight/maxaas,'#') || lpad('D',r.user_io_item*axe_y_hight/maxaas,'D');
     --aas := lpad('#',r.on_cpu_item*tick,'#') || lpad('+',r.user_io_item*tick,'+') || lpad('O',r.other_item*tick,'O');
     aas := lpad('#',round(r.on_cpu_item*tick),'#') || lpad('+',round(r.user_io_item*tick),'+') || lpad('O',round(r.other_item*tick),'O');
     --dbms_output.put_line('lenght - ' || length(aas) || ' on cpu ' || r.on_cpu_item || ' user ' || r.user_io_item || ' multi ' || tick);
     --dbms_output.put_line('lenght - ' || length(aas) || ' on cpu ' || r.on_cpu_item || ' user ' || r.user_io_item || ' multi ' || tick);
     --if ((length(aas)/axe_y_hight*maxaas) > runmax) then
     --   runmax := length(aas)/axe_y_hight*maxaas;
     --end if;
     --if ((length(aas)/tick) > runmax) then
     --   runmax := length(aas)/tick;
     --end if;     
     if (mod(r.l-1,16)=0) then
        x_axe_time := x_axe_time || r.aas_time_item || lpad(' ',16-length(r.aas_time_item));
        --x_axe_tick := x_axe_tick || '+' || lpad(' ',14);
     end if;
     if (mod(r.l-1,8)=0) then
             x_axe_tick := x_axe_tick || '+' || lpad(' ',7);
     end if;
     fill_lines(aas);
     --dbms_output.put_line('aas - ' ||aas);
     --dbms_output.put_line('w perli runmax - ' ||runmax); 
   end loop;
   maxaas := greatest(runmax, cpu_count);
   --maxaas:=4;
   --dbms_output.put_line('po petli runmax - ' ||maxaas || '  ' || cpu_count); 
   create_y_axe(maxaas);
   create_x_axe;
   lines(2):=x_axe_time;
   lines(3):=x_axe_tick;
   --dbms_output.put_line(runmax); 
 end read_data;

 procedure print_legend is
 begin 
     lines(4+y_offset) := substr(lines(4+y_offset), 0, 100) || lpad(' ', 100-length(lines(4+y_offset))) || ' Legend ';
     lines(3+y_offset) := substr(lines(3+y_offset), 0, 100) || lpad(' ', 100-length(lines(3+y_offset))) || ' # - ON CPU ';
     lines(2+y_offset) := substr(lines(2+y_offset), 0, 100) || lpad(' ', 100-length(lines(2+y_offset))) || ' + - Disk I/O ';
     lines(1+y_offset) := substr(lines(1+y_offset), 0, 100) || lpad(' ', 100-length(lines(1+y_offset))) || ' O - Other ';
 end print_legend;
 
 procedure display is
 begin
    print_legend;
    for i in 1..screen_hight loop
        dbms_output.put_line(lines(screen_hight-i+1));
    end loop;
 end;
 
 
 begin    
    reset_lines;
    --select value into cpu_count from v$system_parameter where name = 'cpu_count';
    select sum(value) into cpu_count from (select lag(value) over (order by name) / value value from v$system_parameter where name in ('cpu_count','parallel_threads_per_cpu'));
    maxrun := cpu_count+1;
    if (:usermax is not null) then
       maxrun :=  :usermax;
       cpu_count:=:usermax;
    end if;
    if (:runmax != maxrun) then
        maxrun := :runmax;
    end if;
    --:on_cpu:=   :on_cpu   || to_char(dbms_random.value(0,8),'99.99') || ',';
    --:aas_time:=   :aas_time || to_char(sysdate,'HH24:MI:SS') || ',';
    --:user_io:=  :user_io  || to_char(dbms_random.value(0,20),'99.99') || ','; 
    
    if (:refresh is null) then
	:refresh := 15;
    end if;
    --dbms_output.put_line('maxrun ' || :usermax );
    sash(1,:refresh);
    read_data(maxrun);
    --dbms_output.put_line('maxrun ' || maxrun );
    
    display;
    :runmax := maxrun;
    shift_data;
 end;
 /
 
--@topaas_full.sql
