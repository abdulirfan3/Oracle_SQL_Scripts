REM Queries for Design Capacity Analysis

REM session_activity QUERY accidentally overwritten, get from old backup

----------------------------------------------------------------------------------------------------
REM  Script		capacity_analysis.sql
REM  Created 		09/27/2015
REM  Last Modified	10/23/2015
REM  Author  		Michele Coopersmith, Kellogg Company
REM  Purpose		Provide capacity info for Oracle databases prior to migration or upgrade.
REM			Everything you wanted to know about your Oracle databases but were afraid 
REM			to ask.
REM  Description	Provide general configuration information for an Oracle database,
REM			including sizing, tablespace names, types of objects, SGA size,
REM			RMAN backup history, log mode, character set, etc.
REM  Caution		Some of the queries may not work in lower versions; these errors
REM  			can be ignored.
			
REM  Mods	 	check for compression 		- added 10/23/2015
REM			check for TDE (encryption) 	- added 10/23/2015

REM  Modes to be Added 	check for db scheduler jobs

----------------------------------------------------------------------------------------------------
prompt
prompt

prompt '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
prompt '			                BEGIN CAPACITY_ANALYSIS'
prompt '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
prompt
prompt


prompt '------------------------------------------------------------------------------------'
prompt '				STATION IDENTIFICATION'
prompt '------------------------------------------------------------------------------------'
prompt

select to_char(sysdate,'MM-DD-YYYY HH24:MI:SS') CURRDATE
from dual;

prompt
SELECT DBTIMEZONE TIMEZONE
FROM DUAL;

prompt

column instance_name format a15
column host_name format a15
SELECT INSTANCE_NAME, HOST_NAME
FROM V$INSTANCE;

prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				VERSION, EDITION'
prompt '------------------------------------------------------------------------------------'
prompt
SELECT BANNER
FROM V$VERSION;


prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				INSTALLED COMPONENTS'
prompt '------------------------------------------------------------------------------------'
prompt

set line 200;
set pagesize 9999;
col COMP_ID format a15;
col COMP_NAME format a50;
select COMP_ID,COMP_NAME,STATUS from dba_registry
/

prompt
prompt

column parameter format a45
select *
from v$option
order by parameter
/


prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '				CHARACTER SET'
prompt '------------------------------------------------------------------------------------'
prompt
column parameter format a30
column value format a15

select parameter, value
from nls_database_parameters
where parameter='NLS_CHARACTERSET';

REM  as sys, run the following:
select name, substrb(value$,1,40)
from sys.props$;

prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				CURRENT CONNECTIONS'
prompt '------------------------------------------------------------------------------------'
prompt
column osuser format a15
column machine format a25
column terminal format a25
column username format a15

select osuser, machine, terminal, username, count(0)
from v$session
group by osuser, machine, terminal, username
order by 2,1;

prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				ARCHIVELOG Mode'
prompt '------------------------------------------------------------------------------------'
prompt
select log_mode
from v$database;

prompt
prompt


prompt '------------------------------------------------------------------------------------'
prompt '				   Force Logging'
prompt '------------------------------------------------------------------------------------'
prompt

SELECT FORCE_LOGGING 
from V$DATABASE;


prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '				    Data Guard'
prompt '------------------------------------------------------------------------------------'
prompt

select DECODE(count(*),0,'NO DATA GUARD',
		1,'DATA GUARD ENABLED',
		2,'DATA GUARD ENABLED',
		3,'DATA GUARD ENABLED')
from v$archive_dest
where status = 'VALID'
and target = 'STANDBY';
-- 0   = DG not enabled
-- > 0 = DG enabled
prompt
prompt


column dest_name format a20
column destination format a20
select DEST_NAME, TARGET, DESTINATION, TRANSMIT_MODE
from v$archive_dest
where status = 'VALID'
and target = 'STANDBY';

prompt
prompt

col hostname format a30

SELECT db_name, hostname, log_archived, log_applied, applied_time, 
       log_archived-log_applied AS GAP
FROM (
  SELECT name AS DB_NAME
  FROM v$database),
     (
  SELECT UPPER(SUBSTR(host_name, 1, (DECODE(INSTR(host_name,'.'), 0, 
  LENGTH(host_name), (INSTR(host_name,'.')-1))))) HOSTNAME
  FROM v$instance),
     (
  SELECT MAX(sequence#) AS LOG_ARCHIVED
  FROM v$archived_log
  WHERE dest_id = 1
  AND archived = 'YES'),
     (
  SELECT MAX(sequence#) AS LOG_APPLIED
  FROM v$archived_log
  WHERE dest_id = 2
  AND applied = 'YES'),
     (
  SELECT TO_CHAR(MAX(completion_time),'DD-MON/HH24:MI') AS APPLIED_TIME
  FROM v$archived_log
  WHERE dest_id = 2
  AND applied = 'YES')
/

prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '			        Table Compression'
prompt '------------------------------------------------------------------------------------'
prompt
select compression, count(0)
from DBA_TABLES
group by COMPRESSION
order by 1;

prompt
prompt


prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '			    	      TDE'
prompt '------------------------------------------------------------------------------------'
prompt
COLUMN ENCRYPTION format a10
select ENCRYPTED, count(0)
from DBA_TABLESPACES
group by ENCRYPTED
order by 1;

prompt
prompt



prompt '------------------------------------------------------------------------------------'
prompt '			   SYSTEM AND SYSAUX DATAFILES'
prompt '------------------------------------------------------------------------------------'
prompt
select sum(bytes)/1024/1024/1024 bytes_gb
from dba_data_files
where tablespace_name in ('SYSTEM','SYSAUX')
;

prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				TEMP TABLESPACE USERS'
prompt '------------------------------------------------------------------------------------'
prompt

SELECT TEMPORARY_TABLESPACE, COUNT(USERNAME)
FROM DBA_USERS
GROUP BY TEMPORARY_TABLESPACE
order by 1;

prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				 TEMPFILES SIZE'
prompt '------------------------------------------------------------------------------------'
prompt
SELECT tablespace_name, SUM(BYTES)/1024/1024/1024 BYTES_GB
FROM DBA_TEMP_FILES
group by tablespace_name;

prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '			    UNDO TABLESPACE DATAFILES'
prompt '------------------------------------------------------------------------------------'
prompt
select tablespace_name, sum(bytes)/1024/1024/1024 bytes_gb
from dba_data_files
where tablespace_name =
(SELECT TABLESPACE_NAME
FROM DBA_TABLESPACES
WHERE CONTENTS='UNDO')
group by tablespace_name;

prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				CONTROL FILE SIZE'
prompt '------------------------------------------------------------------------------------'
prompt
select (block_size*file_size_blks)/1024/1024 bytes_mb
from v$controlfile;

prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				   REDO LOGS'
prompt '------------------------------------------------------------------------------------'
prompt
select bytes/1024/1024 bytes_mb
from v$log
/

column member format a45
select group#, member, type
from v$logfile
order by 1,2
/


prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				  ARCHIVE LOGS'
prompt '------------------------------------------------------------------------------------'
prompt
SELECT A.*,
Round(A.Count#*B.AVG#/1024/1024) Daily_Avg_Mb
FROM
(
   SELECT
   To_Char(First_Time,'YYYY-MM-DD') DAY,
   Count(1) Count#,
   Min(RECID) Min#,
   Max(RECID) Max#
FROM
   v$log_history
GROUP BY 
   To_Char(First_Time,'YYYY-MM-DD')
ORDER
BY 1 ASC
) A,
(
SELECT
Avg(BYTES) AVG#,
Count(1) Count#,
Max(BYTES) Max_Bytes,
Min(BYTES) Min_Bytes
FROM
v$log
) B 
;


prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '			   DATA/TEMP FILE TOTAL SIZES'
prompt '------------------------------------------------------------------------------------'
prompt
SELECT A.*,
Round(A.Count#*B.AVG#/1024/1024) Daily_Avg_Mb
FROM
(
   SELECT
   To_Char(First_Time,'YYY

select sum(bytes)/1024/1024/1024 bytes_gb
from dba_data_files
union
select sum(bytes)/1024/1024/1024 bytes_gb
from dba_temp_files
/


prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				SEGMENTS TOTAL'
prompt '------------------------------------------------------------------------------------'
prompt

SELECT SUM(BYTES)/1024/1024/1024 BYTES_GB
FROM DBA_SEGMENTS;

prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '				USERS IN DBA_USERS'
prompt '------------------------------------------------------------------------------------'
prompt

SELECT COUNT(0)
FROM DBA_USERS;


prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '	    ROLES FOR TABLES NOT OWNED BY SYS, SYSTEM, OUTLN, DBSNMP'
prompt '------------------------------------------------------------------------------------'
prompt

select T.GRANTEE, COUNT(0)
from dba_tab_privs t, dba_roles r
WHERE T.grantee = R.ROLE
AND T.OWNER NOT IN ('SYS', 'SYSTEM', 'OUTLN', 'DBSNMP') 
GROUP BY T.GRANTEE
ORDER BY T.GRANTEE
;



prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				TABLESPACES AND DATAFILES'
prompt '------------------------------------------------------------------------------------'
prompt

SELECT COUNT(0) NUM_TABLESPACES
FROM DBA_TABLESPACES;

prompt

SELECT COUNT(0) NUM_DATAFILES
FROM DBA_DATA_FILES;

prompt

SET PAGESIZE 1000
column extent_management format a17
SELECT t.TABLESPACE_NAME, t.extent_management, t.CONTENTS, ROUND(sum(d.bytes)/1024/1024,2) bytes_mb
FROM DBA_TABLESPACES t, DBA_DATA_FILES d
WHERE t.TABLESPACE_NAME=d.TABLESPACE_NAME
GROUP BY T.TABLESPACE_NAME, T.EXTENT_MANAGEMENT, T.CONTENTS
ORDER BY 1
/

prompt

column autoextensible format a14
select autoextensible, count(0)
from dba_data_files
group by autoextensible;


prompt
prompt
prompt '------------------------------------------------------------------------------------'
prompt '				TOTAL OBJECTS'
prompt '------------------------------------------------------------------------------------'
prompt

SELECT OBJECT_TYPE, COUNT(0) 
FROM DBA_OBJECTS
GROUP BY OBJECT_TYPE
ORDER BY 1;


prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '				INVALID OBJECTS'
prompt '------------------------------------------------------------------------------------'
prompt

SELECT OBJECT_TYPE, COUNT(0) 
FROM DBA_OBJECTS
WHERE STATUS <> 'VALID'
GROUP BY OBJECT_TYPE
ORDER BY 1;


prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '				OBJECTS BY OWNER'
prompt '------------------------------------------------------------------------------------'
prompt

SELECT OWNER, OBJECT_TYPE, COUNT(0) 
FROM DBA_OBJECTS
GROUP BY OWNER, OBJECT_TYPE
ORDER BY 1,2;

prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '			     TOTAL SGA IN MB AND GB'
prompt '------------------------------------------------------------------------------------'
prompt

select sum(value)/1024/1024 SGA_MB, sum(value)/1024/1024/1024 SGA_GB
from v$sga;

prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '			       SGA MAJOR AREAS'
prompt '------------------------------------------------------------------------------------'
prompt

column name format a25
select name, round(TO_NUMBER(value)/1024/1024,1) bytes_mb, 
round(TO_NUMBER(value)/1024/1024/1024,1) bytes_gb 
from v$parameter
where name in ('sga_target', 'sga_max_size', 'large_pool_size',
	'db_cache_size', 'log_buffer', 'shared_pool_size',
	'db_block_size','db_block_buffers')
order by 1
/

prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '	CONSTRAINTS NOT OWNED BY BACKUP, DBSNMP, SYS, SYSMAN, SYSTEM, TSMSYS'
prompt '------------------------------------------------------------------------------------'
prompt

prompt 'Legend for DBA_CONSTRAINTS:'
PROMPT 'Type Code  Type Description  		 Acts On Level'
PROMPT '---------  ---------------------------	 -------------'
PROMPT 'C   	   Check on a table 		 Column'
PROMPT 'O   	   Read Only on a view 	 	 Object'
PROMPT 'P   	   Primary Key 		 	 Object'
PROMPT 'R  	   Referential AKA Foreign Key   Column'
PROMPT 'U   	   Unique Key 			 Column'
PROMPT 'V   	   Check Option on a view 	 Object'

PROMPT

column owner format a15
select owner, constraint_type, status, count(0)
from dba_constraints
where owner not in ('BACKUP','DBSNMP','SYS','SYSMAN','SYSTEM','TSMSYS')
group by owner, constraint_type, status
order by 1,2
/


prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '				    DB LINKS'
prompt '------------------------------------------------------------------------------------'
prompt

column owner format a15
column db_link format a30
column username format a20
column host format a15
column created format a15
SELECT *
from DBA_DB_LINKS
ORDER BY 1,2;

prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '			TRIGGERS NOT OWNED BY SYS, SYSMAN, SYSTEM'
prompt '------------------------------------------------------------------------------------'
prompt

column owner format a15
column trigger_name format a30
column trigger_type format a15
column triggering_event format a17
column table_name format a25
column status format a10
select owner, trigger_name, trigger_type, triggering_event, table_name, status
from dba_triggers
where owner not in ('SYS','SYSMAN','SYSTEM')
order by 1,2;

prompt
prompt


prompt '------------------------------------------------------------------------------------'
prompt '			   SOURCE CODE NOT OWNED BY' 
prompt '		BACKUP, DBSNMP, ORACLE_OCM, OUTLN, SYS, SYSMAN, SYSTEM'
prompt '------------------------------------------------------------------------------------'
prompt

column owner format a15
select owner, name, type, count(0)
from dba_source
where owner not in ('BACKUP','DBSNMP', 'ORACLE_OCM', 'OUTLN','SYS', 'SYSMAN', 'SYSTEM')
group by owner, name, type
order by 1,2;

prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '		SEQUENCES NOT OWNED BY DBSNMP, SYS, SYSMAN, SYSTEM'
prompt '------------------------------------------------------------------------------------'
prompt

column sequence_owner format a15
select sequence_owner, sequence_name
from dba_sequences
where sequence_owner not in ('DBSNMP','SYS', 'SYSMAN', 'SYSTEM')
order by 1,2;

prompt
prompt



prompt '------------------------------------------------------------------------------------'
prompt '				EXTERNAL TABLES'
prompt '------------------------------------------------------------------------------------'
prompt

column owner format a15
column table_name format a15
column access_type format a11
column type_name format a15
column def_dir format a10
select owner, table_name, access_type, type_name, default_directory_name def_dir
from dba_external_tables
order by 1,2;

prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '				RMAN BACKUP HISTORY'
prompt '------------------------------------------------------------------------------------'
prompt
set linesize 200
column status format a10
column command_id format a20
column input_bytes_display format a10
column bytes format a10
column time_taken_display format a9
column time format a9
column session_recid format 999999
select START_TIME, END_TIME, STATUS, TIME_TAKEN_DISPLAY time, INPUT_BYTES_DISPLAY bytes, 
COMMAND_ID, SESSION_RECID, SESSION_STAMP, INPUT_TYPE, round(COMPRESSION_RATIO,1) comp
from v$rman_backup_job_details
where command_id <> 'flag_arch_backup_in_progress'
and input_type <> 'CONTROLFILE'
order by start_time desc
/

prompt
prompt

prompt '------------------------------------------------------------------------------------'
prompt '				ALL PARAMETERS'
prompt '------------------------------------------------------------------------------------'
prompt
set pagesize 500
set linesize 132
column name format a40
column value format a40

REM other useful columns:  ISSYS_MODIFIABLE (IMMEDIATE=change is immediate)

select name, value, isdefault
from v$parameter
order by 1
/

prompt
prompt

prompt '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
prompt '			                END CAPACITY_ANALYSIS'
prompt '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'


