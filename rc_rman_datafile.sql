PROMPT ##############################################################################
PROMPT Run the rc_rman_info_all.sql First to get the details needed for this script
PROMPT ##############################################################################

-- Datafile info
PROMPT ###########################################
PROMPT Info from RC_BACKUP_DATAFILE_DETAILS
PROMPT ###########################################
col FILESIZE_DISPLAY format a20;
select * from RMAN.RC_BACKUP_datafile_details
where  btype_key between '&bs_key_from' and '&bs_key_to';

PROMPT ###########################################
PROMPT Info from RC_BACKUP_DATAFILE
PROMPT ###########################################
col USED_OPTIMIZATION format a20
col USED_CHANGE_TRACKING format a20;
select * from RMAN.RC_BACKUP_datafile
where bs_key between '&bs_key_from' and '&bs_key_to';

col handle format a80;
col media format a10
select db_id, bp_key, recid, bs_key, backup_type, media, handle from RMAN.RC_BACKUP_PIECE where bs_key between '&bs_key_from' and '&bs_key_to';
