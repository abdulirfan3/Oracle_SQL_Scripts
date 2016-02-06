@@header

/*
*
*  Author     : Vishal Gupta
*  Purpose    : Display Archive Destination Configuration
*  Parameters : NONE
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  09-MAY-14  Vishal Gupta  Output layout changes
*  19-Mar-14  Vishal Gupta  Created
*  
*/

PROMPT *****************************************************************
PROMPT *  Archive Destinations
PROMPT *****************************************************************

COLUMN dest_id             HEADING "Dest|Id"                     FORMAT 99
COLUMN dest_name           HEADING "Dest Name"                   FORMAT a20
COLUMN db_unique_name      HEADING "UniqueName"                  FORMAT a15
COLUMN destination         HEADING "Destination"                 FORMAT a25
COLUMN archiver            HEADING "Arch|iver"                   FORMAT a4
COLUMN compression         HEADING "Compress"                    FORMAT a8
COLUMN transmit_mode       HEADING "Tranmit|Mode"                
COLUMN affirm              HEADING "AFFIRM"                      FORMAT a6

COLUMN reopen_secs         HEADING "Reopen|(sec)"                FORMAT 999999
COLUMN delay_mins          HEADING "Delay|(min)"                 FORMAT 99999
COLUMN max_connections     HEADING "Max|Conns"                   FORMAT 99999
COLUMN net_timeout         HEADING "Net|Time|Out"                FORMAT 9999
COLUMN alternate           HEADING "Alertnate"                   FORMAT a10
COLUMN dependency          HEADING "Dependency"                  FORMAT a10

COLUMN register            HEADING "Regi|ster"                   FORMAT a4
COLUMN log_sequence        HEADING "LogSeq"                      FORMAT 9999999

COLUMN async_blocks        HEADING "ASYNC|Blocks"                FORMAT 999999
COLUMN valid_now           HEADING "Valid|Now"                   FORMAT a7
COLUMN verify              HEADING "Verify"                      FORMAT a6

COLUMN fail_sequence       HEADING "FailSeq"                     FORMAT 9999999
COLUMN failure_count       HEADING "Fail|Count"                  FORMAT 99999
COLUMN max_failure         HEADING "Max|Fail"                    FORMAT 99999
COLUMN error               HEADING "Error"                       FORMAT a30

SELECT ad.dest_id
     , ad.dest_name
     , ad.db_unique_name
     , ad.destination
     , ad.status
     , ad.schedule
     , ad.target
     , ad.valid_type
     , ad.valid_role
     , ad.binding
     , ad.name_space
     , ad.compression
     , ad.archiver
     , ad.transmit_mode
     , ad.affirm
  FROM v$archive_dest ad
WHERE status <> 'INACTIVE'
;

SELECT ad.dest_id
     , ad.reopen_secs
     , ad.delay_mins
     , ad.max_connections
     , ad.net_timeout
     , ad.process
     , ad.register
     , ad.log_sequence
     , ad.alternate
     , ad.dependency
     , ad.async_blocks
     , ad.type
     , ad.valid_now
     , ad.verify
   --, ad.applied_scn
     , ad.fail_date
     , ad.fail_sequence
     , ad.failure_count
     , ad.max_failure
     , ad.error
  FROM v$archive_dest ad
WHERE status <> 'INACTIVE'
;


@@footer
