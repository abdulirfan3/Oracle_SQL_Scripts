----------------------------------------------------------------------------------------
--
-- File name:   translation_logon_trigger.sql
--
-- Purpose:     Set up translation framework
--
-- Author:      Kerry Osborne
--
-- Usage:       This script creates a logon trigger to set the 10601 event and assign
--              SQL Translator Profile sys.FOO. The trigger can be limited to a set of
--              user accounts by uncommenting the WHEN clause. Note that the 10601 event
--              could be set at the system level as well. Turing off the event can be 
--              done with the following syntax:
--
--              alter system set events '10601 trace name context off';
--
--              Note that SQL Translation Profile sys.FOO must exist.
--              SQLs that are not mapped will be passed through without modification. 
--              There is however a bug in 12cR1 that causes the SQL_ID and HASH_VALUE to 
--              be calculated incorrectly for statements that are passed through without
--              translation. 
---------------------------------------------------------------------------------------

create or replace trigger translate_logon_trigger
  after logon on database
-- when (user in ('KSO', 'HR'))  -- or other users to be included

declare

  -- Trace commands
  stp    varchar2(256)   := 'alter session set sql_translation_profile = sys.FOO';
  xyz    varchar2(256)   := 'alter session set events = '''||'10601 trace name context forever, level 32'||'''';

begin

    -- Start the traces
    execute immediate stp;
    execute immediate xyz;

exception
when others then
null;
end;
/

show errors

prompt
prompt
