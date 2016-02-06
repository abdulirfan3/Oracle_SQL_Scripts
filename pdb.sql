col name format a20;
col open_time format a30;
prompt
prompt #### All PDB's and CDB's  ######
select con_id, dbid, name, open_mode, open_time, total_size, RESTRICTED from v$containers;


prompt #### All PDB's ######
select name, open_mode, con_id, dbid, open_time, total_size,RESTRICTED from v$pdbs;

prompt
prompt ######  List of Available services from DBA_Services   ######
prompt ######       Services for PDB will not appear here     ######

col pdb format a20;
col network_name format a20;
col global_service format a20;
col enabled format a10;
col global format a10;

select service_id, name, network_name, global_service, pdb,enabled from dba_services;

prompt ######  List of Available services from v$Services   ######
select service_id,con_id, name, pdb, creation_date, global from v$services;

prompt ##### TS and Data file relationship for pdb and cdb's  #######
col file_name format a50;
select a.name, b.tablespace_name, b.file_id, b.file_name from v$containers a, cdb_data_files b where a.con_id=b.con_id;