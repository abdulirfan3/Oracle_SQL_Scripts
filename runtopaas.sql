--
--   TOPAAS
--   Copyright: Marcin Przepiorowski - All rights reserved.
--
-- Special thanks go to Tanel Poder and Adrian Billington for idea of real time screen refresh in SQL*Plus window and PL/SQL collection based on internal Oracle package.
--
-- runtopaas is displaying Oracle Average Active Session calculated based on v$session samples. It is read only and doesn't need any objects inside database.
-- It is sampling data using v$session so it will work on Standard and Enterprise Edition without any additional packs.
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


prompt "Waiting for first refresh"
set term off
DEFINE _OLD_ONCPU   = ""
DEFINE _OLD_USERIO   = ""
DEFINE _OLD_OTHER   = ""
DEFINE _OLD_AAS_TIME   = ""
DEFINE _OLD_RUNMAX = "0"


col ifdefcpu noprint new_value _OLD_ONCPU
col ifdefio noprint new_value _OLD_USERIO
col ifdefother noprint new_value _OLD_OTHER
col ifdefaastime noprint new_value _OLD_AAS_TIME
col ifdefrunmax noprint new_value _OLD_RUNMAX

select :on_cpu ifdefcpu from dual;
select :aas_time ifdefaastime from dual;
select :user_io ifdefio from dual;
select :other ifdefother from dual;
select :runmax ifdefrunmax from dual;


var on_cpu varchar2(1000);
var aas_time varchar2(1000);
var user_io varchar2(1000);
var other varchar2(1000);
var runmax number;
var usermax number; 
var refresh number; 
--def refresh = 15;


declare
reset number;

procedure read_commandline is 
begin
   for c in (select * from (select level l, substr('&&1',instr('&&1',':',1,level)+1, decode(instr('&&1',':',1,level+1),0,length('&&1'),instr('&&1',':',1,level+1)-instr('&&1',':',1,level)-1)) conf
from  dual connect by instr('&&1',':',1,level) > 0) where conf<>'aas') loop
      if (lower(c.conf) like 'reset') then
        reset:=1;
      else 
        reset := 0;
	case c.l 
	 when 1 then :refresh:=to_number(c.conf);
         when 2 then :usermax:=to_number(c.conf);
         else null;
	end case;
      end if;
   end loop;
end read_commandline;

begin
read_commandline;
--dbms_output.put_line(nvl(length('&&_OLD_ONCPU'),'0'));
--dbms_output.put_line('&&_OLD_ONCPU');
--  select count(*) into reset from dual where '&&1' like 'reset'; 
  if reset = 0 then
      if nvl(length('&&_OLD_ONCPU'),'0') != 0 then
   	 :on_cpu := '&&_OLD_ONCPU' ;
         :aas_time := '&&_OLD_AAS_TIME' ;
         :user_io := '&&_OLD_USERIO';
         :other := '&&_OLD_OTHER';
         :runmax := '&&_OLD_RUNMAX';
      end if;
  else
      :on_cpu := '';
      :aas_time := '' ;
      :user_io := '';
      :other := '';
      :runmax := ''; 
  end if;
end;
/

set term on

set serveroutput on format wrapped
set linesize 150
set feedback off
set ver off

@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
@topaas
