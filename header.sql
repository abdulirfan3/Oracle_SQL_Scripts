set echo off
set term off
set timi off



set term off
set trimspool on
set tab off
set feed off
set arraysize 5000
set lines 2500
set pages 5000
set verify off
set sqlblankline on

set serveroutput on


-- Set the terminal output off. Otherwise it puts the blank lines on console for 
-- query executed with noprint option below to version variable


define _IF_ORA_8i_OR_HIGHER="--"
define _IF_ORA_9iR2_OR_HIGHER="--"
define _IF_ORA_10gR1_OR_HIGHER="--"
define _IF_ORA_10gR2_OR_HIGHER="--"
define _IF_ORA_11gR1_OR_HIGHER="--"
define _IF_ORA_11107_OR_HIGHER="--"
define _IF_ORA_11gR2_OR_HIGHER="--"
define _IF_ORA_11202_OR_HIGHER="--"

col oraverion_8i_or_higher        new_value _IF_ORA_8i_OR_HIGHER     noprint
col oraverion_9iR2_or_higher      new_value _IF_ORA_9iR2_OR_HIGHER   noprint
col oraverion_10gR1_or_higher     new_value _IF_ORA_10gR1_OR_HIGHER  noprint
col oraverion_10gR2_or_higher     new_value _IF_ORA_10gR2_OR_HIGHER  noprint
col oraverion_11gR1_or_higher     new_value _IF_ORA_11gR1_OR_HIGHER  noprint
col oraverion_11107_or_higher     new_value _IF_ORA_11107_OR_HIGHER  noprint
col oraverion_11gR2_or_higher     new_value _IF_ORA_11gR2_OR_HIGHER  noprint
col oraverion_11202_or_higher     new_value _IF_ORA_11202_OR_HIGHER  noprint

/*
set feed off
WITH ver AS
    (select banner
          , instr(banner, 'Release ')+8 start_pos
       FROM v$version
      WHERE rownum = 1
    )
, ver2 as 
    (select ver.banner
         , instr(banner,'.', start_pos , 2) - start_pos ver_length
         , start_pos
      from ver
    )
, ver3 as 
   ( select CAST (SUBSTR(banner,start_pos,ver_length) AS NUMBER) ver
     FROM ver2
    )
SELECT CASE WHEN ver >= 8.1  THEN '' ELSE '--' END oraverion_8i_or_higher
     , CASE WHEN ver >= 9.2  THEN '' ELSE '--' END oraverion_9iR2_or_higher
     , CASE WHEN ver >= 10.1 THEN '' ELSE '--' END oraverion_10gR1_or_higher
     , CASE WHEN ver >= 10.2 THEN '' ELSE '--' END oraverion_10gR2_or_higher
     , CASE WHEN ver >= 11.1 THEN '' ELSE '--' END oraverion_11gR1_or_higher
     , CASE WHEN ver >= 11.2 THEN '' ELSE '--' END oraverion_11gR2_or_higher
  FROM ver3;
set feed on
*/

SELECT CASE WHEN &&_O_RELEASE >= 0801000000 THEN '' ELSE '--' END oraverion_8i_or_higher
     , CASE WHEN &&_O_RELEASE >= 0902000000 THEN '' ELSE '--' END oraverion_9iR2_or_higher
     , CASE WHEN &&_O_RELEASE >= 1001000000 THEN '' ELSE '--' END oraverion_10gR1_or_higher
     , CASE WHEN &&_O_RELEASE >= 1002000000 THEN '' ELSE '--' END oraverion_10gR2_or_higher
     , CASE WHEN &&_O_RELEASE >= 1101000000 THEN '' ELSE '--' END oraverion_11gR1_or_higher
     , CASE WHEN &&_O_RELEASE >= 1101000700 THEN '' ELSE '--' END oraverion_11107_or_higher
     , CASE WHEN &&_O_RELEASE >= 1102000000 THEN '' ELSE '--' END oraverion_11gR2_or_higher
     , CASE WHEN &&_O_RELEASE >= 1102000200 THEN '' ELSE '--' END oraverion_11202_or_higher
  FROM dual;

set term on
  
--WHENEVER SQLERROR EXIT SQL.SQLCODE

-- VG_SPOOLFILE is being set in the login.sql
-- spool again to flush the buffer contents to file
-- spool &&VG_SPOOLFILE append 
