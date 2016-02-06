@@header

/*
*
*  Author     : Vishal Gupta
*  Purpose    : Display DataGuard Lag
*  Parameters : NONE
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  30-Jul-12  Vishal Gupta  Created
*  
*/

PROMPT *********************************************
PROMPT *    R E C O V E R Y     P R O G R E S S    *
PROMPT *********************************************

COLUMN inst_id             HEADING "I#"                            FORMAT 99
COLUMN start_time          HEADING "Start Time"                    FORMAT a18
COLUMN type                HEADING "Type"                          FORMAT a20
COLUMN item                HEADING "Item"                          FORMAT a25
COLUMN units               HEADING "Units"                         FORMAT a10
COLUMN sofar               HEADING "SoFar"                         FORMAT a45
COLUMN total               HEADING "Total"                         FORMAT 999,999,999,999
COLUMN timestamp           HEADING "Start Time"                    FORMAT a18
COLUMN comments            HEADING "Comments"                      FORMAT a18

SELECT r.inst_id
     --, TO_CHAR(r.start_time,'DD-MON-YY HH24:MI:SS') start_time
     --, r.type
     , r.item
     , CASE r.item
           WHEN 'Last Applied Redo' THEN TO_CHAR(r.timestamp,'DD-MON-YY HH24:MI:SS') || ' , ' || r.comments 
                                       || chr(10) || 'ApplyLag - ' ||  REPLACE(REPLACE(TO_CHAR( CAST(sysdate as TIMESTAMP) - CAST( r.timestamp as TIMESTAMP))
                                                                                ,'+0000000','+')
                                                              ,'.000000','')
         WHEN 'Active Time'       THEN FLOOR(r.sofar/3600) || 'h ' || FLOOR(MOD(r.sofar,3600)/60) || 'm ' ||  MOD(r.sofar,60) || 's' 
         WHEN 'Elapsed Time'      THEN FLOOR(r.sofar/3600) || 'h ' || FLOOR(MOD(r.sofar,3600)/60) || 'm ' ||  MOD(r.sofar,60) || 's'
                                       || chr(10) || 'StartTime: ' || TO_CHAR(r.start_time,'DD-MON-YY HH24:MI:SS') 
         ELSE TRIM(TO_CHAR(r.sofar,'999,999,999,999')) || ' ' || r.units 
      END  SoFar
     --, r.total
  FROM gv$recovery_progress r
 WHERE r.start_time = (SELECT MAX(start_time) from gv$recovery_progress)
 ORDER BY DECODE(r.item
                 ,'Last Applied Redo',1
                 ,'Standby Apply Lag',2
                 ,'Active Apply Rate',3
                 ,'Average Apply Rate',4
                 ,'Maximum Apply Rate',5
                 ,'Redo Applied',6
                 ,'Log Files',7
                 ,'Apply Time per Log',8
                 ,'Checkpoint Time per Log',9
                 ,'Active Time',21
                 ,'Elapsed Time',22
             ,999
                 )
;

@@footer
