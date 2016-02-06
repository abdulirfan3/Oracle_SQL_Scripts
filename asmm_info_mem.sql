@@header

set term off
/*
*
*  Author  : Vishal Gupta
*  Purpose : Display Tablespace usage
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  15-SEP-08  Vishal Gupta  First Draft
*  14-MAR-12  Vishal Gupta  Modified to make it RAC friendly
*  28-MAY-12  Vishal Gupta  Fixed to differentiate between instance specific 
*                           and generic (*.param) parameter values in spfile
*
*/

set term on

COLUMN inst_id             HEADING "Inst#"          FORMAT 99999 
COLUMN name                HEADING "Name"           FORMAT a21
COLUMN current_value1      HEADING "Current"        FORMAT a10 
COLUMN spfile_value1       HEADING "SPFile"         FORMAT a10 
COLUMN current_value2      HEADING "Current"        FORMAT a10 
COLUMN spfile_value2       HEADING "SPFile"         FORMAT a10 
COLUMN current_value3      HEADING "Current"        FORMAT a10 
COLUMN spfile_value3       HEADING "SPFile"         FORMAT a10 
COLUMN current_value4      HEADING "Current"        FORMAT a10 
COLUMN spfile_value4       HEADING "SPFile"         FORMAT a10 
COLUMN current_value5      HEADING "Current"        FORMAT a10 
COLUMN spfile_value5       HEADING "SPFile"         FORMAT a10 
COLUMN current_value6      HEADING "Current"        FORMAT a10 
COLUMN spfile_value6       HEADING "SPFile"         FORMAT a10 
COLUMN current_value7      HEADING "Current"        FORMAT a10 
COLUMN spfile_value7       HEADING "SPFile"         FORMAT a10 
COLUMN current_value8      HEADING "Current"        FORMAT a10 
COLUMN spfile_value8       HEADING "SPFile"         FORMAT a10 


COLUMN component           HEADING "Component"             FORMAT a24
COLUMN user_specified_size HEADING "User|Specified|(MB)"   FORMAT 99,999,999
COLUMN current_size        HEADING "Current|(MB)"          FORMAT 99,999,999
COLUMN free_size           HEADING "Free|(MB)"             FORMAT 99,999,999
COLUMN min_size            HEADING "Min|(MB)"              FORMAT 99,999,999
COLUMN max_size            HEADING "Max|(MB)"              FORMAT 99,999,999
COLUMN GRANULE_SIZE        HEADING "Granule|(MB)"          FORMAT 9,999
COLUMN last_oper_type      HEADING "Last|Operation|Type"   FORMAT a12
COLUMN oper_count          HEADING "Operation|Count"       FORMAT 99,999,999
COLUMN last_oper_time      HEADING "Last|Operation|Time"   FORMAT a18 

BREAK ON REPORT
COMPUTE SUM LABEL 'Total' OF current_size FORMAT 99,999,999  ON REPORT 
COMPUTE SUM LABEL 'Total' OF free_size    FORMAT 99,999,999  ON REPORT 

PROMPT  
PROMPT  ####################################################################
PROMPT  #######                                                      #######
PROMPT  #######    Automatic Shared Memory Management Settings       #######
PROMPT  #######                                                      #######
PROMPT  ####################################################################
PROMPT  


PROMPT  -                    <---- Instance 1 ---> <---- Instance 2 ---> <---- Instance 3 ---> <---- Instance 4 ---> <---- Instance 5 ---> <---- Instance 6 ---> <---- Instance 7 ---> <---- Instance 8 --->
select RPAD(pp.name,20) ||  '|' name
     , MAX(DECODE(pp.inst_id, 1, pp.display_value,NULL))                                                        current_value1
     , MAX(DECODE(pp.inst_id, 1, RPAD(NVL(NVL(sp.display_value,sp_generic.display_value),' '),9) || '|' ,NULL)) spfile_value1
     , MAX(DECODE(pp.inst_id, 2, pp.display_value,NULL))                                                        current_value2
     , MAX(DECODE(pp.inst_id, 2, RPAD(NVL(NVL(sp.display_value,sp_generic.display_value),' '),9) || '|' ,NULL)) spfile_value2
     , MAX(DECODE(pp.inst_id, 3, pp.display_value,NULL))                                                        current_value3
     , MAX(DECODE(pp.inst_id, 3, RPAD(NVL(NVL(sp.display_value,sp_generic.display_value),' '),9) || '|' ,NULL)) spfile_value3
     , MAX(DECODE(pp.inst_id, 4, pp.display_value,NULL))                                                        current_value4
     , MAX(DECODE(pp.inst_id, 4, RPAD(NVL(NVL(sp.display_value,sp_generic.display_value),' '),9) || '|' ,NULL)) spfile_value4
     , MAX(DECODE(pp.inst_id, 5, pp.display_value,NULL))                                                        current_value5
     , MAX(DECODE(pp.inst_id, 5, RPAD(NVL(NVL(sp.display_value,sp_generic.display_value),' '),9) || '|' ,NULL)) spfile_value5
     , MAX(DECODE(pp.inst_id, 6, pp.display_value,NULL))                                                        current_value6
     , MAX(DECODE(pp.inst_id, 6, RPAD(NVL(NVL(sp.display_value,sp_generic.display_value),' '),9) || '|' ,NULL)) spfile_value6
     , MAX(DECODE(pp.inst_id, 7, pp.display_value,NULL))                                                        current_value7
     , MAX(DECODE(pp.inst_id, 7, RPAD(NVL(NVL(sp.display_value,sp_generic.display_value),' '),9) || '|' ,NULL)) spfile_value7
     , MAX(DECODE(pp.inst_id, 8, pp.display_value,NULL))                                                        current_value8
     , MAX(DECODE(pp.inst_id, 8, RPAD(NVL(NVL(sp.display_value,sp_generic.display_value),' '),9) || '|' ,NULL)) spfile_value8
from gv$system_parameter pp
     JOIN gv$instance i ON pp.inst_id = i.inst_id
     LEFT OUTER JOIN gv$spparameter sp ON pp.inst_id = sp.inst_id AND   sp.sid =  i.instance_name and   pp.name = sp.name 
     LEFT OUTER JOIN gv$spparameter sp_generic ON sp_generic.inst_id = pp.inst_id AND sp_generic.sid =  '*' and sp_generic.name  = pp.name
WHERE (  pp.name in ('memory_target'
                   ,'memory_max_target'
                   ,'sga_target'
                   ,'sga_max_size'
                   ,'lock_sga'
                   ,'pre_page_sga'
                   ,'pga_aggregate_target'
                   ,'large_pool_size'
                   ,'use_large_pages'
                   )
       )
GROUP BY pp.name
UNION ALL
-- Get Host physical memory
select RPAD(os.stat_name,20) ||  '|' name
     , MAX(DECODE(os.inst_id, 1, ROUND(os.value/1024/1024/1024) || 'G',NULL))                          current_value1
     , MAX(DECODE(os.inst_id, 1, RPAD(NVL(ROUND(os.value/1024/1024/1024) || 'G',' '),9) || '|' ,NULL)) spfile_value1
     , MAX(DECODE(os.inst_id, 2, ROUND(os.value/1024/1024/1024) || 'G',NULL))                          current_value2
     , MAX(DECODE(os.inst_id, 2, RPAD(NVL(ROUND(os.value/1024/1024/1024) || 'G',' '),9) || '|' ,NULL)) spfile_value2
     , MAX(DECODE(os.inst_id, 3, ROUND(os.value/1024/1024/1024) || 'G',NULL))                          current_value3
     , MAX(DECODE(os.inst_id, 3, RPAD(NVL(ROUND(os.value/1024/1024/1024) || 'G',' '),9) || '|' ,NULL)) spfile_value3
     , MAX(DECODE(os.inst_id, 4, ROUND(os.value/1024/1024/1024) || 'G',NULL))                          current_value4
     , MAX(DECODE(os.inst_id, 4, RPAD(NVL(ROUND(os.value/1024/1024/1024) || 'G',' '),9) || '|' ,NULL)) spfile_value4
     , MAX(DECODE(os.inst_id, 5, ROUND(os.value/1024/1024/1024) || 'G',NULL))                          current_value5
     , MAX(DECODE(os.inst_id, 5, RPAD(NVL(ROUND(os.value/1024/1024/1024) || 'G',' '),9) || '|' ,NULL)) spfile_value5
     , MAX(DECODE(os.inst_id, 6, ROUND(os.value/1024/1024/1024) || 'G',NULL))                          current_value6
     , MAX(DECODE(os.inst_id, 6, RPAD(NVL(ROUND(os.value/1024/1024/1024) || 'G',' '),9) || '|' ,NULL)) spfile_value6
     , MAX(DECODE(os.inst_id, 7, ROUND(os.value/1024/1024/1024) || 'G',NULL))                          current_value7
     , MAX(DECODE(os.inst_id, 7, RPAD(NVL(ROUND(os.value/1024/1024/1024) || 'G',' '),9) || '|' ,NULL)) spfile_value7
     , MAX(DECODE(os.inst_id, 8, ROUND(os.value/1024/1024/1024) || 'G',NULL))                          current_value8
     , MAX(DECODE(os.inst_id, 8, RPAD(NVL(ROUND(os.value/1024/1024/1024) || 'G',' '),9) || '|' ,NULL)) spfile_value8
from gv$osstat os
where os.stat_name = 'PHYSICAL_MEMORY_BYTES'
GROUP BY os.stat_name
ORDER BY 1
/


BREAK ON inst_id SKIP 1

SELECT c.inst_id 
     , c.component
     , ROUND(c.user_specified_size / 1024 / 1024) user_specified_size
     , ROUND(c.current_size        / 1024 / 1024) current_size
     , ROUND(NVL(s.bytes,0)        / 1024 / 1024) free_size
     , ROUND(c.min_size            / 1024 / 1024) min_size
     , ROUND(c.max_size            / 1024 / 1024) max_size
     , ROUND(c.GRANULE_SIZE        / 1024 / 1024) GRANULE_SIZE
     , c.oper_count
     , c.last_oper_type 
     , to_char(c.last_oper_time,'DD-MON-YY hh24:mi:Ss') last_oper_time
FROM  gv$sga_dynamic_components c
    , GV$SGASTAT s
WHERE c.inst_id = s.inst_id (+)
  AND c.component = s.pool (+)
  AND s.name (+) = 'free memory'  
  AND c.current_size <> 0   
ORDER BY c.inst_id , c.component 
/


@@footer
