alter session set sql_translation_profile = &translation_profile_name;
alter session set events = '10601 trace name context forever, level 32';
