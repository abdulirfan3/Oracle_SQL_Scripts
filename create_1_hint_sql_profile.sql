----------------------------------------------------------------------------------------
-- SEE DOC at C:\My personal work Related\MY STUFF\perf notes\Single Hint SQL Profiles
--
-- File name:   create_1_hint_sql_profile.sql
--
-- Purpose:     Prompts for a hint and makes a profile out of it.
-
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for four values.
--
--              profile_name: the name of the profile to be attached to a new statement
--
--              sql_id: the sql_id of the statement to attach the profile to 
--                      (the statement must be in the shared pool)
--
--              category: the category to assign to the new profile 
--
--              force_macthing: a toggle to turn on or off the force_matching feature
--
--              hint_text: text to be used as a hint
--
-- Description: This script prompts for a hint. It does not validate the hint. It creates a 
--              SQL Profile with the hint test and attaches it to the provided sql_id.
--              This script should now work with all flavors of 10g and 11g.
--              
-- Updated:     This script now allows inclusion of quoted text in the hint.
--
--              See kerryosborne.oracle-guy.com for additional information.
----------------------------------------------------------------------------------------- 

accept sql_id -
       prompt 'Enter value for sql_id: ' -
       default 'X0X0X0X0'
accept profile_name -
       prompt 'Enter value for profile_name (PROFILE_sqlid_MANUAL): ' -
       default 'X0X0X0X0'
accept category -
       prompt 'Enter value for category (DEFAULT): ' -
       default 'DEFAULT'
accept force_matching -
       prompt 'Enter value for force_matching (false): ' -
       default 'false'
accept hint_txt -
       prompt 'Enter value for hint_text: ' -
       default 'comment'


set feedback off
set sqlblanklines on
set serveroutput on

declare
l_profile_name varchar2(30);
cl_sql_text clob;
l_category varchar2(30);
l_force_matching varchar2(3);
b_force_matching boolean;
begin

select
sql_fulltext
into
cl_sql_text
from
v$sqlarea
where
sql_id = '&&sql_id';

select decode('&&profile_name','X0X0X0X0','PROFILE_'||'&&sql_id'||'_MANUAL','&&profile_name')
into l_profile_name
from dual;

dbms_sqltune.import_sql_profile(
sql_text => cl_sql_text, 
profile => sqlprof_attr(q'[&&hint_txt]'),
category => '&&category',
name => l_profile_name,
-- use force_match => true
-- to use CURSOR_SHARING=SIMILAR
-- behaviour, i.e. match even with
-- differing literals
force_match => &&force_matching
);

dbms_output.put_line(' ');
dbms_output.put_line('Profile '||l_profile_name||' created.');
dbms_output.put_line(' ');

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      dbms_output.put_line(' ');
      dbms_output.put_line('ERROR: SQL_ID: '||'&&sql_id'||' does not exist in v$sqlarea.');
      dbms_output.put_line('The SQL statement must be in the shared pool to use this script.');
      dbms_output.put_line(' ');
end;
/

undef profile_name
undef sql_id
undef category
undef force_matching
undef hint_txt

set sqlblanklines off
set feedback on