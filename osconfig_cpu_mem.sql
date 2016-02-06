@@header

/*
*
*  Author    : Vishal Gupta
*  Purpose   : Display OS configuration
*  Parameter : None
*
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  27-JUN-14  Vishal Gupta  Created
*  
*/




define _IF_INST1_EXISTS="--"
define _IF_INST2_EXISTS="--"
define _IF_INST3_EXISTS="--"
define _IF_INST4_EXISTS="--"
define _IF_INST5_EXISTS="--"
define _IF_INST6_EXISTS="--"
define _IF_INST7_EXISTS="--"
define _IF_INST8_EXISTS="--"
define _IF_INST9_EXISTS="--"
define _IF_INST10_EXISTS="--"
define _IF_INST11_EXISTS="--"
define _IF_INST12_EXISTS="--"
define _IF_INST13_EXISTS="--"
define _IF_INST14_EXISTS="--"
define _IF_INST15_EXISTS="--"
define _IF_INST16_EXISTS="--"

col INST1_EXISTS        new_value _IF_INST1_EXISTS    noprint
col INST2_EXISTS        new_value _IF_INST2_EXISTS    noprint
col INST3_EXISTS        new_value _IF_INST3_EXISTS    noprint
col INST4_EXISTS        new_value _IF_INST4_EXISTS    noprint
col INST5_EXISTS        new_value _IF_INST5_EXISTS    noprint
col INST6_EXISTS        new_value _IF_INST6_EXISTS    noprint
col INST7_EXISTS        new_value _IF_INST7_EXISTS    noprint
col INST8_EXISTS        new_value _IF_INST8_EXISTS    noprint
col INST9_EXISTS        new_value _IF_INST9_EXISTS    noprint
col INST10_EXISTS       new_value _IF_INST10_EXISTS   noprint
col INST11_EXISTS       new_value _IF_INST11_EXISTS   noprint
col INST12_EXISTS       new_value _IF_INST12_EXISTS   noprint
col INST13_EXISTS       new_value _IF_INST13_EXISTS   noprint
col INST14_EXISTS       new_value _IF_INST14_EXISTS   noprint
col INST15_EXISTS       new_value _IF_INST15_EXISTS   noprint
col INST16_EXISTS       new_value _IF_INST16_EXISTS   noprint

set term off
SELECT MIN(DECODE(inst_id,1,' ', '--'))   INST1_EXISTS
     , MIN(DECODE(inst_id,2,' ', '--'))   INST2_EXISTS
     , MIN(DECODE(inst_id,3,' ', '--'))   INST3_EXISTS
     , MIN(DECODE(inst_id,4,' ', '--'))   INST4_EXISTS
     , MIN(DECODE(inst_id,5,' ', '--'))   INST5_EXISTS
     , MIN(DECODE(inst_id,6,' ', '--'))   INST6_EXISTS
     , MIN(DECODE(inst_id,7,' ', '--'))   INST7_EXISTS
     , MIN(DECODE(inst_id,8,' ', '--'))   INST8_EXISTS
     , MIN(DECODE(inst_id,9,' ', '--'))   INST9_EXISTS
     , MIN(DECODE(inst_id,10,' ', '--'))  INST10_EXISTS
     , MIN(DECODE(inst_id,11,' ', '--'))  INST11_EXISTS
     , MIN(DECODE(inst_id,12,' ', '--'))  INST12_EXISTS
     , MIN(DECODE(inst_id,13,' ', '--'))  INST13_EXISTS
     , MIN(DECODE(inst_id,14,' ', '--'))  INST14_EXISTS
     , MIN(DECODE(inst_id,15,' ', '--'))  INST15_EXISTS
     , MIN(DECODE(inst_id,16,' ', '--'))  INST16_EXISTS
  FROM gv$instance 
  GROUP BY version
;
set term on

PROMPT 
PROMPT #############################################################################
PROMPT #   Operation System Configuratoin
PROMPT #############################################################################

COLUMN stat_name        HEADING "Name"                 FORMAT A25
COLUMN comments         HEADING "Description"          FORMAT A55
COLUMN value1           HEADING "Inst1"                FORMAT A10
COLUMN value2           HEADING "Inst2"                FORMAT A10
COLUMN value3           HEADING "Inst3"                FORMAT A10
COLUMN value4           HEADING "Inst4"                FORMAT A10
COLUMN value5           HEADING "Inst5"                FORMAT A10
COLUMN value6           HEADING "Inst6"                FORMAT A10
COLUMN value7           HEADING "Inst7"                FORMAT A10
COLUMN value8           HEADING "Inst8"                FORMAT A10

SELECT               s.stat_name
                    , s.comments     
                    , MAX(DECODE(s.inst_id
                               , 1, DECODE(s.stat_name
                              ,'PHYSICAL_MEMORY_BYTES',TO_CHAR(ROUND(s.value/power(1024,3))) || ' GB'
                              ,TO_CHAR(ROUND(s.value,2)))
                         , ' ')   
                    )            value1
&&_IF_INST2_EXISTS  , MAX(DECODE(s.inst_id
&&_IF_INST2_EXISTS              , 2, DECODE(s.stat_name
&&_IF_INST2_EXISTS                        ,'PHYSICAL_MEMORY_BYTES',TO_CHAR(ROUND(s.value/power(1024,3))) || ' GB'
&&_IF_INST2_EXISTS                       ,TO_CHAR(ROUND(s.value,2)))
&&_IF_INST2_EXISTS             , ' ')      
&&_IF_INST2_EXISTS       )            value2
&&_IF_INST3_EXISTS  , MAX(DECODE(s.inst_id
&&_IF_INST3_EXISTS              , 3, DECODE(s.stat_name
&&_IF_INST3_EXISTS                        ,'PHYSICAL_MEMORY_BYTES',TO_CHAR(ROUND(s.value/power(1024,3))) || ' GB'
&&_IF_INST3_EXISTS                       ,TO_CHAR(ROUND(s.value,2)))
&&_IF_INST3_EXISTS             , ' ')      
&&_IF_INST3_EXISTS       )            value3
&&_IF_INST4_EXISTS  , MAX(DECODE(s.inst_id
&&_IF_INST4_EXISTS              , 4, DECODE(s.stat_name
&&_IF_INST4_EXISTS                        ,'PHYSICAL_MEMORY_BYTES',TO_CHAR(ROUND(s.value/power(1024,3))) || ' GB'
&&_IF_INST4_EXISTS                       ,TO_CHAR(ROUND(s.value,2)))
&&_IF_INST4_EXISTS             , ' ')      
&&_IF_INST4_EXISTS       )            value4
&&_IF_INST5_EXISTS  , MAX(DECODE(s.inst_id
&&_IF_INST5_EXISTS              , 5, DECODE(s.stat_name
&&_IF_INST5_EXISTS                        ,'PHYSICAL_MEMORY_BYTES',TO_CHAR(ROUND(s.value/power(1024,3))) || ' GB'
&&_IF_INST5_EXISTS                       ,TO_CHAR(ROUND(s.value,2)))
&&_IF_INST5_EXISTS             , ' ')      
&&_IF_INST5_EXISTS       )            value5
&&_IF_INST6_EXISTS  , MAX(DECODE(s.inst_id
&&_IF_INST6_EXISTS              , 6, DECODE(s.stat_name
&&_IF_INST6_EXISTS                        ,'PHYSICAL_MEMORY_BYTES',TO_CHAR(ROUND(s.value/power(1024,3))) || ' GB'
&&_IF_INST6_EXISTS                       ,TO_CHAR(ROUND(s.value,2)))
&&_IF_INST6_EXISTS             , ' ')      
&&_IF_INST6_EXISTS       )            value6
&&_IF_INST7_EXISTS  , MAX(DECODE(s.inst_id
&&_IF_INST7_EXISTS              , 7, DECODE(s.stat_name
&&_IF_INST7_EXISTS                        ,'PHYSICAL_MEMORY_BYTES',TO_CHAR(ROUND(s.value/power(1024,3))) || ' GB'
&&_IF_INST7_EXISTS                       ,TO_CHAR(ROUND(s.value,2)))
&&_IF_INST7_EXISTS             , ' ')      
&&_IF_INST7_EXISTS       )            value7
&&_IF_INST8_EXISTS  , MAX(DECODE(s.inst_id
&&_IF_INST8_EXISTS              , 8, DECODE(s.stat_name
&&_IF_INST8_EXISTS                        ,'PHYSICAL_MEMORY_BYTES',TO_CHAR(ROUND(s.value/power(1024,3))) || ' GB'
&&_IF_INST8_EXISTS                       ,TO_CHAR(ROUND(s.value,2)))
&&_IF_INST8_EXISTS             , ' ')      
&&_IF_INST8_EXISTS       )            value8
  FROM gv$osstat s
 WHERE s.cumulative = 'NO'
GROUP BY  s.stat_name, s.comments 
 ORDER BY DECODE(s.stat_name
                ,'NUM_CPU_SOCKETS'         , 1
                ,'NUM_CPU_CORES'           , 2
                ,'NUM_CPUS'                , 3
                ,'PHYSICAL_MEMORY_BYTES'   , 4
                ,'LOAD'                    , 5
                ,'GLOBAL_RECEIVE_SIZE_MAX' , 6
                ,'GLOBAL_SEND_SIZE_MAX'    , 7
                ,99
                 )
        , s.stat_name          
;

/*
GLOBAL_RECEIVE_SIZE_MAX 
GLOBAL_SEND_SIZE_MAX    
LOAD                    
NUM_CPUS                
NUM_CPU_CORES           
NUM_CPU_SOCKETS         
PHYSICAL_MEMORY_BYTES   
TCP_RECEIVE_SIZE_DEFAULT
TCP_RECEIVE_SIZE_MAX    
TCP_RECEIVE_SIZE_MIN    
TCP_SEND_SIZE_DEFAULT   
TCP_SEND_SIZE_MAX       
TCP_SEND_SIZE_MIN       

*/
@@footer
@login_after