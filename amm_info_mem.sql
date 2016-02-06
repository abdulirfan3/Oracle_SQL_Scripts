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
*  24-FEB-14  Vishal Gupta  Modified to make instance specific columns dynamic.
*  28-MAY-12  Vishal Gupta  Fixed to differentiate between instance specific 
*                           and generic (*.param) parameter values in spfile
*  14-MAR-12  Vishal Gupta  Modified to make it RAC friendly
*  15-SEP-08  Vishal Gupta  Created
*
*/

set term on


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
PROMPT  #############################################################
PROMPT  #######                                               #######
PROMPT  #######    Automatic Memory Management Settings       #######
PROMPT  #######                                               #######
PROMPT  #############################################################
PROMPT  

COLUMN inst_id             HEADING "Inst#"          FORMAT 99999 
COLUMN name                HEADING "Name"           FORMAT a21 

COLUMN current_value1      HEADING "Current"        FORMAT a7 
COLUMN current_value2      HEADING "Current"        FORMAT a7 
COLUMN current_value3      HEADING "Current"        FORMAT a7 
COLUMN current_value4      HEADING "Current"        FORMAT a7 
COLUMN current_value5      HEADING "Current"        FORMAT a7 
COLUMN current_value6      HEADING "Current"        FORMAT a7 
COLUMN current_value7      HEADING "Current"        FORMAT a7 
COLUMN current_value8      HEADING "Current"        FORMAT a7 
COLUMN current_value9      HEADING "Current"        FORMAT a7 
COLUMN current_value10     HEADING "Current"        FORMAT a7 
COLUMN current_value11     HEADING "Current"        FORMAT a7 
COLUMN current_value12     HEADING "Current"        FORMAT a7 
COLUMN current_value13     HEADING "Current"        FORMAT a7 
COLUMN current_value14     HEADING "Current"        FORMAT a7 
COLUMN current_value15     HEADING "Current"        FORMAT a7 
COLUMN current_value16     HEADING "Current"        FORMAT a7 

COLUMN spfile_value1       HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value2       HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value3       HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value4       HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value5       HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value6       HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value7       HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value8       HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value9       HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value10      HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value11      HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value12      HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value13      HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value14      HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value15      HEADING "SPFile"         FORMAT a7 
COLUMN spfile_value16      HEADING "SPFile"         FORMAT a7 

COLUMN end_column          HEADING " "              FORMAT a1

set colsep '|'

set head off
                  SELECT '-                    '
&&_IF_INST1_EXISTS    || ' <---Inst 1 --->'
&&_IF_INST2_EXISTS    || ' <---Inst 2 --->'
&&_IF_INST3_EXISTS    || ' <---Inst 3 --->'
&&_IF_INST4_EXISTS    || ' <---Inst 4 --->'
&&_IF_INST5_EXISTS    || ' <---Inst 5 --->'
&&_IF_INST6_EXISTS    || ' <---Inst 6 --->'
&&_IF_INST7_EXISTS    || ' <---Inst 7 --->'
&&_IF_INST8_EXISTS    || ' <---Inst 8 --->'
                 FROM DUAL;
set head on

select RPAD(pp.name,20)  name
&&_IF_INST1_EXISTS     , MAX(DECODE(pp.inst_id, 1, pp.display_value,NULL))                                current_value1
&&_IF_INST1_EXISTS     , MAX(DECODE(pp.inst_id, 1, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value1
&&_IF_INST2_EXISTS     , MAX(DECODE(pp.inst_id, 2, pp.display_value,NULL))                                current_value2
&&_IF_INST2_EXISTS     , MAX(DECODE(pp.inst_id, 2, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value2
&&_IF_INST3_EXISTS     , MAX(DECODE(pp.inst_id, 3, pp.display_value,NULL))                                current_value3
&&_IF_INST3_EXISTS     , MAX(DECODE(pp.inst_id, 3, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value3
&&_IF_INST4_EXISTS     , MAX(DECODE(pp.inst_id, 4, pp.display_value,NULL))                                current_value4
&&_IF_INST4_EXISTS     , MAX(DECODE(pp.inst_id, 4, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value4
&&_IF_INST5_EXISTS     , MAX(DECODE(pp.inst_id, 5, pp.display_value,NULL))                                current_value5
&&_IF_INST5_EXISTS     , MAX(DECODE(pp.inst_id, 5, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value5
&&_IF_INST6_EXISTS     , MAX(DECODE(pp.inst_id, 6, pp.display_value,NULL))                                current_value6
&&_IF_INST6_EXISTS     , MAX(DECODE(pp.inst_id, 6, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value6
&&_IF_INST7_EXISTS     , MAX(DECODE(pp.inst_id, 7, pp.display_value,NULL))                                current_value7
&&_IF_INST7_EXISTS     , MAX(DECODE(pp.inst_id, 7, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value7
&&_IF_INST8_EXISTS     , MAX(DECODE(pp.inst_id, 8, pp.display_value,NULL))                                current_value8
&&_IF_INST8_EXISTS     , MAX(DECODE(pp.inst_id, 8, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value8
                       , ' '                                                                              end_column
from gv$system_parameter pp
     JOIN gv$instance i ON pp.inst_id = i.inst_id
     LEFT OUTER JOIN gv$spparameter sp ON pp.inst_id = sp.inst_id AND   sp.sid =  i.instance_name and   pp.name = sp.name 
     LEFT OUTER JOIN gv$spparameter sp_generic ON sp_generic.inst_id = pp.inst_id AND sp_generic.sid =  '*' and sp_generic.name  = pp.name
WHERE ( pp.name in ('memory_target','memory_max_target'
                   ,'sga_target','sga_max_size'
                   ,'lock_sga','pre_page_sga','use_large_pages'
                   ,'pga_aggregate_target'
                   ,'java_pool_size','shared_pool_size','large_pool_size'
                   ,'db_cache_size'
                   )
      )
GROUP BY pp.name
UNION ALL
-- Get Host physical memory
select RPAD(os.stat_name,20)  name
&&_IF_INST1_EXISTS     , MAX(DECODE(os.inst_id, 1, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value1
&&_IF_INST1_EXISTS     , NULL spfile_value1
&&_IF_INST2_EXISTS     , MAX(DECODE(os.inst_id, 2, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value2
&&_IF_INST2_EXISTS     , NULL spfile_value2
&&_IF_INST3_EXISTS     , MAX(DECODE(os.inst_id, 3, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value3
&&_IF_INST3_EXISTS     , NULL spfile_value3
&&_IF_INST4_EXISTS     , MAX(DECODE(os.inst_id, 4, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value4
&&_IF_INST4_EXISTS     , NULL spfile_value4
&&_IF_INST5_EXISTS     , MAX(DECODE(os.inst_id, 5, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value5
&&_IF_INST5_EXISTS     , NULL spfile_value5
&&_IF_INST6_EXISTS     , MAX(DECODE(os.inst_id, 6, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value6
&&_IF_INST6_EXISTS     , NULL spfile_value6
&&_IF_INST7_EXISTS     , MAX(DECODE(os.inst_id, 7, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value7
&&_IF_INST7_EXISTS     , NULL spfile_value7
&&_IF_INST8_EXISTS     , MAX(DECODE(os.inst_id, 8, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value8
&&_IF_INST8_EXISTS     , NULL spfile_value8
     , ' '  end_column
from gv$osstat os
where os.stat_name = 'PHYSICAL_MEMORY_BYTES'
GROUP BY os.stat_name
ORDER BY 1
/



set head off
                  SELECT '-                    '
&&_IF_INST9_EXISTS    || ' <---Inst 9 --->'
&&_IF_INST10_EXISTS   || ' <---Inst 10--->'
&&_IF_INST11_EXISTS   || ' <---Inst 11--->'
&&_IF_INST12_EXISTS   || ' <---Inst 12--->'
&&_IF_INST13_EXISTS   || ' <---Inst 13--->'
&&_IF_INST14_EXISTS   || ' <---Inst 14--->'
&&_IF_INST15_EXISTS   || ' <---Inst 15--->'
&&_IF_INST16_EXISTS   || ' <---Inst 16--->'
                 FROM DUAL;
set head on

select RPAD(pp.name,20)  name
&&_IF_INST9_EXISTS     , MAX(DECODE(pp.inst_id, 9, pp.display_value,NULL))                                  current_value9
&&_IF_INST9_EXISTS     , MAX(DECODE(pp.inst_id, 9, NVL(sp.display_value,sp_generic.display_value) ,NULL))   spfile_value9
&&_IF_INST10_EXISTS     , MAX(DECODE(pp.inst_id, 10, pp.display_value,NULL))                                current_value10
&&_IF_INST10_EXISTS     , MAX(DECODE(pp.inst_id, 10, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value10
&&_IF_INST11_EXISTS     , MAX(DECODE(pp.inst_id, 11, pp.display_value,NULL))                                current_value11
&&_IF_INST11_EXISTS     , MAX(DECODE(pp.inst_id, 11, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value11
&&_IF_INST12_EXISTS     , MAX(DECODE(pp.inst_id, 12, pp.display_value,NULL))                                current_value12
&&_IF_INST12_EXISTS     , MAX(DECODE(pp.inst_id, 12, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value12
&&_IF_INST13_EXISTS     , MAX(DECODE(pp.inst_id, 13, pp.display_value,NULL))                                current_value13
&&_IF_INST13_EXISTS     , MAX(DECODE(pp.inst_id, 13, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value13
&&_IF_INST14_EXISTS     , MAX(DECODE(pp.inst_id, 14, pp.display_value,NULL))                                current_value14
&&_IF_INST14_EXISTS     , MAX(DECODE(pp.inst_id, 14, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value14
&&_IF_INST15_EXISTS     , MAX(DECODE(pp.inst_id, 15, pp.display_value,NULL))                                current_value15
&&_IF_INST15_EXISTS     , MAX(DECODE(pp.inst_id, 15, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value15
&&_IF_INST16_EXISTS     , MAX(DECODE(pp.inst_id, 16, pp.display_value,NULL))                                current_value16
&&_IF_INST16_EXISTS     , MAX(DECODE(pp.inst_id, 16, NVL(sp.display_value,sp_generic.display_value) ,NULL)) spfile_value16
                       , ' '                                                                              end_column
from gv$system_parameter pp
     JOIN gv$instance i ON pp.inst_id = i.inst_id
     LEFT OUTER JOIN gv$spparameter sp ON pp.inst_id = sp.inst_id AND   sp.sid =  i.instance_name and   pp.name = sp.name 
     LEFT OUTER JOIN gv$spparameter sp_generic ON sp_generic.inst_id = pp.inst_id AND sp_generic.sid =  '*' and sp_generic.name  = pp.name
WHERE ( pp.name in ('memory_target','memory_max_target'
                   ,'sga_target','sga_max_size'
                   ,'lock_sga','pre_page_sga','use_large_pages'
                   ,'pga_aggregate_target'
                   ,'java_pool_size','shared_pool_size','large_pool_size'
                   )
      )
      AND i.inst_id > 8
GROUP BY pp.name
UNION ALL
-- Get Host physical memory
select RPAD(os.stat_name,20)  name
&&_IF_INST9_EXISTS     , MAX(DECODE(os.inst_id, 9, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value9
&&_IF_INST9_EXISTS     , NULL spfile_value9
&&_IF_INST10_EXISTS     , MAX(DECODE(os.inst_id, 10, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value10
&&_IF_INST10_EXISTS     , NULL spfile_value10
&&_IF_INST11_EXISTS     , MAX(DECODE(os.inst_id, 11, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value11
&&_IF_INST11_EXISTS     , NULL spfile_value11
&&_IF_INST12_EXISTS     , MAX(DECODE(os.inst_id, 12, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value12
&&_IF_INST12_EXISTS     , NULL spfile_value12
&&_IF_INST13_EXISTS     , MAX(DECODE(os.inst_id, 13, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value13
&&_IF_INST13_EXISTS     , NULL spfile_value13
&&_IF_INST14_EXISTS     , MAX(DECODE(os.inst_id, 14, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value14
&&_IF_INST14_EXISTS     , NULL spfile_value14
&&_IF_INST15_EXISTS     , MAX(DECODE(os.inst_id, 15, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value15
&&_IF_INST15_EXISTS     , NULL spfile_value15
&&_IF_INST16_EXISTS     , MAX(DECODE(os.inst_id, 16, ROUND(os.value/1024/1024/1024) || 'G',NULL))  current_value16
&&_IF_INST16_EXISTS     , NULL spfile_value16
                        , ' '  end_column
from gv$osstat os
where os.stat_name = 'PHYSICAL_MEMORY_BYTES'
  AND os.inst_id > 8
GROUP BY os.stat_name
ORDER BY 1
/



set colsep " "


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

BREAK ON inst_id SKIP 1

SELECT c.inst_id
     , c.component
     , ROUND(c.user_specified_size / power(1024,2)) user_specified_size
     , ROUND(c.current_size        / power(1024,2)) current_size
     , ROUND(DECODE(c.component
                  ,'PGA Target',NVL(p.value,0)
                  , ROUND(NVL(s.bytes,0))
                  ) 
            / power(1024,2)
            ) free_size
     , ROUND(c.min_size     / power(1024,2)) min_size
     , ROUND(c.max_size     / power(1024,2)) max_size
     , ROUND(c.GRANULE_SIZE / power(1024,2)) GRANULE_SIZE
     , c.oper_count
     , c.last_oper_type 
     , to_char(c.last_oper_time,'DD-MON-YY hh24:mi:Ss') last_oper_time
FROM  gv$memory_dynamic_components c
      LEFT OUTER JOIN GV$SGASTAT s ON s.inst_id   = c.inst_id AND s.pool = c.component AND s.name  = 'free memory'
      LEFT OUTER JOIN gv$pgastat p ON p.inst_id   = c.inst_id AND p.name = 'total freeable PGA memory'
WHERE c.current_size <> 0   
ORDER BY c.inst_id, c.component 
/



undefine _IF_INST1_EXISTS
undefine _IF_INST2_EXISTS
undefine _IF_INST3_EXISTS
undefine _IF_INST4_EXISTS
undefine _IF_INST5_EXISTS
undefine _IF_INST6_EXISTS
undefine _IF_INST7_EXISTS
undefine _IF_INST8_EXISTS
undefine _IF_INST9_EXISTS
undefine _IF_INST10_EXISTS
undefine _IF_INST11_EXISTS
undefine _IF_INST12_EXISTS
undefine _IF_INST13_EXISTS
undefine _IF_INST14_EXISTS
undefine _IF_INST15_EXISTS
undefine _IF_INST16_EXISTS


@@footer
