col name                format a45
col value               format a18
col isdefault           format a5
col issess_modifiable   format a5
col issys_modifiable    format a10
col description         format a80 

SELECT NAME, VALUE, isdefault, /*isbasic "Basic", -- for 11g only */ isses_modifiable, issys_modifiable,description
  FROM v$parameter
 WHERE NAME LIKE NVL ('%&parameter_name%', NAME);
