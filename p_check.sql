set linesize 360
set pagesize 1000
COLUMN name             FORMAT  a40
COLUMN set              FORMAT  a8
COLUMN remark          FORMAT   a60
COLUMN recommendation  FORMAT   a120
COLUMN is_value        FORMAT   a50
COLUMN should_be_value FORMAT a50 

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
'Parametercheck for Oracle 11.2 based on Note/Version: 1431798/90',
          ' 2',
'Parametercheck last changed: 2014-08-14',
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
decode(x_abap_stack,'TRUE',', ABAP stack',', not ABAP stack')||
decode(x_cluster_database,'TRUE',', RAC',', not RAC')||
decode(x_asm_used,'TRUE',', ASM',', not ASM')||
decode(x_exadata_used,'TRUE',', EXADATA',', not EXADATA'),
          ' 7',
'DB Platform: '||x_platform_name||decode(x_cluster_database,
'TRUE',' (data of instance '||c.inst_id||')',''),
          ' 8',
'DB Patchset: '||x_version||decode(x_cluster_database,
'TRUE',' (data of instance '||c.inst_id||')',''),
          ' 9',
'Last detectable SAP Bundle Patch: '||decode(x_mergefix,
    0,'none',
    x_mergefix_released||' (identified by bugno '||x_bugno||')')||decode(x_cluster_database,
'TRUE',' (data of instance '||c.inst_id||')',''),
          '10',
'Reliability checks: events '||decode(x_event_contains_colon,
  0,'passed',
  'FAILED [event separator ":"'||
  ' unsupported; see note 1431798]')||
', _fix_controls '||decode(x_fix_control_reliable,
  1,'passed',
  'FAILED [not all _fix_controls are in'||
  ' v$system_fix_control; note 1454675 ]')||
decode(x_cluster_database,
  'FALSE',' ',
  ', RAC Bug: '||
  decode(substr(x_version,1,8),
    '11.2.0.2',decode(sign(x_mergefix-9),
      -1,'FAILED (note 1171650)',
      'passed'),
    '11.2.0.3',decode(sign(x_mergefix-3),
      -1,'FAILED (note 1171650)',
      'passed'),
    'passed')),
          '11',
decode(instr('1234',substr(x_version,8,1)),0,
'WARNING: unsupp. patchset used =>'||
' recommendations may not be valid =>'||
' apply latest patchset (note 1431799)',
decode(instr('12',substr(x_version,8,1)),0,
'- no further information -',
'WARNING: no further SBP will be'||
' released for this patchset =>'||
' apply latest patchset (note 1431799)'))),
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
      x_bugno,
      x_mergefix_released,
      x_cluster_database,
      x_asm_used,
      x_exadata_used,
      x_abap_stack,
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
            0,decode(sign(x_parameter.shared_pool_size_mb-0.5*x_parameter.calculated_shared_pool_size_mb),
              -1,'-man-'||o.w,
              decode(sign(x_parameter.shared_pool_size_mb-2*x_parameter.calculated_shared_pool_size_mb),
                1,'-man-'||o.w,
                '-aut-'||o.w)),
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
            0,'current: '||round(x_parameter.shared_pool_size_mb)||
              ' MB; calculated: '||round(x_parameter.calculated_shared_pool_size_mb)||' MB',
            'ASMM is used (sga_target>0)'),                                    
          'UNDO_RETENTION','Max unexpired stolen blocks (gv$undostat): '||x_undostat.max_stolen,
          o.c) "comment",
        decode(instr(lower(o.n),'_fix_control'),0,'FALSE',decode(x_fix_control.bugno,null,'TRUE','FALSE')) hide,
        x_mergefix.mergefix_at_least x_mergefix,
        x_mergefix.bugno x_bugno,
        x_mergefix.mergefix_released x_mergefix_released,
        x_parameter.cluster_database x_cluster_database,
        x_feature_used.asm_used x_asm_used,
        x_feature_used.exadata_used x_exadata_used,
        x_abap_stack.abap_stack x_abap_stack,
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
          decode(instr(' '||r,'ABAP['),0,'',
            substr(r,instr(r,'ABAP[')+5,instr(r,']',
            instr(r,'ABAP['))-instr(r,'ABAP[')-5)) r_abap,
          decode(instr(' '||r,'OS['),0,'',
            substr(r,instr(r,'OS[')+3,instr(r,']',
            instr(r,'OS['))-instr(r,'OS[')-3)) r_os,
          decode(instr(' '||r,'OSF['),0,'',
            substr(r,instr(r,'OSF[')+4,instr(r,']',
            instr(r,'OSF['))-instr(r,'OSF[')-4)) r_osf,
          decode(instr(' '||r,'ASM['),0,'',
            substr(r,instr(r,'ASM[')+4,instr(r,']',
            instr(r,'ASM['))-instr(r,'ASM[')-4)) r_asm,
          decode(instr(' '||r,'EXADATA['),0,'',
            substr(r,instr(r,'EXADATA[')+8,instr(r,']',
            instr(r,'EXADATA['))-instr(r,'EXADATA[')-8)) r_exadata            
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
  ( select '###PS[0]###' val from dual union all ( select '#'
||'_AWR_MMON_DEEP_PURGE_ALL_EXPIRED#TRUE#PS[4]###'
||'_B_TREE_BITMAP_PLANS#FALSE#PS[1], OSF[UNIX], MF[0-1]#2p#'
  ||'avoid bitmap operations when using B*TREE indexes#'
||'_B_TREE_BITMAP_PLANS#-man-set to FALSE if SBP date<=201009#'
  ||'PS[1], OSF[UNIX], MF[2-2]#2p#'
  ||'avoid bitmap operations when using B*TREE indexes#'
||'_B_TREE_BITMAP_PLANS#-man-set to FALSE if Winbundle<=5#'
  ||'PS[1], OSF[WINDOWS]#2p#'
  ||'avoid bitmap operations when using B*TREE indexes#'
||'_BUG16850197_ENABLE_FIX_FOR_13602883#1#PS[3], OSF[UNIX], MF[12-12]#'
  ||'2f#avoids instance crash with ORA-600: [kjruch:resp]#'
||'_DISABLE_CELL_OPTIMIZED_BACKUPS#TRUE#'
  ||'PS[2], OSF[UNIX], EXADATA[TRUE]###'
||'_DISABLE_CELL_OPTIMIZED_BACKUPS#TRUE#'
  ||'PS[3], MF[0-13], OSF[UNIX], EXADATA[TRUE]###'
||'_ENABLE_NUMA_SUPPORT#'
  ||'-man-set optionally to TRUE after successful test##2p##'
||'_FIFTH_SPARE_PARAMETER#-man-set to 1 if SBP date>=201212#'
  ||'PS[2], OSF[UNIX], MF[12-12]#2p#'
  ||'consider blck chg track during inc. Backups#'
||'_FIFTH_SPARE_PARAMETER#1#PS[2], OSF[UNIX], MF[13-13]#2p#'
  ||'consider blck chg track during inc. Backups#'
||'_FILE_SIZE_INCREASE_INCREMENT#2143289344#'
  ||'PS[3], OSF[UNIX], MF[0-12], EXADATA[TRUE]###'
||'_FIRST_SPARE_PARAMETER#-man-set to 1 if Winbundle>=14#'
  ||'PS[3], OSF[WINDOWS]#2p#'
  ||'avoid high CPU consumption for Mutex requests#'
||'_FIRST_SPARE_PARAMETER#1#PS[2], OSF[UNIX], MF[1-2]#2p#'
  ||'avoid high CPU consumption for Mutex requests#'
||'_FIX_CONTROL,4728348#4728348:OFF#PS[1], OSF[UNIX], MF[0-1]#1f#'
  ||'avoid wrong values; note 1547676#'
||'_FIX_CONTROL,4728348#-man-set to 4728348:OFF if SBP date<=201101#'
  ||'PS[1], OSF[UNIX], MF[2-2]#1f#avoid wrong values; note 1547676#'
||'_FIX_CONTROL,4728348#-man-set to 4728348:OFF if Winbundle<=10#'
  ||'PS[1], OSF[WINDOWS]#1f#avoid wrong values; note 1547676#'
val from dual ) union all ( select '#'
||'_FIX_CONTROL,4728348#4728348:OFF#PS[2], OSF[UNIX], MF[0-1]#1f#'
  ||'avoid wrong values; note 1547676#'
||'_FIX_CONTROL,5099019#5099019:ON##2p#'
  ||'dbms_stats counts leaf blocks correctly#'
||'_FIX_CONTROL,5705630#5705630:ON##2p#'
  ||'use optimal OR concatenation; note 176754#'
||'_FIX_CONTROL,6055658#6055658:OFF##2p#'
  ||'calculate correct join card. with histograms#'
||'_FIX_CONTROL,6120483#6120483:OFF##2p##'
||'_FIX_CONTROL,6399597#6399597:ON##2p#'
  ||'sort group by instead of hash group by; note 176754#'
||'_FIX_CONTROL,6430500#6430500:ON##2p#'
  ||'avoid that unique index not chosen#'
||'_FIX_CONTROL,6440977#6440977:ON##2p#'
  ||'consider redundant predicates in join; note 981875#'
||'_FIX_CONTROL,6626018#6626018:ON##2p#'
  ||'avoid to low filter costs; note 981875#'
||'_FIX_CONTROL,6972291#6972291:ON##2p#'
  ||'use column group selectivity with hgrm;note 1165319#'
||'_FIX_CONTROL,7168184#7168184:OFF##2f#'
  ||'avoid multi-column/bloom filter problems on comp. Tab.#'
||'_FIX_CONTROL,8937971#8937971:ON##2f#'
  ||'correct clause definition dbms_metadata.get_ddl#'
||'_FIX_CONTROL,9196440#9196440:ON##2p#'
  ||'fixes low distinct keys in index stats#'
||'_FIX_CONTROL,9495669#9495669:ON##2p#'
  ||'disable histogram use for join cardinality#'
||'_FIX_CONTROL,12693573#12693573:OFF#PS[23], EXADATA[TRUE]#2p##'
||'_FIX_CONTROL,13077335#13077335:ON##2p#'
  ||'correct long varchar cardinality calculation with histgr#'
||'_FIX_CONTROL,13627489#13627489:ON##2p#'
  ||'use good access for merge in dbms_redefinition#'
||'_FIX_CONTROL,14255600#14255600:ON#PS[4]#2p#'
  ||'statistic collection during index creation#'
||'_FIX_CONTROL,14255600#14255600:ON#PS[3], OSF[UNIX], MF[9-99]#2p#'
  ||'statistic collection during index creation#'
||'_FIX_CONTROL,14255600#-man-set to 14255600:ON if Winbundle>=17#'
  ||'PS[3], OSF[WINDOWS]#2p#'
  ||'statistic collection during index creation#'
val from dual ) union all ( select '#'
||'_FIX_CONTROL,14255600#14255600:ON#'
  ||'PS[2], OSF[UNIX], MF[14-99], EXADATA[FALSE]#2p#'
  ||'statistic collection during index creation#'
||'_FIX_CONTROL,14255600#14255600:ON#'
  ||'PS[2], OSF[UNIX], MF[15-99], EXADATA[TRUE]#2p#'
  ||'statistic collection during index creation#'
||'_FIX_CONTROL,14255600#-man-set to 14255600:ON if SXD date=201306#'
  ||'PS[2], OSF[UNIX], MF[14-14], EXADATA[TRUE]#2p#'
  ||'statistic collection during index creation#'
||'_FIX_CONTROL,14255600#-man-set to 14255600:ON if Winbundle>=25#'
  ||'PS[2], OSF[WINDOWS]#2p#'
  ||'statistic collection during index creation#'
||'_FIX_CONTROL,14595273#14595273:ON#PS[34]#2p##'
||'_FIX_CONTROL,18405517#18405517:2#PS[34]#2p##'
||'_GC_OVERRIDE_FORCE_CR#FALSE#'
  ||'PS [3], OSF[UNIX], MF[14-14], RAC[TRUE]#1f#'
  ||'can lead to outage of DB (note 2048023)#'
||'_GC_OVERRIDE_FORCE_CR#-man-set to FALSE if SBP date >=201402#'
  ||'PS [3], OSF[UNIX], MF[13-13], RAC[TRUE]#1f#'
  ||'can lead to outage of DB (note 2048023)#'
||'_GC_OVERRIDE_FORCE_CR#-man-set to FALSE if 28 <= Winbundle <= 32#'
  ||'PS [3], OSF[WINDOWS], RAC[TRUE]#1f#'
  ||'can lead to outage of DB (note 2048023)#'
||'_IN_MEMORY_UNDO#FALSE#PS[1]#1f##'
||'_KTB_DEBUG_FLAGS#8##1f#'
  ||'avoid invalid index block SCNs on STDBY; note 2005311#'
||'_MUTEX_WAIT_SCHEME#1#PS[2], OSF[UNIX], MF[3-99]#2p#'
  ||'controls mutex spins/waits; note 1588876#'
||'_MUTEX_WAIT_SCHEME#1#PS[34], OSF[UNIX]#2p#'
  ||'controls mutex spins/waits; note 1588876#'
||'_MUTEX_WAIT_SCHEME#1#PS[234], OSF[WINDOWS]#2p#'
  ||'controls mutex spins/waits; note 1588876#'
||'_MUTEX_WAIT_TIME#10#PS[2], OSF[UNIX], MF[3-99]#2p#'
  ||'controls mutex spins/waits; note 1588876#'
||'_MUTEX_WAIT_TIME#10#PS[34]#2p#'
  ||'controls mutex spins/waits; note 1588876#'
val from dual ) union all ( select '#'
||'_MUTEX_WAIT_TIME#'
  ||'-man- set to 4 if Winbundle <=7; otherwise set to 10#'
  ||'PS[2], OSF[WINDOWS]#2p#controls mutex spins/waits; note 1588876#'
||'_NINTH_SPARE_PARAMETER#'
  ||'-man-set to 1 if SXD date between 201212 and 201301#'
  ||'PS[2], OSF[UNIX], MF[12-12], EXADATA[TRUE]#2p#'
  ||'consider blck chg track during inc. Backups#'
||'_NINTH_SPARE_PARAMETER#1#'
  ||'PS[2], OSF[UNIX], MF[13-13], EXADATA[TRUE]#2p#'
  ||'consider blck chg track during inc. Backups#'
||'_NINTH_SPARE_PARAMETER#'
  ||'-man-set to 1 if SXD date between 201212 and 201304#'
  ||'PS[3], OSF[UNIX], MF[7-9], EXADATA[TRUE]#2p#'
  ||'consider blck chg track during inc. Backups#'
||'_NINTH_SPARE_PARAMETER#-man-set to 1 if Winbundle>=23#'
  ||'PS[2], OSF[WINDOWS]#2p#'
  ||'consider blck chg track during inc. Backups#'
||'_OPTIM_PEEK_USER_BINDS#FALSE##1p#avoid bind value peeking#'
||'_OPTIMIZER_ADAPTIVE_CURSOR_SHARING#FALSE##2p##'
||'_OPTIMIZER_EXTENDED_CURSOR_SHARING_REL#NONE##2p##'
||'_OPTIMIZER_USE_CBQT_STAR_TRANSFORMATION#FALSE#PS[1]#1f##'
||'_OPTIMIZER_USE_CBQT_STAR_TRANSFORMATION#FALSE#'
  ||'PS[2], OSF[UNIX], MF[1-5]#1f##'
||'_OPTIMIZER_USE_CBQT_STAR_TRANSFORMATION#'
  ||'-man-set to FALSE if Winbundle<=12#PS[2], OSF[WINDOWS]#1f##'
||'_OPTIMIZER_USE_CBQT_STAR_TRANSFORMATION#'
  ||'-man-set to FALSE if no Winbundle is installed#'
  ||'PS[3], OSF[UNIX], MF[0-0]#1f##'
||'_OPTIMIZER_USE_CBQT_STAR_TRANSFORMATION#'
  ||'-man-set to FALSE if no Winbundle is installed#'
  ||'PS[3], OSF[WINDOWS]#1f##'
||'_OPTIMIZER_USE_FEEDBACK#FALSE##2p#'
  ||'avoid preference of index supporting inlist#'
||'_SECOND_SPARE_PARAMETER#-man-set to 1 if SBP date>=201011#'
  ||'PS[1], OSF[UNIX], MF[2-2]#2p#'
  ||'Avoid high CPU consumption for Mutex requests#'
||'_SECOND_SPARE_PARAMETER#1#PS[1], OSF[UNIX], MF[3-99]#2p#'
  ||'Avoid high CPU consumption for Mutex requests#'
val from dual ) union all ( select '#'
||'_SECUREFILES_CONCURRENCY_ESTIMATE#50#PS[34]#2p#'
  ||'Avoids buffer busy waits (free list) during LOB inserts#'
||'_SIMPLE_VIEW_MERGING#'
  ||'-man-set to FALSE if SXD date between 201205 and 201310 201310 and IOTs are used#'
  ||'PS[3], OSF[UNIX], MF[4-11], EXADATA[TRUE]#1f#'
  ||'risk of wrong values with IOTs; note 1915485#'
||'_SIMPLE_VIEW_MERGING#'
  ||'-man-set to FALSE if Winbundle between 6 and 26 and IOTs are used#'
  ||'PS[3], OSF[WINDOWS]#1f#'
  ||'risk of wrong values with IOTs; note 1915485#'
||'AUDIT_FILE_DEST#/oracle/[SID]/saptrace/audit#OSF[UNIX]###'
||'AUDIT_FILE_DEST#[DRIVE]:\oracle\[SID]\saptrace\audit#OSF[WINDOWS]##'
  ||'#'
||'BACKGROUND_DUMP_DEST#-del-####'
||'CLUSTER_DATABASE#TRUE#RAC[TRUE]###'
||'COMMIT_LOGGING#-del-##1f##'
||'COMMIT_WAIT#-del-##1f##'
||'COMMIT_WRITE#-del-##1f##'
||'COMPATIBLE#11.2.0#ASM[FALSE]#1f##'
||'COMPATIBLE#11.2.0.2.0#ASM[TRUE]#1f##'
||'CONTROL_FILE_RECORD_KEEP_TIME#>=30####'
||'CONTROL_FILES#-man-three copies on different disk areas####'
||'CORE_DUMP_DEST#-del-####'
||'DB_BLOCK_SIZE#8192####'
||'DB_CACHE_SIZE#-man-appropriately set####'
||'DB_CREATE_FILE_DEST#+DATA#ASM[TRUE]###'
||'DB_CREATE_ONLINE_LOG_DEST_1#+DATA#ASM[TRUE]###'
||'DB_CREATE_ONLINE_LOG_DEST_2#+RECO#ASM[TRUE]###'
||'DB_FILE_MULTIBLOCK_READ_COUNT#-del-##1p##'
||'DB_FILES#-man-set larger than short term expected datafiles####'
||'DB_NAME#[SID]####'
||'DB_RECOVERY_FILE_DEST#+RECO#ASM[TRUE]###'
||'DB_RECOVERY_FILE_DEST_SIZE#-man-appropriately set#ASM[TRUE]###'
||'DIAGNOSTIC_DEST#/oracle/[SID]/saptrace#OSF[UNIX]###'
||'DIAGNOSTIC_DEST#[DRIVE]:\oracle\[SID]\saptrace#OSF[WINDOWS]###'
||'DISK_ASYNCH_IO#'
  ||'-man-set to FALSE with standard filesystem (not on OnlineJFS; note 798194)#'
  ||'OS[HP-UX IA (64-bit),HP-UX (64-bit)], ASM[FALSE]###'
val from dual ) union all ( select '#'
||'EVENT,10027#10027##2f#avoid process state dump at deadlock#'
||'EVENT,10028#10028##2f#do not wait while writing deadlock trace#'
||'EVENT,10142#10142##2p#avoid btree bitmap conversion plans#'
||'EVENT,10183#10183##1p#avoid rounding during cost calculation#'
||'EVENT,10191#10191##2f#avoid high CBO memory consumption#'
||'EVENT,10198#-man-set if SBP>=201305 is installed#'
  ||'PS[3], OSF[UNIX], MF[9-9], EXADATA[FALSE]#1f#'
  ||'avoid ora-60 deadlocks (note 1847870)#'
||'EVENT,10198#10198#PS[3], OSF[UNIX], MF[10-99]#1f#'
  ||'avoid ora-60 deadlocks (note 1847870)#'
||'EVENT,10198#10198#PS[2], OSF[UNIX], MF[14-99], EXADATA[FALSE]#1f#'
  ||'avoid ora-60 deadlocks (note 1847870)#'
||'EVENT,10198#-man-set if SXD>=201306 is installed#'
  ||'PS[2], OSF[UNIX], MF[14-14], EXADATA[TRUE]#1f#'
  ||'avoid ora-60 deadlocks (note 1847870)#'
||'EVENT,10198#10198#PS[2], OSF[UNIX], MF[15-99], EXADATA[TRUE]#1f#'
  ||'avoid ora-60 deadlocks (note 1847870)#'
||'EVENT,10198#-man-set if Winbundle>=20#'
  ||'PS[3], OSF[WINDOWS], EXADATA[FALSE]#1f#'
  ||'avoid ora-60 deadlocks (note 1847870)#'
||'EVENT,10995#10995 level 2##2f#'
  ||'avoid flush shared pool during online reorg#'
||'EVENT,31991#31991#OSF[UNIX], PS[4]#2p#'
  ||'avoid too many recursive calls#'
||'EVENT,31991#31991#OSF[UNIX], PS[3], MF[5-99]#2p#'
  ||'avoid too many recursive calls#'
||'EVENT,31991#31991#OSF[UNIX], PS[2], MF[11-99]#2p#'
  ||'avoid too many recursive calls#'
||'EVENT,31991#-man-set if SBP>=201207 is installed#'
  ||'OSF[UNIX], PS[2], MF[10-10]#2p#avoid too many recursive calls#'
||'EVENT,31991#-man-set if Winbundle>=20#OSF[WINDOWS], PS[2]#2p#'
  ||'avoid too many recursive calls#'
||'EVENT,31991#-man-set if Winbundle>=8#OSF[WINDOWS], PS[3]#2p#'
  ||'avoid too many recursive calls#'
val from dual ) union all ( select '#'
||'EVENT,31991#-man-set if Winbundle>=2#OSF[WINDOWS], PS[4]#2p#'
  ||'avoid too many recursive calls#'
||'EVENT,38068#38068 level 100##2p#'
  ||'long raw statistic; implement note 948197#'
||'EVENT,38085#38085##2p#'
  ||'consider cost adjust for index fast full scan#'
||'EVENT,38087#38087##1f#avoid ora-600 at star transformation#'
||'EVENT,44951#44951 level 1024##2p#'
  ||'avoid HW enqueues during LOB inserts#'
||'FILESYSTEMIO_OPTIONS#SETALL##1p#note  793113#'
||'HPUX_SCHED_NOAGE#178#RAC[FALSE]#2p#performance#'
||'LOCAL_LISTENER#'
  ||'-man-set to (ADDRESS = (PROTOCOL=TCP) (HOST=[hostname]>) (PORT=[port]))#'
  ||'RAC[FALSE]###'
||'LOG_ARCHIVE_DEST_1#LOCATION=+[DGNAME]/[SID]/ORAARCH#'
  ||'ASM[TRUE], RAC [TRUE]###'
||'LOG_ARCHIVE_DEST_1#LOCATION=+ARCH#ASM[TRUE], RAC[FALSE]###'
||'LOG_ARCHIVE_DEST_1#LOCATION=/oracle/[SID]/oraarch/[SID]arch#'
  ||'OSF[UNIX], ASM[FALSE]##note 966073#'
||'LOG_ARCHIVE_DEST_1#'
  ||'LOCATION=[drive]:\oracle\[SID]\oraarch\[SID]arch#'
  ||'OSF[WINDOWS], ASM[FALSE]##note 966073#'
||'LOG_ARCHIVE_FORMAT#%t_%s_%r.dbf####'
||'LOG_BUFFER#-del-#ASM[TRUE], EXADATA[FALSE]###'
||'LOG_BUFFER#-man-depends on number of CPUs; details in note 1627481#'
  ||'ASM[FALSE], EXADATA[FALSE]##CPU_COUNT=[CPU_COUNT]#'
||'LOG_BUFFER#-man-set to at least 128MB; details in note 1627481#'
  ||'EXADATA[TRUE]##CPU_COUNT=[CPU_COUNT]#'
||'LOG_CHECKPOINTS_TO_ALERT#TRUE####'
||'MAX_DUMP_FILE_SIZE#20000####'
||'NLS_LENGTH_SEMANTICS#-del-##2f##'
||'OPEN_CURSORS#between 800 and 2000####'
||'OPTIMIZER_DYNAMIC_SAMPLING#-del-#BW[FALSE]#1p##'
||'OPTIMIZER_DYNAMIC_SAMPLING#6#BW[TRUE]#1p##'
||'OPTIMIZER_DYNAMIC_SAMPLING#-man-OLTP: do not set; OLAP: 6#'
  ||'BW[UNKNOWN]#1p##'
||'OPTIMIZER_FEATURES_ENABLE#-del-##1p##'
||'OPTIMIZER_INDEX_CACHING#-del-##2p#'
  ||'est. % of index cached (inlist, nested loop)#'
val from dual ) union all ( select '#'
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
  ||'-man-set to TRUE on systems with a Unix App. Server without SSFS (note 1622837)#'
  ||'ABAP[TRUE]###'
||'REMOTE_OS_AUTHENT#-del-#ABAP[FALSE]###'
||'REPLICATION_DEPENDENCY_TRACKING#-any-####'
||'SESSIONS#-man-2*PROCESSES###PROCESSES=[PROCESSES]#'
||'SHARED_POOL_SIZE#appropriately set; note 690241####'
||'STAR_TRANSFORMATION_ENABLED#TRUE#PS[2], OSF[UNIX], MF[6-99]#1p##'
||'STAR_TRANSFORMATION_ENABLED#-man-set to TRUE if Winbundle>=12#'
  ||'PS[2], OSF[WINDOWS]#1p##'
||'STAR_TRANSFORMATION_ENABLED#TRUE#PS[3], OSF[UNIX], MF[1-99]#1p##'
||'STAR_TRANSFORMATION_ENABLED#-man-set to TRUE if Winbundle>=1#'
  ||'PS[3], OSF[WINDOWS]#1p##'
||'STAR_TRANSFORMATION_ENABLED#TRUE#PS[4]#1p##'
||'UNDO_RETENTION#-man-appropriately set####'
||'UNDO_TABLESPACE#PSAPUNDO#RAC[FALSE]###'
||'UNDO_TABLESPACE#-man-appropriately set#RAC[TRUE]###'
||'USE_LARGE_PAGES#-man-can be set according to note 1672954#'
  ||'OS[Linux IA (64-bit),Linux x86 64-bit],PS[2345]###'
||'USER_DUMP_DEST#-del-####'
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
      ( select /*old libraries allow max. 8 of the below aggregate functions */
          a.inst_id,
          a.cpu_count,
          a.shared_pool_size_mb,
          a.sga_target,
          a.cluster_database,
          a.log_buffer,
          a.db_cache_size,
          a.calculated_shared_pool_size_mb,
          b.processes,
          b.para_max
        from
        (
          select
            inst_id,
            max(decode(name,'cpu_count',value,null)) cpu_count,
            max(decode(name,'shared_pool_size',value,null))/1024/1024 shared_pool_size_mb,
            max(decode(name,'sga_target',value,null)) sga_target,
            max(decode(name,'cluster_database',value,null)) cluster_database,
            max(decode(name,'log_buffer',value,null)) log_buffer,
            max(decode(name,'db_cache_size',value,null)) db_cache_size,
            ( max(decode(name,'cpu_count',value,null))/4*500+
              max(decode(name,'sga_max_size',value,null))/1024/1024/1024*5+300)*
              decode(max(decode(name,'cluster_database',value,null)), 'TRUE', 1.2, 1) calculated_shared_pool_size_mb
          from
            gv$parameter2
          where
            name in
            (
              'cpu_count',
              'shared_pool_size',
              'sga_target',
              'cluster_database',
              'log_buffer',
              'db_cache_size',
              'sga_max_size'
            )
          group by
            inst_id
        ) a,
        (
          select
            inst_id,
            max(decode(name,'processes',value,null)) processes,
            max(decode(name,'parallel_max_servers',value,null)) para_max
          from
            gv$parameter2
          where
            name in
            (
            'processes',
            'parallel_max_servers'
            )
          group by
            inst_id
        ) b
        where 
          a.inst_id=b.inst_id )
x_parameter,
      ( select inst_id, max(UNXPBLKRELCNT+UNXPBLKREUCNT) max_stolen from gv$undostat group by inst_id)
x_undostat,
      (
        select
          to_number(substr(max(bf.nr_bg),1,2)) mergefix_at_least,
          decode(substr(max(dt.mf_date),substr(max(bf.nr_bg),1,2)*7+1,1),
          '=','20',
          '<','before 20')||
          substr(max(dt.mf_date),substr(max(bf.nr_bg),1,2)*7+2,2)||'-'||
          substr(max(dt.mf_date),substr(max(bf.nr_bg),1,2)*7+4,2)||'-'||
          substr(max(dt.mf_date),substr(max(bf.nr_bg),1,2)*7+6,2) mergefix_released,
          substr(max(bf.nr_bg),3) bugno
        from
        (
          select
            decode(substr(val,instr(val,'#',1,r-2)+1,
              instr(val,'#',1,r-1)-instr(val,'#',1,r-2)-1),
              'A','11.2.0.1',
              'B','11.2.0.2',
              'C','11.2.0.3',
              'D','11.2.0.4',
              '?') patchset,
            lpad(to_number(substr(val,instr(val,'#',1,r-0)+1,
              instr(val,'#',1,r+1)-instr(val,'#',1,r-0)-1)),2)||
            to_number(substr(val,instr(val,'#',1,r-1)+1,
              instr(val,'#',1,r-0)-instr(val,'#',1,r-1)-1)) nr_bg
          from
          ( select '#'||
'A#12591120#4#A#6055658#3#A#8937971#2#A#9495669#1#A#-1#0#'||
'B#14712222#15#B#14723910#14#B#13891981#13#B#14255600#12#B#13627489#11#'||
'B#13777823#10#B#13594712#9#B#13524237#8#B#13077335#7#B#12827166#6#'||
'B#12591120#5#B#11892888#4#B#6055658#3#B#11699884#2#B#10134677#1#B#-1#0#'||
'C#18405517#15#C#18035463#14#C#16470836#13#C#16976121#12#C#16092378#11#'||
'C#14712222#10#C#14723910#9#C#13891981#8#C#14467202#7#C#14255600#6#'||
'C#13627489#5#C#13777823#4#C#13594712#3#C#13524237#2#C#12622441#1#C#-1#0#'||
'D#18405517#3#D#18035463#2#D#16470836#1#D#-1#0#'  
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
'11.2.0.1' version,
'=100330=100610=100910=110510=110810' mf_date
          from dual union ( select
'11.2.0.2' version,
'=101110=101110=110310=110510=110610=110810=111010=120110'||
'=120210=120310=120510=120810=120910=130210=130510=130810' mf_date
          from dual ) union ( select
'11.2.0.3' version,
'=111210=111210=120210=120310=120510=120710=121010'||
'=121110=130210=130310=130610=130810=131110=131210=140610=140810' mf_date
          from dual ) union ( select
'11.2.0.4' version,
'=140210=140210=140610=140810' mf_date
          from dual )
        ) dt
        where
          to_number(substr(bf.nr_bg,3))=fc.bugno and
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
      ( select 
          decode(nvl(sum(decode(event,'cell single block physical read',1,0)),0),
            0,'FALSE','TRUE') exadata_used,
          decode(nvl(sum(decode(event,'ASM background timer',1,0)),0),0,'FALSE','TRUE') asm_used
        from v$system_event 
        where event in ('cell single block physical read','ASM background timer'))
x_feature_used,
      ( select decode(count(*),0,'FALSE','TRUE') abap_stack from
          dba_tables where table_name = 'T000' and owner like 'SAP%')
x_abap_stack,
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
        (o.r_asm is null or o.r_asm = x_feature_used.asm_used) and
        (o.r_exadata is null or o.r_exadata = x_feature_used.exadata_used) and
        (o.r_abap is null or o.r_abap = x_abap_stack.abap_stack) and
        (o.r_bw is null or o.r_bw = x_olap.olap ) and
        (o.r_ps is null or instr(o.r_ps,decode(substr(o.version,1,7),
          '11.2.0.',substr(o.version,8,1),'?'))>0)
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
'_AWR_MMON_DEEP_PURGE_ALL_EXPIRED#_B_TREE_BITMAP_PLANS#'||
'_BUG16850197_ENABLE_FIX_FOR_13602883#_DISABLE_CELL_OPTIMIZED_BACKUPS#'||
'_ENABLE_NUMA_SUPPORT#'||	
'_FIFTH_SPARE_PARAMETER#_FILE_SIZE_INCREASE_INCREMENT#_FIRST_SPARE_PARAMETER#'||
'_FIX_CONTROL 4728348#_FIX_CONTROL 5099019#'||
  '_FIX_CONTROL 5705630#_FIX_CONTROL 6055658#'||
  '_FIX_CONTROL 6120483#_FIX_CONTROL 6399597#'||
  '_FIX_CONTROL 6430500#_FIX_CONTROL 6440977#_FIX_CONTROL 6626018#'||
  '_FIX_CONTROL 6972291#_FIX_CONTROL 7168184#'||   
  '_FIX_CONTROL 8937971#_FIX_CONTROL 9196440#'||
  '_FIX_CONTROL 9495669#_FIX_CONTROL 12693573#_FIX_CONTROL 13077335#'||
  '_FIX_CONTROL 13627489#_FIX_CONTROL 14255600#_FIX_CONTROL 14595273#'||  
  '_FIX_CONTROL 18405517#'||
'_GC_OVERRIDE_FORCE_CR#'||
'_IN_MEMORY_UNDO#_KTB_DEBUG_FLAGS#_MUTEX_WAIT_SCHEME#_MUTEX_WAIT_TIME#'||
'_NINTH_SPARE_PARAMETER#_OPTIM_PEEK_USER_BINDS#'||
  '_OPTIMIZER_ADAPTIVE_CURSOR_SHARING#_OPTIMIZER_EXTENDED_CURSOR_SHARING_REL#'||
  '_OPTIMIZER_USE_CBQT_STAR_TRANSFORMATION#_OPTIMIZER_USE_FEEDBACK#'||  
'_SECOND_SPARE_PARAMETER#_SECUREFILES_CONCURRENCY_ESTIMATE#_SIMPLE_VIEW_MERGING#'||  
'EVENT 10027#EVENT 10028#EVENT 10142#EVENT 10183#EVENT 10191#EVENT 10198#'||
  'EVENT 10995#EVENT 31991#EVENT 38068#EVENT 38085#EVENT 38087#EVENT 44951#'
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
) union all
( select /* This dummy select is needed due to an SQL Editor Bug */ 
  null,null,null,null,null,null,null,null,null,null from dual where 1=0 )
order by
  id,
  i,
  u,
  name,
  inst_id;



