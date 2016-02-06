/*****************************************************************************
 * File:        estimate_mttr.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        28-Feb 2008
 *
 * Description:
 *	SQL*Plus script to query an RMAN repository residing in a "recovery
 *	catalog" database and provide information with which to estimate the
 *	amount of time to restore and recover a single tablespace or an
 *	entire database.
 *
 * Input:
 *	The script will prompt the user for the following information:
 *
 *	Name		Description				Default value
 *	--------------- --------------------------------------- -------------
 *	db_name		DB_NAME (not necessarily ORACLE_SID)	(none)
 *	ts_name		tablespace name				NULL (meaning
 *								all tablespaces)
 *	fail_if_unrecv 	Should the report fail if FULL or LVL0	Y (yes)
 *			backups do not exist for all datafiles?	
 *	include_ro	Include READ ONLY tablespaces?		Y (yes)
 *
 * Output:
 *	Field		Description
 *	--------------- -----------------------------------------------------
 *	File handle on	The name of the RMAN backupset piece on backup media
 *	backup media	
 *
 *	Completion	The date and time that the RMAN backupset piece completed
 *	time of		being written to backup media
 *	backup piece	
 *
 *	Backup elapsed	The number of hours it took to write the RMAN backupset
 *	hours		piece to backup media
 *
 *	Backup piece	The number of Mbytes the RMAN backupset piece occupies
 *	Size in Mb	on backup media
 *
 *	Mb/Sec during	The average throughput, expressed in Mbytes per second,
 *	backup		of the backup of the RMAN backupset piece to backup media
 *
 *	Mb to be	The number of Mbytes that must be extracted from the
 *	extracted from	RMAN backupset pieces to recover the tablespace or database
 *	backup set	following the restore from backup media
 *	pieces aft
 *	restore
 *
 *	# files to be	The number of datafiles or archived redo log files to be
 *	extrctd after	extracted from the backupset piece after restore from
 *	restore		backup media
 *
 *	Any RO df?	Does the RMAN backupset piece contain any datafiles from
 *			READ ONLY tablespaces?
 *
 * Restrictions:
 *	The driving query in this script uses a "query subfactoring clause"
 *	(a.k.a. "WITH" clause), which became available in Oracle9iR2.  So,
 *	this SQL script cannot be used with Oracle8i databases or older...
 *
 * Modification:
 *	TGorman	28-Feb-08	Written
 ****************************************************************************/
set pagesize 200 linesize 130 trimout on trimspool on
set pause off verify off echo off feedback off timing off
clear breaks computes
break on any_ro skip 1 on report
compute sum of elapsed_hrs on any_ro
compute sum of bp_mbytes on any_ro
compute avg of bkup_mbytes_sec on any_ro
compute sum of file_mbytes on any_ro
compute sum of file_cnt on any_ro
compute sum of elapsed_hrs on report
compute sum of bp_mbytes on report
compute avg of bkup_mbytes_sec on report
compute sum of file_mbytes on report
compute sum of file_cnt on report

col sort0 noprint
col sort1 noprint
col sort2 noprint
col handle format a40 heading "File handle on backup media" truncate
col completion_time format a18 heading "Completion Time|of backup piece"
col elapsed_hrs format 99,990.00 heading "Bkup|Elpsd|Hours"
col bp_mbytes format 99,999,990.00 heading "Backup|Piece|Size in Mb"
col bkup_mbytes_sec format 990.00 heading "Mb/Sec|during|backup"
col file_mbytes format 99,999,990.00 heading "Mb to be|extracted|from backup|set pieces|aft restore"
col file_cnt format 99,990 heading "# files|to be|extrctd|after|restore"
col any_ro format a3 heading "Any|RO|df?"

REM alter session set workarea_size_policy = manual;
REM alter session set sort_area_size = 536870912;
REM alter session set hash_area_size = 1073741824;
REM alter session set max_dump_file_size = unlimited;
REM alter session set tracefile_identifier = estmttr;
REM alter session set events '10046 trace name context forever, level 12';

accept db_name prompt "Please enter DB_NAME value []: "
accept ts_name prompt "Please enter the name of the tablespace or just press ENTER for entire database []: "
accept fail_if_unrecv prompt "Should the report fail if all datafiles cannot be restored (y/n)? [y]: "
accept include_ro prompt "Include READ ONLY tablespaces (y/n)? [y]: "

spool estimate_mttr_&&db_name
prompt
set pagesize 0
col open_comment new_value V_OPEN_COMMENT noprint
col close_comment new_value V_CLOSE_COMMENT noprint
select	decode(to_number(substr(version,1,instr(version,'.',1)-1)),
		8, 'NOTE: RMAN in Oracle version 8.x does not store volume (bytes) of backupset pieces.',
		9, 'NOTE: RMAN in Oracle version 9.x does not store volume (bytes) of backupset pieces.',
		'') msg,
	decode(to_number(substr(version,1,instr(version,'.',1)-1)),
		8, '/* ',
		9, '/* ',
		'') open_comment,
	decode(to_number(substr(version,1,instr(version,'.',1)-1)),
		8, ' */',
		9, ' */',
		'') close_comment
from	rcver;
set pagesize 200
prompt

with	L0 as				/* begin query block for "L0" */
	/* 
	 * ...return no rows if *any* datafile is lacking a LEVEL 0 backup...
	 * ...otherwise, return info about all LEVEL 0 backups, particularly
	 * BACKUP_SET information...
	 */
	(select	db_key,
		dbinc_key,
		file#,
		create_scn,
		read_only,
		ckp_scn,
		ckp_time,
		incr_level,
		completion_time,
		bs_key,
		blk_sz,
		blks,
		blks_written
	 from	/* 
		 * ...inner-most query (outer-joining RC_DATAFILE and RC_BACKUP_DATAFILE)
		 * retrieves the latest incremental LEVEL 0 datafile backup (i.e. where
		 * pseudo-column "RN" has the value of "1") and also fails to return any
		 * rows if a datafile does not have a backup (i.e. pseudo-column
		 * "MISSING_BDF" has a value of "-1")...
		 */
		(select	db_key,
			dbinc_key,
			file#,
			create_scn,
			read_only,
			ckp_scn,
			ckp_time,
			incr_level,
			completion_time,
			bs_key,
			blk_sz,
			blks,
			blks_written,
			row_number() over (partition by file#, create_scn
					   order by ckp_scn desc) rn,
			min(nvl(ckp_scn,-1)) over () missing_bdf
		 from	/* 
			 * ...outer-join RC_DATAFILE to RC_BACKUP_DATAFILE to retrieve
			 * all incremental LEVEL 0 datafile backups.  Datafiles without
			 * valid LEVEL 0 backups will show all "BDF"-aliased columns as
			 * NULL values...
			 */
			(select	dbinc.db_key,
				df.dbinc_key,
				df.file#,
				df.create_scn,
				df.read_only,
				bdf.ckp_scn,
				bdf.ckp_time,
				bdf.incr_level,
				bdf.completion_time,
				bdf.bs_key,
				bdf.block_size blk_sz,
				bdf.datafile_blocks blks,
				bdf.blocks blks_written
			 from	dbinc,
				ts,
				df,
				bdf
			 where	upper(dbinc.db_name) = upper('&&db_name')
			 and	ts.ts_name = nvl(upper('&&ts_name'), ts.ts_name)
			 and	df.dbinc_key = dbinc.dbinc_key
			 and	df.ts# = ts.ts#
			 and	df.ts_create_scn = ts.create_scn
			 and	df.drop_scn is null
			 and	bdf.dbinc_key (+) = df.dbinc_key
			 and	bdf.file# (+) = df.file#
			 and	bdf.create_scn (+) = df.create_scn
			 and	nvl(bdf.incr_level (+), 0) = 0))
	 where	rn = 1
	 and	(missing_bdf >= 0
	    or	 nvl(upper('&&fail_if_unrecv'),'Y') in ('N','NO'))
	),				/* end query block for "L0" */
	L1 as				/* begin query block for "L1" */
	/* 
	 * ...retrieve the most-recent LEVEL 1 datafile backups performed
	 * since the most-recent LEVEL 0 datafile backups...
	 */
	(select	db_key,
		dbinc_key,
		file#,
		create_scn,
		read_only,
		ckp_scn,
		incr_scn,
		incr_level,
		completion_time,
		bs_key,
		blk_sz,
		blks,
		blks_written
	 from	(select	L0.db_key,
			L0.dbinc_key,
			L0.file#,
			L0.create_scn,
			L0.read_only,
			nvl(L1.ckp_scn, L0.ckp_scn) ckp_scn,
			L1.incr_scn,
			L1.incr_level,
			L1.completion_time,
			L1.bs_key,
			L1.block_size blk_sz,
			L1.datafile_blocks blks,
			L1.blocks blks_written,
			row_number() over (partition by L0.file#, L0.create_scn
					   order by nvl(L1.ckp_scn, L0.ckp_scn) desc) rn
		 from	L0,
			bdf	L1
		 where	L1.dbinc_key (+) = L0.dbinc_key
		 and	L1.file# (+) = L0.file#
		 and	L1.create_scn (+) = L0.create_scn
		 and	L1.incr_level (+) = 1
		 and	L1.incr_scn (+) >= L0.ckp_scn)
	 where	rn = 1
	),				/* end query block for "L1" */
	L2 as				/* begin query block for "L2" */
	/* 
	 * ...retrieve the most-recent LEVEL 2 datafile backups performed
	 * since the most-recent LEVEL 1 datafile backups...
	 */
	(select	db_key,
		dbinc_key,
		file#,
		create_scn,
		read_only,
		ckp_scn,
		incr_scn,
		incr_level,
		completion_time,
		bs_key,
		blk_sz,
		blks,
		blks_written
	 from	(select	L1.db_key,
			L1.dbinc_key,
			L1.file#,
			L1.create_scn,
			L1.read_only,
			nvl(L2.ckp_scn, L1.ckp_scn) ckp_scn,
			L2.incr_scn,
			L2.incr_level,
			L2.completion_time,
			L2.bs_key,
			L2.block_size blk_sz,
			L2.datafile_blocks blks,
			L2.blocks blks_written,
			row_number() over (partition by L1.file#, L1.create_scn
					   order by nvl(L2.ckp_scn, L1.ckp_scn) desc) rn
		 from	L1,
			bdf	L2
		 where	L2.dbinc_key (+) = L1.dbinc_key
		 and	L2.file# (+) = L1.file#
		 and	L2.create_scn (+) = L1.create_scn
		 and	L2.incr_level (+) = 2
		 and	L2.incr_scn (+) >= L1.ckp_scn)
	 where	rn = 1
	),				/* end query block for "L2" */
	AL as				/* begin query block for "AL" */
	/* 
	 * ...retrieve the archived redo log files necessary to recover
	 * the database past the most recent LEVEL 0, 1, or 2 datafile
	 * backup...
	 */
	(select L2.db_key,
		L2.dbinc_key,
		brl.brl_key,
		brl.low_scn,
		brl.next_scn,
		brl.sequence#,
		brl.bs_key,
		brl.block_size blk_sz,
		brl.blocks blks
	 from	brl,
		L2
	 where	L2.read_only = 0
	 and	brl.dbinc_key = L2.dbinc_key
	 group by
		L2.db_key,
		L2.dbinc_key,
		brl.brl_key,
		brl.low_scn,
		brl.next_scn,
		brl.sequence#,
		brl.bs_key,
		brl.block_size,
		brl.blocks
	 having brl.next_scn >= min(L2.ckp_scn)
	)				/* end query block for "AL" */
/*
 * =========> BEGIN MAIN QUERY BLOCK <=========
 */
select	max(L0.read_only) sort0,
	nvl(max(L0.incr_level),0) sort1,
	to_char(p.completion_time,'YYYYMMDDHH24MISS') sort2,
	p.handle,
	to_char(p.completion_time,'DD-MON-RR HH24:MI:SS') completion_time,
	abs((p.completion_time - p.start_time) * 86400)/3600 elapsed_hrs,
	&&V_OPEN_COMMENT
	(p.bytes/1048576) bp_mbytes,
	(p.bytes/1048576)/abs((p.completion_time - p.start_time) * 86400) bkup_mbytes_sec,
	&&V_CLOSE_COMMENT
	sum(L0.blk_sz*L0.blks_written)/1048576 file_mbytes,
	count(*) file_cnt,
	decode(sum(L0.read_only),0,'NO','YES') any_ro
from	L0,
	dbinc	d,
	bp	p,
	bs	s
where	(L0.read_only = 0 or nvl('&&include_ro', 'Y') = 'Y')
and	s.db_key = L0.db_key
and	s.bs_key = L0.bs_key
and	s.status = 'A'
and	p.bs_key = s.bs_key
and	p.status = 'A'
group by 
	to_char(p.completion_time,'YYYYMMDDHH24MISS'),
	p.handle,
	to_char(p.completion_time,'DD-MON-RR HH24:MI:SS'),
	abs((p.completion_time - p.start_time) * 86400) &&V_OPEN_COMMENT ,
	(p.bytes/1048576),
	(p.bytes/1048576)/abs((p.completion_time - p.start_time) * 86400) &&V_CLOSE_COMMENT
union all
select	max(L1.read_only) sort0,
	nvl(max(L1.incr_level),0) sort1,
	to_char(p.completion_time,'YYYYMMDDHH24MISS') sort2,
	p.handle,
	to_char(p.completion_time,'DD-MON-RR HH24:MI:SS') completion_time,
	abs((p.completion_time - p.start_time) * 86400)/3600 elapsed_hrs,
	&&V_OPEN_COMMENT
	(p.bytes/1048576) bp_mbytes,
	(p.bytes/1048576)/abs((p.completion_time - p.start_time) * 86400) bkup_mbytes_sec,
	&&V_CLOSE_COMMENT
	sum(L1.blk_sz*L1.blks_written)/1048576 file_mbytes,
	count(*) file_cnt,
	decode(sum(L1.read_only),0,'NO','YES') any_ro
from	L1,
	bp	p,
	bs	s
where	(L1.read_only = 0 or nvl('&&include_ro', 'Y') = 'Y')
and	L1.incr_scn is not null
and	s.db_key = L1.db_key
and	s.bs_key = L1.bs_key
and	s.status = 'A'
and	p.bs_key = s.bs_key
and	p.status = 'A'
group by 
	to_char(p.completion_time,'YYYYMMDDHH24MISS'),
	p.handle,
	to_char(p.completion_time,'DD-MON-RR HH24:MI:SS'),
	abs((p.completion_time - p.start_time) * 86400) &&V_OPEN_COMMENT ,
	(p.bytes/1048576),
	(p.bytes/1048576)/abs((p.completion_time - p.start_time) * 86400) &&V_CLOSE_COMMENT
union all
select	max(L2.read_only) sort0,
	nvl(max(L2.incr_level),0) sort1,
	to_char(p.completion_time,'YYYYMMDDHH24MISS') sort2,
	p.handle,
	to_char(p.completion_time,'DD-MON-RR HH24:MI:SS') completion_time,
	abs((p.completion_time - p.start_time) * 86400)/3600 elapsed_hrs,
	&&V_OPEN_COMMENT
	(p.bytes/1048576) bp_mbytes,
	(p.bytes/1048576)/abs((p.completion_time - p.start_time) * 86400) bkup_mbytes_sec,
	&&V_CLOSE_COMMENT
	sum(L2.blk_sz*L2.blks_written)/1048576 file_mbytes,
	count(*) file_cnt,
	decode(sum(L2.read_only),0,'NO','YES') any_ro
from	L2,
	bp	p,
	bs	s
where	(L2.read_only = 0 or nvl('&&include_ro', 'Y') = 'Y')
and	L2.incr_scn is not null
and	s.db_key = L2.db_key
and	s.bs_key = L2.bs_key
and	s.status = 'A'
and	p.bs_key = s.bs_key
and	p.status = 'A'
group by 
	to_char(p.completion_time,'YYYYMMDDHH24MISS'),
	p.handle,
	to_char(p.completion_time,'DD-MON-RR HH24:MI:SS'),
	abs((p.completion_time - p.start_time) * 86400) &&V_OPEN_COMMENT ,
	(p.bytes/1048576),
	(p.bytes/1048576)/abs((p.completion_time - p.start_time) * 86400) &&V_CLOSE_COMMENT
union all
select	0 sort0,
	999 sort1,
	to_char(p.completion_time,'YYYYMMDDHH24MISS') sort0,
	p.handle,
	to_char(p.completion_time,'DD-MON-RR HH24:MI:SS') completion_time,
	abs((p.completion_time - p.start_time) * 86400)/3600 elapsed_hrs,
	&&V_OPEN_COMMENT
	(p.bytes/1048576) bp_mbytes,
	(p.bytes/1048576)/abs((p.completion_time - p.start_time) * 86400) bkup_mbytes_sec,
	&&V_CLOSE_COMMENT
	sum(AL.blk_sz*AL.blks)/1048576 file_mbytes,
	count(*) file_cnt,
	'NO' any_ro
from	AL,
	bp	p,
	bs	s
where	s.db_key = AL.db_key
and	s.bs_key = AL.bs_key
and	s.status = 'A'
and	p.bs_key = s.bs_key
and	p.status = 'A'
group by 
	to_char(p.completion_time,'YYYYMMDDHH24MISS'),
	p.handle,
	to_char(p.completion_time,'DD-MON-RR HH24:MI:SS'),
	abs((p.completion_time - p.start_time) * 86400) &&V_OPEN_COMMENT ,
	(p.bytes/1048576),
	(p.bytes/1048576)/abs((p.completion_time - p.start_time) * 86400) &&V_CLOSE_COMMENT
order by sort0, sort1, sort2;
spool off

REM alter session set events '10046 trace name context off';
REM alter session set workarea_size_policy = auto;
clear breaks computes
set feedback 6 verify on
