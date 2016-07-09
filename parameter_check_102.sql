select
  name,
  substr(order_recommendation,3) recommendation,
  substr(flags,1,1) "I",
  substr(flags,2,1) "U",
  remark,
  "SET",
  is_value,
  should_be_value,
  substr(order_recommendation,1,1) "ID",
  inst_id
from
(
  select
    decode(substr(c.name,1,3),
      '***',-1,c.inst_id) inst_id,
    decode(substr(c.name,1,3),
      '***',upper(c.name),
      decode(c.subname,
        ' ',c.name,
        c.name||' ('||c.subname||')')) name,
    decode(substr(c.name,1,3),
      '***','* '||
        decode(substr(c.name,17,2),
          ' 1',
'Parametercheck for Oracle 10.2. based on Note/Version: 830576/225',
          ' 2',
'Parametercheck last changed: 2013-02-15',
          ' 3',
'Parametercheck Execution: '||to_char(sysdate,
'YYYY-MM-DD HH24:MI:SS'),
          ' 4',
'DB Startup: '||to_char(x_startup,
'YYYY-MM-DD HH24:MI:SS')||decode(x_cluster_database,
'TRUE',' (data of instance '||c.inst_id||')',''),
          ' 5',
'DB SID: '||x_db_name,
          ' 6',
'DB Environment: '||
decode(x_olap,'TRUE','OLAP','UNKNOWN','OLTP or OLAP','OLTP')||
decode(x_cluster_database,'TRUE',', RAC',', not RAC'),
          ' 7',
'DB Platform: '||x_platform_name||decode(x_cluster_database,
'TRUE',' (data of instance '||c.inst_id||')',''),
          ' 8',
'DB Patchset: '||x_version||
decode(x_cluster_database,
'TRUE',' (data of instance '||c.inst_id||')',''),
          ' 9',
'Last detectable DB Mergefix: '||decode(substr(x_version,1,8),
  '10.2.0.4',decode(sign(x_mergefix-16),
    1,'from SAP Bundle Patch',
    x_mergefix),
  '10.2.0.5',decode(x_mergefix,
    0,'from unpatched 10.2.0.5',
    'from SAP Bundle Patch'),
  x_mergefix)||' (released '||x_mergefix_released||')'||decode(x_cluster_database,
'TRUE',' (data of instance '||c.inst_id||')',''),
          '10',
'Reliability checks: events '||decode(x_event_contains_colon,
0,'passed',
'FAILED [event separator ":"'||
' unsupported; see note 1431798]')||
', _fix_controls '||decode(x_fix_control_reliable,
1,'passed',
'FAILED [not all _fix_controls are in'||
' v$system_fix_control; note 1454675 ]'),
          '11',
decode(instr('45',substr(x_version,8,1)),0,
'WARNING: unsupported patchset used =>'||
' recommendations may not be valid =>'||
' apply latest patchset (note 871735)',
decode(substr(x_version,1,8),'10.2.0.4',
'WARNING: no further SBP will be'||
' released for this patchset =>'||
' apply latest patchset (note 871735)',
  '10.2.0.5',decode(instr('2012,2013,2014',substr(x_mergefix_released,1,4)),0,
'WARNING: Extended support for 10.2.0.5'||
' only available with a special extended'||
' support contract (note 1431752)',
'WARNING: usage of SBP released after 2011-11'||
' only allowed with an extended support '||
' contract (note 1654734)')))),
      decode(c.ismodified,
        'FALSE', decode(c.isdefault,
          'TRUE',decode(s.value,
            null,
'Q ok (is not set; mentioned with other prerequisites/not mentioned in note)',
            decode(substr(s.value,1,5),
              '-man-',
'E check if default value "'||c.value||'" is suitable ('||substr(s.value,6)||')',
              '-aut-',
'H automatic check ok; doublecheck if default value "'||c.value||'" is suitable ('||substr(s.value,6)||')',
              '-any-',
'P ok (is not set; any value recommended)',
              '-del-',
'K ok (is not set; not to be set as explicitly mentioned in note)',
              decode(upper(c.value),
                upper(s.value),
'J add explicitly with default value "'||s.value||'"',
'B add with value "'||s.value||'"'))),
          decode(s.value,
            null,
'G check why set but mentioned with other prerequisites/not mentioned in note',
            decode(substr(s.value,1,5),
              '-man-',
'F check if value "'||c.value||'" is suitable ('||substr(s.value,6)||')',
              '-aut-',
'I automatic check ok; doublecheck if value "'||c.value||'" is suitable ('||substr(s.value,6)||')',
              '-any-',
'O ok (is set; any value recommended)',
              '-del-',
'C delete (is set; not to be set as explicitly mentioned in note)',
              decode(
                decode(
                  substr(replace(upper(c.value),' ',''),1,length(
                    substr(replace(upper(s.value),' ',''),1,
                    instr(replace(upper(s.value),' ',''),'[')-1))),
                  substr(replace(upper(s.value),' ',''),1,
                    instr(replace(upper(s.value),' ',''),'[')-1),'X',
                  ' ')||
                decode(
                  substr(replace(upper(c.value),' ',''),-length(
                    substr(replace(upper(s.value),' ',''),
                    instr(replace(upper(s.value),' ',''),']')+1))),
                  substr(replace(upper(s.value),' ',''),
                    instr(replace(upper(s.value),' ',''),']')+1),'X',
                  ' '),
                'XX',
'L ok (is set correctly =)',
                decode(sign(
                  decode(rpad('>=',length(s.value),'X'),
                    translate(s.value,'1234567890','XXXXXXXXXX'),
                      to_number(c.value)-to_number(substr(s.value,3))+1,
                    0)),
                  1,
'M ok (is set correctly >=)',
                  decode(sign(
                    decode(rpad('between ',length(s.value),'X'),
                      replace(translate(s.value,'1234567890','XXXXXXXXXX'),' and ','XXXXX'),
                        to_number(c.value)-to_number(substr(s.value,9,instr(s.value,' and ')-9))+1,
                      0))*sign(
                    decode(rpad('between ',length(s.value),'X'),
                      replace(translate(s.value,'1234567890','XXXXXXXXXX'),' and ','XXXXX'),
                        to_number(substr(s.value,instr(s.value,' and ')+5))-to_number(c.value)+1,
                      0)),
                    1,
'N ok (is set correctly between)',
'D change value to "'||s.value||'"')))))),
      decode(
        decode(substr(c.name,1,4),'nls_',0,1)+
        instr(',nls_length_semantics,nls_nchar_conv_excp,',','||c.name||','),
          0,
'R ok (ignored dynamically changed parameter)',
'A parameter was dynamically changed; no reliable recommendation can be given'))) order_recommendation,
    decode(substr(c.name,1,3),
      '***',' ',
      decode(c.isdefault,
        'TRUE','N',
        'Y')) "SET",
    c.value is_value,
    decode(substr(s.value,1,5),
      '-man-',substr(s.value,6),
      '-aut-',substr(s.value,6),
      '-any-','any value',
      '-del-','deleted '||chr(102)||'rom parameter file',
              s.value) should_be_value,
    s."comment" remark,
    s.flags
  from
  (
    select
      inst_id,
      name,
      subname,
      value,
      "comment",
      flags,
      hide,
      x_mergefix,
      x_mergefix_released,
      x_cluster_database,
      x_olap,
      x_version,
      x_startup,
      x_platform_name,
      x_event_contains_colon,
      x_fix_control_reliable,
      x_db_name
    from
    (
      select
        o.inst_id,
        lower(decode(instr(o.n,','),0,o.n,substr(o.n,1,instr(o.n,',')-1))) name,
        lower(decode(instr(o.n,','),0,' ',substr(o.n,instr(o.n,',')+1))) subname,
        replace(decode(o.n,
          'DB_FILES','>='||to_char(round(x_datafile_count.value*1.1)),
          'PARALLEL_MAX_SERVERS',decode(x_parameter.cpu_count*10-x_parameter.para_max,
            0,'-aut-'||substr(o.w,6),o.w),
          'PGA_AGGREGATE_TARGET',decode(sign(round(x_pgastat.MAX_since_start/(x_pgastat.limit_value+1)*100)-90),
            -1,decode(sign(round(x_pgastat.MAX_since_start/(x_pgastat.limit_value+1)*100)-75),
              1,'-aut-'||substr(o.w,6),
               o.w),
            o.w),
          'PROCESSES',decode(sign(round(x_rl.MAX_UTILIZATION/(x_rl.limit_value+1)*100)-75),
            -1,'-aut-'||substr(o.w,6),o.w),
          'SESSIONS',decode(sign(round(x_rl.MAX_UTILIZATION/(x_rl.limit_value+1)*100)-75),
            -1,'-aut-'||substr(o.w,6),o.w),
          'SHARED_POOL_SIZE',decode(x_parameter.sga_target,          
            0,decode(x_parameter.db_cache_size,
              0,'-man-'||o.w,
              decode(sign(x_parameter.shared_pool_size_mb-0.5*x_parameter.calculated_shared_pool_size_mb),
                -1,'-man-'||o.w,
                decode(sign(x_parameter.shared_pool_size_mb-2*x_parameter.calculated_shared_pool_size_mb),
                  1,'-man-'||o.w,
                  '-aut-'||o.w))),
            '-man-'||o.w),                      
          'UNDO_RETENTION',decode(x_undostat.max_stolen,
            0,'-aut-'||substr(o.w,6),o.w),
          o.w),'[SID]',x_database.name) value,
        o.p flags,
        decode(o.n,
          'PARALLEL_MAX_SERVERS','Max used (gv$resource_limit): '||x_rl.MAX_UTILIZATION
            ||' ('||round(x_rl.MAX_UTILIZATION/(x_parameter.para_max+1)*100)
            ||'%); '
            ||replace(o.c,'[CPU_COUNT]',to_char(x_parameter.cpu_count)),
          'PGA_AGGREGATE_TARGET','Max used MB (gv$pgastat): '||round(x_pgastat.MAX_since_start/1024/1024)
            ||' ('||round(x_pgastat.MAX_since_start/(x_pgastat.limit_value+1)*100)
            ||'%) ',
          'PROCESSES','Max used (gv$resource_limit): '||x_rl.MAX_UTILIZATION
            ||' ('||round(x_rl.MAX_UTILIZATION/(x_rl.limit_value+1)*100)
            ||'%)',
          'SESSIONS','Max used (gv$resource_limit): '||x_rl.MAX_UTILIZATION
            ||' ('||round(x_rl.MAX_UTILIZATION/(x_rl.limit_value+1)*100)
            ||'%); '
            ||replace(o.c,'[PROCESSES]',to_char(x_parameter.processes)),
          'SHARED_POOL_SIZE',decode(x_parameter.sga_target,          
            0,decode(x_parameter.db_cache_size,
              0,'db_cache_size=0',
              'current: '||round(x_parameter.shared_pool_size_mb)||
              ' MB; calculated: '||round(x_parameter.calculated_shared_pool_size_mb)||' MB'),
            'ASMM is used (sga_target>0)'),
          'UNDO_RETENTION','Max unexpired stolen blocks (gv$undostat): '||x_undostat.max_stolen,
          o.c) "comment",
        decode(instr(lower(o.n),'_fix_control'),0,'FALSE',decode(x_fix_control.bugno,null,'TRUE','FALSE')) hide,
        x_mergefix.mergefix_at_least x_mergefix,
        x_mergefix.mergefix_released x_mergefix_released,
        x_parameter.cluster_database x_cluster_database,
        x_olap.olap x_olap,
        o.version x_version,
        o.startup_time x_startup,
        x_database.platform_name x_platform_name,
        x_event.contains_colon x_event_contains_colon,
        x_fix_control_reliable.reliable x_fix_control_reliable,
        x_database.name x_db_name
      from
      (
        select
          i.inst_id inst_id,
          i.startup_time,
          i.version,
          n,w,c,p,
          decode(instr(' '||r,'PS['),0,'',
            substr(r,instr(r,'PS[')+3,instr(r,']',
            instr(r,'PS['))-instr(r,'PS[')-3)) r_ps,
          decode(instr(' '||r,'MF['),0,'',
            substr(r,instr(r,'MF[')+3,instr(r,']',
            instr(r,'MF['))-instr(r,'MF[')-3)) r_mf,
          decode(instr(' '||r,'BW['),0,'',
            substr(r,instr(r,'BW[')+3,instr(r,']',
            instr(r,'BW['))-instr(r,'BW[')-3)) r_bw,
          decode(instr(' '||r,'RAC['),0,'',
            substr(r,instr(r,'RAC[')+4,instr(r,']',
            instr(r,'RAC['))-instr(r,'RAC[')-4)) r_rac,
          decode(instr(' '||r,'OS['),0,'',
            substr(r,instr(r,'OS[')+3,instr(r,']',
            instr(r,'OS['))-instr(r,'OS[')-3)) r_os,
          decode(instr(' '||r,'OSF['),0,'',
            substr(r,instr(r,'OSF[')+4,instr(r,']',
            instr(r,'OSF['))-instr(r,'OSF[')-4)) r_osf
        from
        (
          select
'*** INFORMATION '||lpad(rownum,2)||' ***' n,
  '' w,
  '' r,
  '' p,
  '' c from gv$parameter2 where rownum < 12 union (
select
  substr(val,instr(val,'#',1,r-4)+1,instr(val,'#',1,r-3)-instr(val,'#',1,r-4)-1) n,
  substr(val,instr(val,'#',1,r-3)+1,instr(val,'#',1,r-2)-instr(val,'#',1,r-3)-1) w,
  substr(val,instr(val,'#',1,r-2)+1,instr(val,'#',1,r-1)-instr(val,'#',1,r-2)-1) r,
  substr(val,instr(val,'#',1,r-1)+1,instr(val,'#',1,r-0)-instr(val,'#',1,r-1)-1) p,
  substr(val,instr(val,'#',1,r-0)+1,instr(val,'#',1,r+1)-instr(val,'#',1,r-0)-1) c
from
(
  select
    val
  from
  ( select '###PS[0]###' val from dual union ( select '#'
||'_B_TREE_BITMAP_PLANS#FALSE#PS[2]#2p#'
  ||'avoid b*tree conversion to bitmap#'
||'_B_TREE_BITMAP_PLANS#FALSE#PS[4], OSF[UNIX], MF[0-22]#2p#'
  ||'avoid b*tree conversion to bitmap#'
||'_B_TREE_BITMAP_PLANS#-man-set to FALSE if Winbundle<=39#'
  ||'PS[4], OSF[WINDOWS]#2p#avoid b*tree conversion to bitmap#'
||'_B_TREE_BITMAP_PLANS#-man-set to FALSE if no SBP is installed#'
  ||'PS[5], OSF[UNIX], MF[0-0]#2p#avoid b*tree conversion to bitmap#'
||'_B_TREE_BITMAP_PLANS#-man-set to FALSE if Winbundle<=2#'
  ||'PS[5], OSF[WINDOWS]#2p#avoid b*tree conversion to bitmap#'
||'_BLOOM_FILTER_ENABLED#FALSE#PS[2]#1f#avoid wrong values#'
||'_CURSOR_FEATURES_ENABLED#10#PS[4], OSF[UNIX], MF[20-99]#2f#'
  ||'enables fix; note 1273790#'
||'_CURSOR_FEATURES_ENABLED#-man-set to 10 if Winbundle>=27#'
  ||'PS[4], OSF[WINDOWS]#2f#enables fix; note 1273790#'
||'_DB_BLOCK_NUMA#-man-set to 1 without CLM#'
  ||'OS[HP-UX IA (64-bit),HP-UX (64-bit)]##performance; note 1225732#'
||'_DISABLE_OBJSTAT_DEL_BROADCAST#FALSE#PS[5]###'
||'_ENABLE_NUMA_OPTIMIZATION#-man-set to FALSE without CLM#'
  ||'OS[HP-UX IA (64-bit),HP-UX (64-bit)]##performance; note 1225732#'
||'_EXTERNAL_SCN_REJECTION_THRESHOLD_HOURS#'
  ||'-man-set to 24 if SBP >= 201202#PS[5], MF[3-3], OSF[UNIX]###'
||'_EXTERNAL_SCN_REJECTION_THRESHOLD_HOURS#'
  ||'-man-set to 24 if Winbundle >=14#PS[5], MF[3-3], OSF[WINDOWS]###'
||'_EXTERNAL_SCN_REJECTION_THRESHOLD_HOURS#24#PS[5], MF[4-99]###'
||'_FIRST_SPARE_PARAMETER#'
  ||'-man-set to 1 if fix 6904068 is installed and 7291739 is not installed#'
  ||'PS[4], OSF[UNIX], MF[0-16]#2p#'
  ||'Avoid high CPU consumption for Mutex requests#'
||'_FIRST_SPARE_PARAMETER#-man-set to 1 if Winbundle>=13#'
  ||'PS[4], OSF[WINDOWS]#2p#'
  ||'Avoid high CPU consumption for Mutex requests#'
val from dual ) union ( select '#'
||'_FIRST_SPARE_PARAMETER#1#PS[5], OSF[UNIX], MF[1-15]#2p#'
  ||'Avoid high CPU consumption for Mutex requests#'
||'_FIRST_SPARE_PARAMETER#-man-set to 1 if Winbundle>=3#'
  ||'PS[5], OSF[WINDOWS]#2p#'
  ||'Avoid high CPU consumption for Mutex requests#'
||'_FIX_CONTROL,4728348#4728348:OFF#PS[2], MF[0-2]#1f#'
  ||'avoid wrong values; notes 964858 and 997889#'
||'_FIX_CONTROL,4728348#4728348:OFF#PS[4], OSF[UNIX], MF[0-24]#1f#'
  ||'avoid wrong values; note 1547676#'
||'_FIX_CONTROL,4728348#4728348:OFF#PS[4], OSF[WINDOWS]#1f#'
  ||'avoid wrong values; note 1547676#'
||'_FIX_CONTROL,4728348#4728348:OFF#PS[5], OSF[UNIX] MF[0-2]#1f#'
  ||'avoid wrong values; note 1547676#'
||'_FIX_CONTROL,4728348#-man-set to 4728348:OFF if Winbundle<=5#'
  ||'PS[5], OSF[WINDOWS]#1f#avoid wrong values; note 1547676#'
||'_FIX_CONTROL,5099019#5099019:ON#PS[456]#2p#'
  ||'dbms_stats counts leaf blocks correctly#'
||'_FIX_CONTROL,5705630#5705630:ON##2p#'
  ||'use optimal OR concatenation; note 176754#'
||'_FIX_CONTROL,5765456#5765456:3#PS[456]#2p#'
  ||'no further information available#'
||'_FIX_CONTROL,6055658#6055658:OFF#PS[45]#2p#'
  ||'calculate correct join card. with histograms#'
||'_FIX_CONTROL,6120483#6120483:OFF#PS[2], OSF[UNIX], MF[13-14]#2p#'
  ||'avoid wrong plan in simple query;notes 981875,1165319#'
||'_FIX_CONTROL,6120483#6120483:OFF#PS[4], OSF[UNIX], MF[0-5]#2p#'
  ||'avoid wrong plan in simple query;notes 981875,1165319#'
||'_FIX_CONTROL,6120483#'
  ||'-man-set to 6120483:OFF for Winbundle between 1 and 10#'
  ||'PS[4], OSF[WINDOWS]#2p#'
  ||'avoid wrong plan in simple query;notes 981875,1165319#'
||'_FIX_CONTROL,6221403#6221403:ON#PS[4]#2p#'
  ||'correct selectivity; note 1165319#'
||'_FIX_CONTROL,6329318#'
  ||'-man-set to 6329318:OFF if fix 6329318 is installed and 7211965 is not installed#'
  ||'PS[2]#2p#avoid between costs lower than =; note 1165319#'
val from dual ) union ( select '#'
||'_FIX_CONTROL,6329318#6329318:OFF#PS[4], OSF[UNIX], MF[1-5]#2p#'
  ||'avoid between costs lower than =; note 1165319#'
||'_FIX_CONTROL,6329318#6329318:ON#PS[4], OSF[UNIX], MF[6-99]#2p#'
  ||'avoid between costs lower than =; note 1165319#'
||'_FIX_CONTROL,6329318#'
  ||'-man-set to 6329318:OFF if 6(32bit)/8(64bit)<=Winbundle<=10#'
  ||'PS[4], OSF[WINDOWS]#2p#'
  ||'avoid between costs lower than =; note 1165319#'
||'_FIX_CONTROL,6329318#-man-set to 6329318:ON if Winbundle>=11#'
  ||'PS[4], OSF[WINDOWS]#2p#'
  ||'avoid between costs lower than =; note 1165319#'
||'_FIX_CONTROL,6399597#6399597:ON##2p#'
  ||'sort group by instead of hash group by; note 176754#'
||'_FIX_CONTROL,6430500#6430500:ON##2p#'
  ||'avoid that unique index not chosen#'
||'_FIX_CONTROL,6440977#6440977:ON##2p#'
  ||'consider redundant predicates in join; note 981875#'
||'_FIX_CONTROL,6626018#6626018:ON##2p#'
  ||'avoid to low filter costs; note 981875#'
||'_FIX_CONTROL,6660162#6660162:ON#PS[2], OSF[UNIX]#2p#'
  ||'choose right index; note 981875#'
||'_FIX_CONTROL,6670551#6670551:ON#PS[45]#2p#'
  ||'calculate stats on empty table; note 1165319#'
||'_FIX_CONTROL,6972291#6972291:ON#PS[456]#2p#'
  ||'use column group selectivity with hgrm;note 1165319#'
||'_FIX_CONTROL,7325597#7325597:ON#PS[24]#2p#'
  ||'Avoid expensive index only access#'
||'_FIX_CONTROL,7692248#7692248:ON#PS[45]#2p#'
  ||'collect always histogram information#'
||'_FIX_CONTROL,7891471#7891471:ON#PS[45]#2p#'
  ||'speed up order by with first_rows_10#'
||'_FIX_CONTROL,9196440#9196440:ON#PS[45]#2p#'
  ||'fixes low distinct keys in index stats#'
||'_FIX_CONTROL,9495669#9495669:ON#PS[45]#2p#'
  ||'disable histogram use for join cardinality#'
||'_FIX_CONTROL,13627489#13627489:ON#PS[5]#2p#'
  ||'fixes bad access path for merge within in#'
val from dual ) union ( select '#'
||'_IN_MEMORY_UNDO#FALSE#PS[2]#1f#avoid corruptions#'
||'_INDEX_JOIN_ENABLED#FALSE#PS[2]#1f#'
  ||'avoid wrong values; workaround for note 981875#'
||'_OPTIM_PEEK_USER_BINDS#FALSE##1p#avoid bind value peeking#'
||'_OPTIMIZER_MJC_ENABLED#FALSE##2p#'
  ||'avoid cartesian merge joins in general#'
||'_PUSH_JOIN_UNION_VIEW#'
  ||'-man-set to FALSE if fix 7155655 is not installed#'
  ||'PS[4], OSF[UNIX], MF[0-6]#1f#avoid wrong values#'
||'_PUSH_JOIN_UNION_VIEW#-man-set to FALSE if Winbundle<=10#'
  ||'PS[4], OSF[WINDOWS]#1f#avoid wrong values#'
||'_SECOND_SPARE_PARAMETER#'
  ||'-man-set to 1 if fixes 6904068 and 7291739 are installed#'
  ||'PS[4], OSF[UNIX], MF[0-16]#2p#'
  ||'Avoid high CPU consumption for Mutex requests#'
||'_SECOND_SPARE_PARAMETER#1#PS[4], OSF[UNIX], MF[20-99]#2p#'
  ||'Avoid high CPU consumption for Mutex requests#'
||'_SORT_ELIMINATION_COST_RATIO#10##2p#'
  ||'use non-order-by-sorted indexes (first_rows)#'
||'_TABLE_LOOKUP_PREFETCH_SIZE#0#PS[2]#1f#'
  ||'avoid wrong values; note 1109753#'
||'BACKGROUND_DUMP_DEST#/oracle/[SID]/saptrace/background#OSF[UNIX]###'
||'BACKGROUND_DUMP_DEST#[DRIVE]:\oracle\[SID]\saptrace\background#'
  ||'OSF[WINDOWS]###'
||'CLUSTER_DATABASE#TRUE#RAC[TRUE]###'
||'COMMIT_WRITE#-del-##1f##'
||'COMPATIBLE#10.2.0##1f##'
||'CONTROL_FILE_RECORD_KEEP_TIME#>=30####'
||'CONTROL_FILES#-man-three copies on different disk areas####'
||'CORE_DUMP_DEST#/oracle/[SID]/saptrace/background#OSF[UNIX]###'
||'CORE_DUMP_DEST#[DRIVE]:\oracle\[SID]\saptrace\background#'
  ||'OSF[WINDOWS]###'
||'DB_BLOCK_BUFFERS#-del-####'
||'DB_BLOCK_SIZE#8192####'
||'DB_CACHE_SIZE#-man-appropriately set####'
||'DB_FILE_MULTIBLOCK_READ_COUNT#-del-##1p##'
||'DB_FILES#-man-set larger than short term expected datafiles####'
||'DB_NAME#[SID]####'
val from dual ) union ( select '#'
||'DB_WRITER_PROCESSES#'
  ||'-man-change default in case of dbwr problems only####'
||'EVENT,10027#10027 trace name context forever, level 1##2f#'
  ||'avoid process state dump at deadlock#'
||'EVENT,10028#10028 trace name context forever, level 1##2f#'
  ||'do not wait while writing deadlock trace#'
||'EVENT,10049#-man-set with level 2 if Winbundle in (5,6,7,8,9)#'
  ||'PS[4], OSF[WINDOWS]#2p#'
  ||'avoid ORA-07445/ORA-00600 as of Winbundle 5#'
||'EVENT,10091#10091 trace name context forever, level 1#PS[2]#2p#'
  ||'avoid CU Enqueue during parsing#'
||'EVENT,10091#10091 trace name context forever, level 1#'
  ||'PS[4], OSF[UNIX], MF[0-2]#2p#avoid CU Enqueue during parsing#'
||'EVENT,10091#-man-set with level 1 if Winbundle<=6(32bit)/8(64bit)#'
  ||'PS[4], OSF[WINDOWS]#2p#avoid CU Enqueue during parsing#'
||'EVENT,10142#10142 trace name context forever, level 1##2p#'
  ||'avoid Btree Bitmap Conversion plans#'
||'EVENT,10162#10162 trace name context forever, level 1#PS[2]#1f#'
  ||'avoid wrong values#'
||'EVENT,10183#10183 trace name context forever, level 1##1p#'
  ||'avoid rounding during cost calculation#'
||'EVENT,10191#10191 trace name context forever, level 1##2f#'
  ||'avoid high CBO memory consumption#'
||'EVENT,10411#10411 trace name context forever, level 1#'
  ||'PS[45], OSF[UNIX]#2f#fixes int-does-not-correspond-to-number bug#'
||'EVENT,10411#-man-set with level 1 if Winbundle>=2#'
  ||'PS[4], OSF[WINDOWS]#2f#'
  ||'fixes int-does-not-correspond-to-number bug#'
||'EVENT,10411#-man-set with level 1 if Winbundle>=3#'
  ||'PS[5], OSF[WINDOWS]#2f#'
  ||'fixes int-does-not-correspond-to-number bug#'
||'EVENT,10629#10629 trace name context forever, level 32##2f#'
  ||'influence rebuild online error handling#'
||'EVENT,10753#10753 trace name context forever, level 2#PS[4]#1f#'
  ||'avoid wrong values caused by prefetch; note 1351737#'
val from dual ) union ( select '#'
||'EVENT,10891#10891 trace name context forever, level 1#PS[12]#2p#'
  ||'avoid high parsing times joining many tables#'
||'EVENT,14532#-man-set with level 1 if fix 5618049 is installed#'
  ||'PS[2]#2f#avoid massive shared pool consumption#'
||'EVENT,14532#14532 trace name context forever, level 1#PS[456]#2f#'
  ||'avoid massive shared pool consumption#'
||'EVENT,31991#31991 trace name context forever, level 1#'
  ||'OSF[UNIX], PS[5], MF[5-99]###'
||'EVENT,31991#-man-set with level 1 if SBP>=201207 is installed#'
  ||'OSF[UNIX], PS[5], MF[4-4]###'
||'EVENT,38068#38068 trace name context forever, level 100##2p#'
  ||'long raw statistic; implement note 948197#'
||'EVENT,38085#38085 trace name context forever, level 1#PS[456]#2p#'
  ||'consider cost adjust for index fast full scan#'
||'EVENT,38087#-man-set with level 1 if fix 5842686 is installed#'
  ||'PS[2]#1f#avoid ora-600 at star transformation#'
||'EVENT,38087#38087 trace name context forever, level 1#PS[456]#1f#'
  ||'avoid ora-600 at star transformation#'
||'EVENT,44951#-man-set with level 1024 if fix 6376915 is installed#'
  ||'PS[2]#2p#avoid HW enqueues during LOB inserts#'
||'EVENT,44951#44951 trace name context forever, level 1024#PS[456]#'
  ||'2p#avoid HW enqueues during LOB inserts#'
||'FILESYSTEMIO_OPTIONS#SETALL##1p#note 793113#'
||'HPUX_SCHED_NOAGE#178#RAC[FALSE]##performance#'
||'LOG_ARCHIVE_DEST#-del-####'
||'LOG_ARCHIVE_DEST_1#LOCATION=/oracle/[SID]/oraarch/[SID]arch#'
  ||'OSF[UNIX]##note 966073#'
||'LOG_ARCHIVE_DEST_1#'
  ||'LOCATION=[drive]:\oracle\[SID]\oraarch\[SID]arch#OSF[WINDOWS]##'
  ||'note 966073#'
||'LOG_ARCHIVE_FORMAT#%t_%s_%r.dbf####'
||'LOG_BUFFER#>=1048576##2p##'
||'LOG_CHECKPOINTS_TO_ALERT#TRUE####'
||'MAX_DUMP_FILE_SIZE#20000####'
||'NLS_LENGTH_SEMANTICS#-del-##2f##'
val from dual ) union ( select '#'
||'OPEN_CURSORS#>=800####'
||'OPTIMIZER_DYNAMIC_SAMPLING#-del-#BW[FALSE]#1p##'
||'OPTIMIZER_DYNAMIC_SAMPLING#6#PS[456], BW[TRUE]#1p##'
||'OPTIMIZER_DYNAMIC_SAMPLING#-man-OLTP: do not set; OLAP: 6#'
  ||'BW[UNKNOWN]#1p##'
||'OPTIMIZER_FEATURES_ENABLE#-del-##1p##'
||'OPTIMIZER_INDEX_CACHING#-del-##2p#'
  ||'est. % of index cached (inlist, nested loop)#'
||'OPTIMIZER_INDEX_COST_ADJ#20#BW[FALSE]#1p##'
||'OPTIMIZER_INDEX_COST_ADJ#-del-#BW[TRUE]#1p##'
||'OPTIMIZER_INDEX_COST_ADJ#-man-OLTP: 20; OLAP: do not set#'
  ||'BW[UNKNOWN]###'
||'OPTIMIZER_MODE#-del-##1p##'
||'PARALLEL_EXECUTION_MESSAGE_SIZE#16384##2p##'
||'PARALLEL_MAX_SERVERS#-man-Number of DB machine CPU CORES*10###'
  ||'CPU_COUNT=[CPU_COUNT]#'
||'PARALLEL_THREADS_PER_CPU#1##2p##'
||'PGA_AGGREGATE_TARGET#-man-appropriately set####'
||'PROCESSES#-man-formula how to set in parameter note###'
  ||'dependent: SESSIONS#'
||'QUERY_REWRITE_ENABLED#FALSE##2p##'
||'RECYCLEBIN#OFF##1f##'
||'REMOTE_OS_AUTHENT#'
  ||'-man-set to TRUE on ABAP stack systems with a Unix App. Server without SSFS (note 1622837)#'
  ||'###'
||'REPLICATION_DEPENDENCY_TRACKING#-any-####'
||'SESSIONS#-man-2*PROCESSES###PROCESSES=[PROCESSES]#'
||'SHARED_POOL_SIZE#appropriately set; note 690241####'
||'STAR_TRANSFORMATION_ENABLED#TRUE##1p##'
||'UNDO_MANAGEMENT#AUTO####'
||'UNDO_RETENTION#-man-appropriately set####'
||'UNDO_TABLESPACE#PSAPUNDO#RAC[FALSE]###'
||'UNDO_TABLESPACE#-man-appropriately set#RAC[TRUE]###'
||'USER_DUMP_DEST#/oracle/[SID]/saptrace/usertrace#OSF[UNIX]###'
||'USER_DUMP_DEST#[DRIVE]:\oracle\[SID]\saptrace\usertrace#'
  ||'OSF[WINDOWS]###'
val from dual )
  )
),
(
  select
    rownum*5 r
  from
    v$parameter2
  where rownum <= 40
)
where
  val != '#' and
  substr(val,instr(val,'#',1,r-4)+1,
  instr(val,'#',1,r-3)-instr(val,'#',1,r-4)-1) is not null
        )),
        gv$instance i
      )
o,
      ( SELECT
          inst_id,
          upper(RESOURCE_NAME) RESOURCE_NAME,
          limit_value,
          MAX_UTILIZATION
        FROM
          gv$RESOURCE_LIMIT
        WHERE
          RESOURCE_NAME IN (
            'processes',
            'sessions',
            'parallel_max_servers')
      )
x_rl,
      ( select
          pga.inst_id,
          pga.value max_since_start,
          param.value limit_value
        from
          gv$pgastat pga,
          gv$parameter2 param
        where
          pga.inst_id=param.inst_id and
          pga.name='maximum PGA allocated' and
          param.name='pga_aggregate_target')
x_pgastat,
      ( select
          inst_id,
          max(decode(name,'processes',value,null)) processes,
          max(decode(name,'parallel_max_servers',value,null)) para_max,
          max(decode(name,'cpu_count',value,null)) cpu_count,
          max(decode(name,'shared_pool_size',value,null))/1024/1024 shared_pool_size_mb,
          max(decode(name,'sga_target',value,null)) sga_target,
          max(decode(name,'cluster_database',value,null)) cluster_database,
          max(decode(name,'db_cache_size',value,null)) db_cache_size,
          ( max(decode(name,'cpu_count',value,null))/4*350+
            max(decode(name,'db_cache_size',value,null))/1024/1024/1024*5+300)*
            decode(max(decode(name,'cluster_database',value,null)), 'TRUE', 1.2, 1) calculated_shared_pool_size_mb
        from
          gv$parameter2
        where
          name in
          (
            'processes',
            'parallel_max_servers',
            'cpu_count',
            'shared_pool_size',
            'sga_target',
            'cluster_database',
            'db_cache_size'
          )
        group by
          inst_id )
x_parameter,
      ( select inst_id, max(UNXPBLKRELCNT+UNXPBLKREUCNT) max_stolen from gv$undostat group by inst_id)
x_undostat,
      (
        select
          max(bf.nr) mergefix_at_least,
          decode(substr(max(dt.mf_date),max(bf.nr)*7+1,1),
          '=','20',
          '<','before 20')||
          substr(max(dt.mf_date),max(bf.nr)*7+2,2)||'-'||
          substr(max(dt.mf_date),max(bf.nr)*7+4,2)||'-'||
          substr(max(dt.mf_date),max(bf.nr)*7+6,2) mergefix_released
        from
        (
          select
            decode(substr(val,instr(val,'#',1,r-2)+1,
              instr(val,'#',1,r-1)-instr(val,'#',1,r-2)-1),
              'A','10.2.0.2',
              'B','10.2.0.4',
              'C','10.2.0.5',
              '?') patchset,
            to_number(substr(val,instr(val,'#',1,r-1)+1,
              instr(val,'#',1,r-0)-instr(val,'#',1,r-1)-1)) bg,
            to_number(substr(val,instr(val,'#',1,r-0)+1,
              instr(val,'#',1,r+1)-instr(val,'#',1,r-0)-1)) nr
          from
          ( select '#'||
'A#5648287#16#A#6440977#14#A#6120483#13#A#6660162#12#A#6251917#11#'||
'A#6062266#10#A#6087237#9#A#5882954#8#A#4708389#8#A#5944076#7#'||
'A#5680702#6#A#5884780#3#A#5084239#2#A#5912195#1#A#-1#0#'||
'B#7592673#27#B#6055658#26#B#6503543#25#B#9668086#24#B#6994194#23#'||
'B#6086930#22#B#9196440#21#B#9495669#20#B#8855396#16#B#8213977#15#'||
'B#8247017#14#B#8355120#13#B#5394888#12#B#7272039#11#B#5099019#10#'||
'B#7295298#8#B#7430474#7#B#5648287#6#B#7138405#5#B#6399597#4#'||
'B#6221403#3#B#5714944#1#B#-1#0#'||
'C#14254795#6#'||
'C#13627489#5#C#13618170#4#C#7592673#3#C#6055658#2#C#9196440#1#C#-1#0#'
        val from dual
          ),
          ( select rownum*3 r from v$parameter2 )
          where
            substr(val,instr(val,'#',1,r-1)+1,
              instr(val,'#',1,r-0)-instr(val,'#',1,r-1)-1) is not null
        ) bf,
        ( select bugno from v$system_fix_control union
          ( select to_number('-1') bugno from dual )
        ) fc,
          v$instance i,
        ( select
'10.2.0.2' version,
'<070831<070831<070831<070831<070831<070831<070831=070831=071207'||
'=071207=080221=080221=080714=080714=080714=090112=090112' mf_date
          from dual union ( select
'10.2.0.4' version,
'<080711=080711=080711=080711=081107=081107=081107=081107=081210'||
'=090212=090212=090310=090508=090610=090810=091010=091220=100510'||
'=100510=100510=100510=100710=100910=101010=110210=110410=110510'||
'=110610' mf_date
          from dual ) union ( select
'10.2.0.5' version,
'<101110=101110=110510=110610=120610=120810=121110' mf_date
          from dual )
        ) dt
        where
          bf.bg=fc.bugno and
          substr(i.version,1,instr(i.version,'.',1,4)-1)=bf.patchset and
          bf.patchset=dt.version
      )
x_mergefix,
      (
        select
          decode(sign(nvl(sum(decode(sfc.bugno,null,1,0)),0)),1,0,1) reliable
        from
        (
          select
            substr(trim(translate(a.value,chr(10)||chr(13)||chr(9),'   ')),1,instr(trim(a.value),':')-1) subname
          from
          (
            select
              vparam.inst_id,
              substr(','||vparam.value,
               instr(','||vparam.value,',',1,vcnt.cnt)+1,
               decode(instr(','||vparam.value,',',1,vcnt.cnt+1),
                 0,length(','||vparam.value),
                 instr(','||vparam.value,',',1,vcnt.cnt+1)-1)-
               decode(instr(','||vparam.value,',',1,vcnt.cnt),
                 0,length(','||vparam.value),
                 instr(','||vparam.value,',',1,vcnt.cnt))) value
            from
              gv$parameter vparam,
              (select rownum cnt from gv$parameter2 where rownum <= 20) vcnt
            where
              vparam.name='_fix_control'
          ) a
          where
            a.value is not null
        ) b,
          v$system_fix_control sfc
        where
          b.subname=to_char(sfc.bugno(+))
      )
x_fix_control_reliable,
        v$system_fix_control
x_fix_control,
      ( select decode(instr(value,'/'),0,'WINDOWS','UNIX') os_family from
          v$parameter2 where name = 'control_files' and rownum < 2)
x_os_family,
      ( select decode(substr(upper('<OLAP System? [n]>'),1,1),
        'Y','TRUE',
        '?','UNKNOWN',
        'FALSE') olap from dual )
x_olap,
        v$database
x_database,
      ( select count(*) value from v$datafile )
x_datafile_count,
      ( select count(*) contains_colon from gv$parameter2 where name = 'event' and instr(value,':')>0)
x_event
      where
        o.inst_id = x_rl.inst_id(+) and
        o.n = x_rl.RESOURCE_NAME(+) and
        o.inst_id = x_pgastat.inst_id(+) and
        o.inst_id = x_parameter.inst_id and
        o.inst_id = x_undostat.inst_id(+) and
        (o.r_mf is null or
         x_mergefix.mergefix_at_least between
           to_number(substr(o.r_mf,1,instr(o.r_mf,'-')-1)) and
           to_number(substr(o.r_mf,instr(o.r_mf,'-')+1))) and
        lower(decode(instr(o.n,','),0,' ',substr(o.n,instr(o.n,',')+1)))=
          to_char(x_fix_control.bugno(+)) and
        decode(x_fix_control.bugno(+),
          null, decode(instr(lower(o.n),'_fix_control'),
            0,'OK',
            'HIDE'),
          'OK')='OK' and
        (o.r_osf is null or instr(o.r_osf, x_os_family.os_family)>0) and
        (o.r_os is null or instr(o.r_os, x_database.platform_name)>0) and
        (o.r_rac is null or o.r_rac = x_parameter.cluster_database) and
        (o.r_bw is null or o.r_bw = x_olap.olap ) and
        (o.r_ps is null or instr(o.r_ps,decode(substr(o.version,1,7),
          '10.2.0.',substr(o.version,8,1),'?'))>0)
    )
    where hide='FALSE'
  ) s,
  (
    select
      inst_id,
      name,
      subname,
      trim(substr(max(sort_string),1,5)) isdefault,
      substr(max(sort_string),6)||
        decode(count(*),1,'',
        decode(name,'event','',
        decode(substr(name,1,1),'_','',
        ', ...'))) value,
      max(ismodified) ismodified
    from
    (
      select
        inst_id,
        lower(name) name,
        ' ' subname,
        concat(lpad(isdefault,5),value) sort_string,
        ismodified
      from
        gv$parameter2
      where
        name not in ('event','_fix_control')
      union
      (
        select
          a.inst_id,
          a.name,
          substr(trim(translate(value,
            chr(10)||chr(13)||chr(9),'   ')),1,decode(a.name,'event',5,instr(trim(value),':')-1)) subname,
          concat('FALSE',trim(translate(value,
            chr(10)||chr(13)||chr(9),'  '))) sort_string,
          a.ismodified
        from
        (
          select
            vparam.inst_id,
            vparam.name,
            substr(decode(vparam.name,'event',':',',')||vparam.value,
             instr(decode(vparam.name,'event',':',',')||vparam.value,decode(vparam.name,'event',':',','),1,vcnt.cnt)+1,
             decode(instr(decode(vparam.name,'event',':',',')||vparam.value,decode(vparam.name,'event',':',','),1,vcnt.cnt+1),
               0,length(decode(vparam.name,'event',':',',')||vparam.value),
               instr(decode(vparam.name,'event',':',',')||vparam.value,decode(vparam.name,'event',':',','),1,vcnt.cnt+1)-1)-
             decode(instr(decode(vparam.name,'event',':',',')||vparam.value,decode(vparam.name,'event',':',','),1,vcnt.cnt),
               0,length(decode(vparam.name,'event',':',',')||vparam.value),
               instr(decode(vparam.name,'event',':',',')||vparam.value,decode(vparam.name,'event',':',','),1,vcnt.cnt))) value,
            vparam.ismodified
          from
            gv$parameter2 vparam,
            (select rownum cnt from gv$parameter2 where rownum <= 20) vcnt
          where
            vparam.name in ('event','_fix_control')
        ) a
        where
          value is not null
      )
      union
      (
        select
          inst_id,
          decode(substr(lower(n),1,5),
            'event','event',
            '_fix_','_fix_control',
            lower(n)) name,
          decode(substr(lower(n),1,5),
            'event',substr(n,7),
            '_fix_',substr(n,14),
            ' ') subname,
          ' TRUE ' sort_string,
          'FALSE' ismodified
        from
        (
          select
            inst_id,
            '*** INFORMATION '||lpad(rownum,2)||
            ' ***' n
          from
            gv$mystat
          where
            rownum < 12
          union
          (
          select
            inst_id,
            n
          from
          (
            select
              substr(val,instr(val,'#',1,r-0)+1,
                instr(val,'#',1,r+1)-instr(val,'#',1,r-0)-1) n
            from
            ( select '#'||
'_B_TREE_BITMAP_PLANS#_BLOOM_FILTER_ENABLED#'||
'_CURSOR_FEATURES_ENABLED#'||
'_DB_BLOCK_NUMA#_DISABLE_OBJSTAT_DEL_BROADCAST#'||
'_ENABLE_NUMA_OPTIMIZATION#_EXTERNAL_SCN_REJECTION_THRESHOLD_HOURS#'||
'_FIRST_SPARE_PARAMETER#'||
'_FIX_CONTROL 4728348#_FIX_CONTROL 5099019#_FIX_CONTROL 5705630#'||
  '_FIX_CONTROL 5765456#_FIX_CONTROL 6055658#_FIX_CONTROL 6120483#'||
  '_FIX_CONTROL 6221403#_FIX_CONTROL 6329318#_FIX_CONTROL 6399597#'||
  '_FIX_CONTROL 6430500#_FIX_CONTROL 6440977#_FIX_CONTROL 6626018#'||
  '_FIX_CONTROL 6660162#_FIX_CONTROL 6670551#_FIX_CONTROL 6972291#'||
  '_FIX_CONTROL 7325597#_FIX_CONTROL 7692248#_FIX_CONTROL 7891471#'||
  '_FIX_CONTROL 9495669#_FIX_CONTROL 9196440#_FIX_CONTROL 13627489#'||
'_INDEX_JOIN_ENABLED#_IN_MEMORY_UNDO#'||
'_OPTIM_PEEK_USER_BINDS#_OPTIMIZER_MJC_ENABLED#'||
'_PUSH_JOIN_UNION_VIEW#'||
'_SECOND_SPARE_PARAMETER#_SORT_ELIMINATION_COST_RATIO#'||
'_TABLE_LOOKUP_PREFETCH_SIZE#'||
'EVENT 10027#EVENT 10028#EVENT 10049#EVENT 10091#EVENT 10142#'||
  'EVENT 10162#EVENT 10183#EVENT 10191#EVENT 10411#EVENT 10629#'||
  'EVENT 10753#EVENT 10891#EVENT 14532#EVENT 31991#EVENT 38068#'||
  'EVENT 38085#EVENT 38087#EVENT 44951#'
              val from dual
            ),
            ( select rownum r from v$parameter2 )
            where
              substr(val,instr(val,'#',1,r-0)+1,
                instr(val,'#',1,r+1)-instr(val,'#',1,r-0)-1) is not null
          ),
          gv$instance)
        ) underscore
      )
    )
    group by
      inst_id,
      name,
      subname
  ) c
  where
    c.inst_id=s.inst_id(+) and
    c.name=s.name(+) and
    c.subname=s.subname(+)
)
order by
  id,
  i,
  u,
  name,
  inst_id;
                                                                                  