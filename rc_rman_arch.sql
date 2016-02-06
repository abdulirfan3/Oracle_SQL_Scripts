PROMPT ##############################################################################
PROMPT Run the rc_rman_info_all.sql First to get the details needed for this script
PROMPT ##############################################################################

-- Archive log info
select min(sequence#), max(sequence#) from RMAN.RC_BACKUP_ARCHIVELOG_DETAILS where session_recid='&session_recid';

col handle format a70;
col media format a15
select db_id, bp_key, recid, bs_key, backup_type, handle, media from RMAN.RC_BACKUP_PIECE where bs_key between '&bs_key_from' and '&bs_key_to';

