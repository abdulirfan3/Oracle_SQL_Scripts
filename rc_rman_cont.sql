PROMPT ##############################################################################
PROMPT Run the rc_rman_info_all.sql First to get the details needed for this script
PROMPT ##############################################################################

select btype, btype_key, session_key, session_recid, db_name, creation_time, resetlogs_change#, resetlogs_time, checkpoint_change#, checkpoint_time from RMAN.RC_BACKUP_CONTROLFILE_DETAILS
where session_recid='&session_recid';

select db_id, bp_key, recid, bs_key, backup_type, handle, media from RMAN.RC_BACKUP_PIECE where bs_key between '&bs_key_from' and '&bs_key_to';

-- Spfile info (look into this if needed)