select null name, null recommendation, null "I", null "U", null remark, null is_set,
  null is_value, null should_be_value, null "ID", null inst_id from dual where 1 = 0
union all (
select null name, null recommendation, null "I", null "U", null remark, null is_set,
  null is_value, null should_be_value, null "ID", null inst_id from dual where 1 = 0
) union all ( select * from (
with BASIS_INFO as
( select /*+MATERIALIZE*/
    decode(substr(upper(is_olap),1,1),
      'Y','Y','?','?','N') is_olap,
    decode(substr(sim_patch,9,1),
      '/',substr(sim_patch,1,8),null) sim_patch_set,
    decode(substr(sim_patch,9,1),
      '/',substr(sim_patch,10),null) sim_bundle,
    platform_name sim_os,
    decode(instr('YN',upper(substr(sim_abap,1,1))),0,'',
      upper(substr(sim_abap,1,1))) sim_abap,
    decode(instr('YN',upper(substr(sim_rac,1,1))),0,'',
      upper(substr(sim_rac,1,1))) sim_rac,
    decode(instr('YN',upper(substr(sim_oes,1,1))),0,'',
      upper(substr(sim_oes,1,1))) sim_oes,
    decode(instr('YN',upper(substr(sim_asm,1,1))),0,'',
      upper(substr(sim_asm,1,1))) sim_asm,
    decode(instr('YN',upper(substr(sim_ldt,1,1))),0,'',
      upper(substr(sim_ldt,1,1))) sim_ldt,
    decode(substr(upper(is_lac),1,1),
      'N','N','?','?','Y') is_lac       
  from
  ( select
      '<OLAP System? [n]>' is_olap,
      '<Licenced Advanced Compression? [y]>' is_lac,
      '<Simulate licenced Diag./Tuning Pack []>' sim_ldt,
      '<Simulate Patch []>' sim_patch,
      '<Simulate OS []>' sim_os,
      '<Simulate ABAP []>' sim_abap,
      '<Simulate RAC []>' sim_rac,
      '<Simulate ASM []>' sim_asm,
      '<Simulate OES []>' sim_oes
    from
      dual
  ),
    v$transportable_platform
  where
    sim_os=platform_name(+)
),
MaintInfo as
( select
     '36' NoteVersion,
     '2016-06-14' LastChanged
   from
     dual
),
MaintShouldRaw as
( select /*+MATERIALIZE*/ val from
  ( select '###PS[0]###' val from dual union all ( select '#'
||'*** 1#####'
||'*** 2#####'
||'*** 3#####'
||'*** 4#####'
||'*** 5#####'
||'*** 6#####'
||'*** 7#####'
||'*** 8#####'
||'*** 9#####'
||'*** 10#####'
||'*** 11#####'
||'_ADVANCED_INDEX_COMPRESSION_OPTIONS#16#LAC[T]#2f#'
  ||'ATTENTION: Don´t set without Advanced Compression License#'
||'_ADVANCED_INDEX_COMPRESSION_OPTIONS#'
  ||'-man-set to 16 if advanced compression is licensed#LAC[?]#2f#'
  ||'use low advanced index compress for rebuild/create; note 2138262#'
||'_AWR_MMON_DEEP_PURGE_ALL_EXPIRED#TRUE####'
||'_ENABLE_NUMA_SUPPORT#'
  ||'-man-set optionally to TRUE after successful test##2p##'
||'_FILE_SIZE_INCREASE_INCREMENT#2143289344#OES[T]###'
||'_FIX_CONTROL,5099019#5099019:ON##2p#'
  ||'dbms_stats counts leaf blocks correctly#'
||'_FIX_CONTROL,5705630#5705630:ON##2p#'
  ||'use optimal OR concatenation; note 176754#'
||'_FIX_CONTROL,6055658#6055658:OFF##2p#'
  ||'calculate correct join card. with histograms#'
||'_FIX_CONTROL,6120483#6120483:OFF##2p##'
||'_FIX_CONTROL,6399597#6399597:ON##2p#'
  ||'sort group by instead of hash group by; note 176754#'
||'_FIX_CONTROL,6430500#6430500:ON##2p#avoid not using unique index#'
||'_FIX_CONTROL,6440977#6440977:ON##2p#'
  ||'consider redundant predicates in join; note 981875#'
||'_FIX_CONTROL,6626018#6626018:ON##2p#'
  ||'avoid to low filter costs; note 981875#'
||'_FIX_CONTROL,6972291#6972291:ON##2p#'
  ||'use column group selectivity with hgrm;note 1165319#'
||'_FIX_CONTROL,7168184#7168184:OFF##2f#'
  ||'avoid multi-column/bloom filter problems on comp. tab.#'
||'_FIX_CONTROL,7658097#7658097:ON##2p#'
  ||'temp. workaround for Oracle Bug 19875411#'
||'_FIX_CONTROL,8937971#8937971:ON##2f#'
  ||'correct clause definition dbms_metadata.get_ddl#'
val from dual ) union all ( select '#'
||'_FIX_CONTROL,9196440#9196440:ON##2p#'
  ||'fixes low distinct keys in index stats#'
||'_FIX_CONTROL,9495669#9495669:ON##2p#'
  ||'disable histogram use for join cardinality#'
||'_FIX_CONTROL,13077335#13077335:ON##2p#'
  ||'correct long varchar cardinality calculation with histgr#'
||'_FIX_CONTROL,13627489#13627489:ON##2p#'
  ||'use good access for merge in dbms_redefinition#'
||'_FIX_CONTROL,14255600#14255600:ON##2p#'
  ||'statistic collection during index creation#'
||'_FIX_CONTROL,14595273#14595273:ON##2p##'
||'_FIX_CONTROL,14846352#14846352:OFF##2p#'
  ||'avoid wrong cardinality estimations; note 2254070#'
||'_FIX_CONTROL,18405517#18405517:2##2p##'
||'_FIX_CONTROL,20355502#20355502:8#OSF[U]REL[1]PS[2]FIX[201508-]:'
  ||'OSF[W]REL[1]PS[2]FIX[5-]#2p#reduces parse time with OR-expansion#'
||'_FIX_CONTROL,22540411#22540411:ON##2p#'
  ||'use hash group by with sort for aggregation#'
||'_KTB_DEBUG_FLAGS#8##1f#'
  ||'avoid invalid index block SCNs on STDBY; note 2005311#'
||'_MUTEX_WAIT_SCHEME#1##2p#controls mutex spins/waits; note 1588876#'
||'_MUTEX_WAIT_TIME#10##2p#controls mutex spins/waits; note 1588876#'
||'_OPTIM_PEEK_USER_BINDS#FALSE##1p#avoid bind value peeking#'
||'_OPTIMIZER_ADAPTIVE_CURSOR_SHARING#FALSE##2p##'
||'_OPTIMIZER_AGGR_GROUPBY_ELIM#FALSE##1f#'
  ||'avoid wrong values with groub by; note 2159551#'
||'_OPTIMIZER_BATCH_TABLE_ACCESS_BY_ROWID#FALSE##1f#'
  ||'avoid wrong values after unclustering; note 2240098#'
||'_OPTIMIZER_EXTENDED_CURSOR_SHARING_REL#NONE##2p##'
||'_OPTIMIZER_REDUCE_GROUPBY_KEY#FALSE##1f#'
  ||'avoid wrong values with group by; note 2258559#'
||'_OPTIMIZER_USE_FEEDBACK#FALSE##2p##'
||'_SECUREFILES_CONCURRENCY_ESTIMATE#50##2p#'
  ||'Avoids bbw (free list) and enq waits during LOB inserts; note 1887235#'
val from dual ) union all ( select '#'
||'_SUPPRESS_IDENTIFIERS_ON_DUPKEY#TRUE####'
||'_USE_SINGLE_LOG_WRITER#TRUE####'
||'AUDIT_FILE_DEST#/oracle/[SID]/saptrace/audit#OSF[U]###'
||'AUDIT_FILE_DEST#[DRIVE]:\oracle\[SID]\saptrace\audit#OSF[W]###'
||'BACKGROUND_DUMP_DEST#-del-####'
||'CLUSTER_DATABASE#TRUE#RAC[T]###'
||'CLUSTER_DATABASE_INSTANCES#-man-set to number of RAC instances#'
  ||'RAC[T]###'
||'COMMIT_LOGGING#-del-##1f##'
||'COMMIT_WAIT#-del-##1f##'
||'COMMIT_WRITE#-del-##1f##'
||'COMPATIBLE#12.1.0.2.0##1f#note 1739274#'
||'CONTROL_FILE_RECORD_KEEP_TIME#>=30####'
||'CONTROL_FILES#-man-three copies on different disk areas#OES[F]###'
||'CONTROL_FILES#-man-two copies on different disk areas#OES[T]###'
||'CONTROL_MANAGEMENT_PACK_ACCESS#DIAGNOSTIC+TUNING#LDT[T]###'
||'CONTROL_MANAGEMENT_PACK_ACCESS#'
  ||'-man-set to DIAGNOSTIC+TUNING if both packs are licensed (strongly recom.)#'
  ||'LDT[F]###'
||'CORE_DUMP_DEST#-del-####'
||'DB_BLOCK_SIZE#8192####'
||'DB_CACHE_SIZE#-man-appropriately set###note 789011, 617416#'
||'DB_CREATE_FILE_DEST#+DATA#ASM[T]###'
||'DB_CREATE_ONLINE_LOG_DEST_1#+DATA#ASM[T]###'
||'DB_CREATE_ONLINE_LOG_DEST_2#+RECO#ASM[T]###'
||'DB_FILE_MULTIBLOCK_READ_COUNT#-del-##1p##'
||'DB_FILES#'
  ||'-man-set larger than number of short term expected datafiles####'
||'DB_NAME#[SID]####'
||'DB_RECOVERY_FILE_DEST#+RECO#ASM[T]###'
||'DIAGNOSTIC_DEST#/oracle/[SID]/saptrace#OSF[U]###'
||'DIAGNOSTIC_DEST#[DRIVE]:\oracle\[SID]\saptrace#OSF[W]###'
||'DISK_ASYNCH_IO#'
  ||'-man-set to FALSE with standard filesystem (not on OnlineJFS; note 798194)#'
  ||'OS[HP-UX IA (64-bit),HP-UX (64-bit)], ASM[F]##note 798194#'
||'EVENT,10027#10027##2f#'
  ||'avoid process state dump at deadlock; note 596420#'
val from dual ) union all ( select '#'
||'EVENT,10028#10028##2f#'
  ||'do not wait for writing deadlock trace; note 596420#'
||'EVENT,10142#10142##2p#'
  ||'avoid btree bitmap conversion plans; note 1284478#'
||'EVENT,10183#10183##1p#'
  ||'avoid rounding during cost calculation; note 128648#'
||'EVENT,10191#10191##2f#'
  ||'avoid high CBO memory consumption; note 128221#'
||'EVENT,10995#10995 level 2##2f#'
  ||'avoid flush shared pool at online reorg (note 1565421)#'
||'EVENT,38068#38068 level 100##2p#'
  ||'no rule based access if first ind col with range; note 176754#'
||'EVENT,38085#38085##2p#'
  ||'consider cost adjust for index fast full scan; note 176754#'
||'EVENT,38087#38087##2p#'
  ||'calc long raw statistic correctly; note 948197#'
||'EVENT,44951#44951 level 1024##2p#'
  ||'avoid HW enqueues during LOB inserts; note 1166242#'
||'FILESYSTEMIO_OPTIONS#SETALL##1p#note  793113#'
||'HEAT_MAP#on#LAC[T]#2f#note 2254866#'
||'HEAT_MAP#-man-set to "on" if advanced compression is licensed#'
  ||'LAC[?]#2f#note 2254866#'
||'HPUX_SCHED_NOAGE#178#RAC[F]#2p#performance#'
||'INMEMORY_CLAUSE_DEFAULT#PRIORITY HIGH#INM[T]##note 2178980#'
||'INMEMORY_MAX_POPULATE_SERVERS#4#INM[T]##note 2178980#'
||'INMEMORY_SIZE#-man-appropriately set; details in note 2178980#'
  ||'INM[T]##note 2178980#'
||'INSTANCE_NAME#-man-set to [SID][Instance Number]#RAC[T]###'
||'INSTANCE_NUMBER#-man-set to 3 digit numeric value#RAC[T]###'
||'LOCAL_LISTENER#'
  ||'-man-set to (ADDRESS = (PROTOCOL=TCP) (HOST=[hostname]>) (PORT=[port]))#'
  ||'RAC[F]###'
||'LOCAL_LISTENER#'
  ||'-man-set to (ADDRESS = (PROTOCOL=TCP) (HOST=[hostname_vip]>) (PORT=1521))#'
  ||'RAC[T]###'
||'LOG_ARCHIVE_DEST_1#LOCATION=+[DGNAME]/[SID]/ORAARCH#ASM[T]RAC[T]###'
val from dual ) union all ( select '#'
||'LOG_ARCHIVE_DEST_1#LOCATION=+ARCH#ASM[T]RAC[F]###'
||'LOG_ARCHIVE_DEST_1#LOCATION=/oracle/[SID]/oraarch/[SID]arch#'
  ||'OSF[U]ASM[F]##note 966073#'
||'LOG_ARCHIVE_DEST_1#'
  ||'LOCATION=[drive]:\oracle\[SID]\oraarch\[SID]arch#OSF[W]ASM[F]##'
  ||'note 966073#'
||'LOG_ARCHIVE_FORMAT#%t_%s_%r.dbf####'
||'LOG_BUFFER#-del-#ASM[T]OES[F]###'
||'LOG_BUFFER#-man-depends on number of CPUs; details in note 1627481#'
  ||'ASM[F]OES[F]##CPU_COUNT=[CPU_COUNT]#'
||'LOG_BUFFER#-man-set to at least 128MB; details in note 1627481#'
  ||'OES[T]##CPU_COUNT=[CPU_COUNT]#'
||'LOG_CHECKPOINTS_TO_ALERT#TRUE####'
||'MAX_DUMP_FILE_SIZE#20000####'
||'NLS_LENGTH_SEMANTICS#-del-##2f##'
||'OPEN_CURSORS#between 800 and 2000####'
||'OPTIMIZER_ADAPTIVE_FEATURES#FALSE#REL[1]#2p#'
  ||'disable e.g. adaptive plans#'
||'OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES#FALSE##2p#'
  ||'no automatiq SQL plan baseline collection#'
||'OPTIMIZER_DYNAMIC_SAMPLING#-del-#BW[F]#1p##'
||'OPTIMIZER_DYNAMIC_SAMPLING#6#BW[T]#1p##'
||'OPTIMIZER_DYNAMIC_SAMPLING#-man-OLTP: do not set; OLAP: 6#BW[?]#1p#'
  ||'#'
||'OPTIMIZER_FEATURES_ENABLE#-del-##1p##'
||'OPTIMIZER_INDEX_CACHING#-del-##2p#'
  ||'est. % of index cached (inlist, nested loop)#'
||'OPTIMIZER_INDEX_COST_ADJ#20#BW[F]#1p##'
||'OPTIMIZER_INDEX_COST_ADJ#-del-#BW[T]#1p##'
||'OPTIMIZER_INDEX_COST_ADJ#-man-OLTP: 20; OLAP: do not set#BW[?]###'
||'OPTIMIZER_MODE#-del-##1p##'
||'PARALLEL_EXECUTION_MESSAGE_SIZE#16384##2p##'
||'PARALLEL_MAX_SERVERS#-man-Number of DB machine CPU_COUNT*10###'
  ||'CPU_COUNT=[CPU_COUNT]#'
||'PARALLEL_THREADS_PER_CPU#1##2p##'
||'PGA_AGGREGATE_TARGET#-man-appropriately set####'
||'PROCESSES#-man-formula how to set in parameter note###'
  ||'dependent: SESSIONS#'
val from dual ) union all ( select '#'
||'QUERY_REWRITE_ENABLED#FALSE##2p##'
||'RECYCLEBIN#OFF##1f##'
||'REMOTE_LISTENER#'
  ||'-man-set to //[scan_name]:1521//[scan_listener_DNS_name]:1521#'
  ||'RAC[T]###'
||'REMOTE_OS_AUTHENT#-del-####'
||'REPLICATION_DEPENDENCY_TRACKING#-any-####'
||'SESSIONS#-man-2*PROCESSES###PROCESSES=[PROCESSES]#'
||'SERVICE_NAMES#-man-set to ([SID], [Instance Name])#RAC[T]###'
||'SHARED_POOL_SIZE#appropriately set; note 690241####'
||'SPFILE#-any-####'
||'STAR_TRANSFORMATION_ENABLED#TRUE##1p##'
||'THREAD#-man-set to instance_number value without leading zeros#'
  ||'RAC[T]###'
||'UNDO_RETENTION#-man-appropriately set####'
||'UNDO_TABLESPACE#PSAPUNDO#RAC[F]###'
||'UNDO_TABLESPACE#-man-set to PSAPUNDO[Instance Number]#RAC[T]###'
||'USE_LARGE_PAGES#-man-can be set according to note 1672954#'
  ||'OS[Linux IA (64-bit),Linux x86 64-bit]###'
||'USER_DUMP_DEST#-del-####'
  val from dual ))
),
NumGen as
( select /*+MATERIALIZE*/
    rownum nr
  from
    v$parameter2
  where
    rownum <= 100
),
ShouldByLine as
( select /*+MATERIALIZE*/
    substr(val,instr(val,'#',1,r-4)+1,instr(val,'#',1,r-3)-instr(val,'#',1,r-4)-1) n,
    substr(val,instr(val,'#',1,r-3)+1,instr(val,'#',1,r-2)-instr(val,'#',1,r-3)-1) w,
    ':'||substr(val,instr(val,'#',1,r-2)+1,instr(val,'#',1,r-1)-instr(val,'#',1,r-2)-1)||':' r,
    substr(val,instr(val,'#',1,r-1)+1,instr(val,'#',1,r-0)-instr(val,'#',1,r-1)-1) p,
    substr(val,instr(val,'#',1,r-0)+1,instr(val,'#',1,r+1)-instr(val,'#',1,r-0)-1) c
  from
    MaintShouldRaw,
    ( select nr*5 r from NumGen )
  where
    val != '#' and
    substr(val,instr(val,'#',1,r-4)+1,
    instr(val,'#',1,r-3)-instr(val,'#',1,r-4)-1) is not null
),
ShouldOrByLine as
( select /*+MATERIALIZE*/
    decode(substr(n,1,4),'*** ','*** INFORMATION '||lpad(substr(n,5),2)||' ***',n) n,
    w,
    substr(r,instr(r,':',1,nr)+1,instr(r,':',1,nr+1)-instr(r,':',1,nr)-1) r,
    p,c
  from
    ShouldByLine,
    NumGen
  where
    substr(r,instr(r,':',1,nr)+1,instr(r,':',1,nr+1)-instr(r,':',1,nr)-1) is not null or
    nr=1
),
ShouldPerInstCondColsOrByLine as
( select
    inst_id,
    n,w,c,p,
    decode(instr(' '||r,'INM[T]'),
      0,decode(instr(' '||r,'INM[F]'),
        0,'','N'),'Y') r_inm,   
    decode(instr(' '||r,'LDT[T]'),
      0,decode(instr(' '||r,'LDT[F]'),
        0,'','N'),'Y') r_ldt,   
    decode(instr(' '||r,'LAC[T]'),
      0,decode(instr(' '||r,'LAC[?]'),
        0,'','?'),'Y') r_lac,        
    decode(instr(' '||r,'REL['),0,'',
      substr(r,instr(r,'REL[')+4,instr(r,']',
      instr(r,'REL['))-instr(r,'REL[')-4)) r_rel,
    decode(instr(' '||r,'PS['),0,'',
      substr(r,instr(r,'PS[')+3,instr(r,']',
      instr(r,'PS['))-instr(r,'PS[')-3)) r_ps,
    decode(instr(' '||r,'FIX['),0,'',
      substr(r,instr(r,'FIX[')+4,instr(r,']',
      instr(r,'FIX['))-instr(r,'FIX[')-4)) r_fix,
    decode(instr(' '||r,'BW[T]'),
      0,decode(instr(' '||r,'BW[F]'),
        0,decode(instr(' '||r,'BW[?]'),
          0,'','?'),'N'),'Y') r_bw,
    decode(instr(' '||r,'RAC[T]'),
      0,decode(instr(' '||r,'RAC[F]'),
        0,'','N'),'Y') r_rac,
    decode(instr(' '||r,'ABAP[T]'),
      0,decode(instr(' '||r,'ABAP[F]'),
        0,'','N'),'Y') r_abap,
    decode(instr(' '||r,'OS['),0,'',
      substr(r,instr(r,'OS[')+3,instr(r,']',
      instr(r,'OS['))-instr(r,'OS[')-3)) r_os,
    decode(instr(' '||r,'OSF[U]'),
      0,decode(instr(' '||r,'OSF[W]'),
        0,'','WINDOWS'),'UNIX') r_osf,
    decode(instr(' '||r,'ASM[T]'),
      0,decode(instr(' '||r,'ASM[F]'),
        0,'','N'),'Y') r_asm,
    decode(instr(' '||r,'OES[T]'),
      0,decode(instr(' '||r,'OES[F]'),
        0,'','N'),'Y') r_oes,
    sim_bundle oj_helper_sim_bundle
  from
    ShouldOrByLine,
    gv$instance,
    BASIS_INFO
),
IsResLim as
( select
    inst_id,
    upper(resource_name) resource_name,
    limit_value res_limit_value,
    max_utilization
  from
    gv$resource_limit
  where
    resource_name in ('processes',
      'sessions','parallel_max_servers')
),
IsPgaStat as
( select
    pga.inst_id,
    pga.value max_since_start,
    param.value pga_limit_value
  from
    gv$pgastat pga,
    gv$parameter2 param
  where
    pga.inst_id=param.inst_id and
    pga.name='maximum PGA allocated' and
    param.name='pga_aggregate_target'
),
IsSomeParVals as
( select /*old libraries allow max. 8 of the below aggregate functions */
    a.inst_id,
    cpu_count,
    shared_pool_size_mb,
    sga_target,
    cluster_database is_rac,
    log_buffer,
    db_cache_size,
    calculated_shared_pool_size_mb,
    processes,
    para_max,
    control_management_pack_access is_ldt,
    is_inm
  from
  ( select
      inst_id,
      max(decode(name,'shared_pool_size',value,null))/1024/1024 shared_pool_size_mb,
      max(decode(name,'sga_target',value,null)) sga_target,
      max(decode(name,'cluster_database',nvl(sim_rac,
        decode(value,'TRUE','Y','N')),null)) cluster_database,  
      max(decode(name,'log_buffer',value,null)) log_buffer,
      max(decode(name,'cpu_count',value,null)) cpu_count, 
      ( max(decode(name,'cpu_count',value,null))/4*500+
        max(decode(name,'sga_max_size',value,null))/1024/1024/1024*5+300)*
        decode(max(decode(name,'cluster_database',nvl(sim_rac,
        decode(value,'TRUE','Y','N')),null)), 'Y', 1.2, 1) calculated_shared_pool_size_mb,
      max(decode(name,'control_management_pack_access',nvl(sim_ldt,
        decode(value,'DIAGNOSTIC+TUNING','Y','N')),null)) control_management_pack_access  
    from
      gv$parameter2,
      BASIS_INFO
    where
      name in ('cluster_database','control_management_pack_access',
        'cpu_count','log_buffer','sga_max_size',
        'sga_target','shared_pool_size')
    group by
      inst_id
  ) a,
  ( select
      inst_id,
      max(decode(name,'db_cache_size',value,null)) db_cache_size,      
      max(decode(name,'inmemory_size',decode(value,0,'N','Y'),null)) is_inm, 
      max(decode(name,'processes',value,null)) processes,
      max(decode(name,'parallel_max_servers',value,null)) para_max                                             
    from
      gv$parameter2
    where
      name in ('db_cache_size','inmemory_size','processes','parallel_max_servers')
    group by
      inst_id
  ) b
  where
    a.inst_id=b.inst_id
),
IsUndoStat as
( select
    inst_id,
    max(UNXPBLKRELCNT+UNXPBLKREUCNT) max_stolen
  from
    gv$undostat
  group by
    inst_id
),
MaintIsPSAndMFvDollar as
( select
    1 OuterJoinDummy,
    vdo_startup_time,
    vdo_patch_set,
    vdo_bundle_date_min,
    vdo_bundle_date_max,
    vdo_bundle_win_min,
    vdo_bundle_win_max,
    vdo_bug_no
  from
  ( select
      i.startup_time vdo_startup_time,
      substr(i.version,1,8) vdo_patch_set,
      to_number(substr(val,5,6)) vdo_bundle_date_min,
      to_number(substr(val,12,6)) vdo_bundle_date_max,
      to_number(substr(val,19,6)) vdo_bundle_win_min,
      to_number(substr(val,26,6)) vdo_bundle_win_max,
      to_number(substr(val,33)) vdo_bug_no
    from
    ( select
        '1,2,000000,201503,000000,000002,-1'       v1,
        '1,2,201504,201504,000003,000003,19563657' v2,
        '1,2,201505,201506,000004,000006,20046257' v3,  
        '1,2,201508,201508,000009,000009,20914534' v4, 
        '1,2,201509,201509,000009,000009,20118383' v5, 
        '1,2,201511,201511,000010,000010,20808265' v6,
        '1,2,201602,201602,160119,160119,20732410' v7,
        '1,2,201605,201605,160531,160531,22540411' v8,
        null  v9, null v10,
        null v11, null v12, null v13, null v14,
        null v15, null v16, null v17, null v18,
        null v19, null v20, null v21, null v22,
        null v23, null v24, null v25, null v26,
        null v27, null v28, null v29, null v30,
        null v31, null v32, null v33, null v34,
        null v35, null v36, null v37, null v38,
        null v39, null v40, null v41, null v42,
        null v43, null v44, null v45, null v46,
        null v47, null v48, null v49, null v50
      from dual)
        unpivot (val for nr in (v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,
        v16,v17,v18,v19,v20,v21,v22,v23,v24,v25,v26,v27,v28,v29,v30,v31,v32,v33,v34,v35,v36,
        v37,v38,v39,v40,v41,v42,v43,v44,v45,v46,v47,v48,v49,v50)) bf,
      ( select bugno from v$system_fix_control union ( select -1 bugno from dual)) fc,
      v$instance i
    where
      to_number(substr(val,33))=fc.bugno and
      substr(i.version,1,8)='12.'||substr(val,1,1)||'.0.'||substr(val,3,1)
    order by
      substr(val,5,13) desc
  )
  where
    rownum=1
),
IsPSAndMFdba_hist as
( select
    1 OuterJoinDummy,
    dba_bundle
  from
  ( select
      dba_bundle
    from
    ( select
        h.id dba_bundle
      from
        dba_registry_history h,
        v$instance i
      where
        ( substr(h.comments,1,13)='WinBundle 12.' or
          substr(h.comments,1,7)='SBP 12.') and
        substr(i.version,1,8) = substr(h.version, 1, 8) and
        h.action='APPLY'
      union
      ( select 
          h.bundle_id dba_bundle
        from
          dba_registry_sqlpatch h,
          v$instance i
        where
          substr(h.description,1,30)='WINDOWS DB BUNDLE PATCH 12.1.0' and
          substr(i.version,1,8) = substr(h.version, 1, 8) and
          h.action='APPLY' and h.status='SUCCESS'
      )      
      union (select 0 dba_bundle from dual)
    )
    order by
      dba_bundle desc
  )
  where
    rownum = 1
),
IsPSAndMF as
( select 
    to_char(vdo_bundle_date_min) vdo_bundle_date_min,
    to_char(vdo_bundle_date_max) vdo_bundle_date_max,
    to_char(vdo_bundle_win_min) vdo_bundle_win_min,
    to_char(vdo_bundle_win_max) vdo_bundle_win_max,
    to_char(dba_bundle) dba_bundle,
    vdo_startup_time startup_time,
    nvl(sim_patch_set, vdo_patch_set) version,
    nvl(sim_bundle, decode(sign(vdo_bundle_date_min-dba_bundle),
      1, vdo_bundle_date_min,
      dba_bundle)) bundle_date_min,
    nvl(sim_bundle, decode(sign(vdo_bundle_date_min-dba_bundle),
      1, vdo_bundle_date_max,
      dba_bundle)) bundle_date_max,
    nvl(sim_bundle, decode(sign(vdo_bundle_win_min-dba_bundle),
      1, vdo_bundle_win_min,
      dba_bundle)) bundle_win_min,
    nvl(sim_bundle, decode(sign(vdo_bundle_win_min-dba_bundle),
      1, vdo_bundle_win_max,
      dba_bundle)) bundle_win_max
  from
    MaintIsPSAndMFvDollar,
    IsPSAndMFdba_hist,
    BASIS_INFO
  where
    IsPSAndMFdba_hist.OuterJoinDummy=MaintIsPSAndMFvDollar.OuterJoinDummy(+)   
),
IsFixControlReliable as
( select
    decode(sign(nvl(sum(decode(sfc.bugno,null,1,0)),0)),1,0,1) reliable
  from
  ( select
      substr(trim(translate(value,chr(10)||chr(13)||chr(9),'   ')),1,instr(trim(value),':')-1) subname
    from
    ( select
        inst_id,
        substr(','||value,
         instr(','||value,',',1,nr)+1,
         decode(instr(','||value,',',1,nr+1),
           0,length(','||value),
           instr(','||value,',',1,nr+1)-1)-
         decode(instr(','||value,',',1,nr),
           0,length(','||value),
           instr(','||value,',',1,nr))) value
      from
        gv$parameter,
        NumGen
      where
        name='_fix_control'
    )
    where
      value is not null
  ) b,
    v$system_fix_control sfc
  where
    b.subname=to_char(sfc.bugno(+))
),
IsFeatureUsed as
( select
    nvl(max(sim_asm),nvl(max(decode(event,
      'ASM background timer','Y',null)),'N')) is_asm,
    nvl(max(sim_oes),nvl(max(decode(event,
      'cell single block physical read','Y',null)),'N')) is_oes
  from
    v$system_event,
    BASIS_INFO
  where
    event in ('cell single block physical read',
      'ASM background timer','db file sequential read')
),
IsABAPStack as
( select
    nvl(max(sim_abap),nvl(max(decode(table_name,
      'T000','Y',null)),'N')) is_abap
  from
    dba_tables,
    BASIS_INFO
  where
    owner like 'SAP%' and table_name='T000' or    
    owner='SYS' and table_name='TAB$'
),
IsDatabase as
( select
    name,
    nvl(sim_os,platform_name) platform_name,
    decode(instr(upper(nvl(sim_os,platform_name)),'WIN'),
      0,'UNIX',
      'WINDOWS') os_family
  from
    v$database,
    BASIS_INFO
),
IsDatafileCount as
( select
    count(*) value
  from
    v$datafile ),
IsEvent as
( select
    count(*) contains_colon
  from
    gv$parameter2
  where
    name = 'event' and
    instr(value,':')>0
),
ShouldRestrictionAndHeuristics as
( select
    s.inst_id,
    lower(decode(instr(n,','),0,n,substr(n,1,instr(n,',')-1))) name,
    lower(decode(instr(n,','),0,' ',substr(n,instr(n,',')+1))) subname,
    replace(decode(n,
      'DB_FILES','>='||to_char(round(IsDatafileCount.value*1.1)),
      'PARALLEL_MAX_SERVERS',decode(cpu_count*10-para_max,
        0,'-aut-'||substr(w,6),w),
      'PGA_AGGREGATE_TARGET',decode(sign(round(MAX_since_start/(pga_limit_value+1)*100)-90),
        -1,decode(sign(round(MAX_since_start/(pga_limit_value+1)*100)-75),
          1,'-aut-'||substr(w,6),
           w),
        w),
      'PROCESSES',decode(sign(round(MAX_UTILIZATION/(res_limit_value+1)*100)-75),
        -1,'-aut-'||substr(w,6),w),
      'SESSIONS',decode(sign(round(MAX_UTILIZATION/(res_limit_value+1)*100)-75),
        -1,'-aut-'||substr(w,6),w),
      'SHARED_POOL_SIZE',decode(sga_target,
        0,decode(sign(shared_pool_size_mb-0.5*calculated_shared_pool_size_mb),
          -1,'-man-'||w,
          decode(sign(shared_pool_size_mb-2*calculated_shared_pool_size_mb),
            1,'-man-'||w,
            '-aut-'||w)),
        '-man-'||w),
      'UNDO_RETENTION',decode(max_stolen,
        0,'-aut-'||substr(w,6),w),
      w),'[SID]',IsDatabase.name) value,
    p flags,
    decode(n,
      'LOG_BUFFER',replace(c,'[CPU_COUNT]',to_char(cpu_count)),
      'PARALLEL_MAX_SERVERS','Max used (gv$resource_limit): '||MAX_UTILIZATION
        ||' ('||round(MAX_UTILIZATION/(para_max+1)*100)
        ||'%); '
        ||replace(c,'[CPU_COUNT]',to_char(cpu_count)),
      'PGA_AGGREGATE_TARGET','Max used MB (gv$pgastat): '||round(MAX_since_start/1024/1024)
        ||' ('||round(MAX_since_start/(pga_limit_value+1)*100)
        ||'%) ',
      'PROCESSES','Max used (gv$resource_limit): '||MAX_UTILIZATION
        ||' ('||round(MAX_UTILIZATION/(res_limit_value+1)*100)
        ||'%)',
      'SESSIONS','Max used (gv$resource_limit): '||MAX_UTILIZATION
        ||' ('||round(MAX_UTILIZATION/(res_limit_value+1)*100)
        ||'%); '
        ||replace(c,'[PROCESSES]',to_char(processes)),
      'SHARED_POOL_SIZE',decode(sga_target,
        0,'current: '||round(shared_pool_size_mb)||
          ' MB; calculated: '||round(calculated_shared_pool_size_mb)||' MB',
        'ASMM is used (sga_target>0)'),
      'UNDO_RETENTION','Max unexpired stolen blocks (gv$undostat): '||max_stolen,
      c) remark,
    decode(instr(lower(n),'_fix_control'),
      0,'N',
      decode(bugno,
        null, decode(sim_bundle,
          null,'Y',
          'N'),
        'N')) hide,
    version,
    startup_time,
    decode(os_family, 'WINDOWS', bundle_win_min,
      bundle_date_min) bundle_min,
    decode(os_family, 'WINDOWS', bundle_win_max,
        bundle_date_max) bundle_max,
    dba_bundle,
    decode(os_family, 'WINDOWS', vdo_bundle_win_min,
      vdo_bundle_date_min) vdo_bundle_min,
    decode(os_family, 'WINDOWS', vdo_bundle_win_max,
        vdo_bundle_date_max) vdo_bundle_max,
    decode(r_fix,null,0,to_number(nvl(substr(r_fix,
      1,instr(r_fix,'-')-1),0))) restriction_min,
    decode(r_fix,null,991231,to_number(nvl(substr(r_fix,
      instr(r_fix,'-')+1),991231))) restriction_max,
    is_rac,
    is_asm,
    is_oes,
    is_abap,
    contains_colon IsEvent_contains_colon,
    reliable IsFixControlReliable,
    name db_name,
    platform_name
  from
    ShouldPerInstCondColsOrByLine s,
    IsResLim,
    IsPgaStat,
    IsSomeParVals,
    IsUndoStat,
    IsPSAndMF,
    IsFixControlReliable,
    v$system_fix_control IsFixControl,
    IsFeatureUsed,
    IsABAPStack,
    IsDatabase,
    IsDatafileCount,
    IsEvent,
    BASIS_INFO
  where
    s.inst_id = IsResLim.inst_id(+) and
            n = resource_name(+) and
    s.inst_id = IsPgaStat.inst_id(+) and
    s.inst_id = IsSomeParVals.inst_id and
    s.inst_id = IsUndoStat.inst_id(+) and
    ( r_fix is null or
      os_family = 'UNIX' and
        bundle_date_max >= to_number(nvl(substr(r_fix,1,instr(r_fix,'-')-1),0)) and
        bundle_date_min <= to_number(nvl(substr(r_fix,instr(r_fix,'-')+1),991231)) or
      os_family = 'WINDOWS' and
        bundle_win_max >= to_number(nvl(substr(r_fix,1,instr(r_fix,'-')-1),0)) and
        bundle_win_min <= to_number(nvl(substr(r_fix,instr(r_fix,'-')+1),991231))
    ) and
    lower(decode(instr(n,','),
      0,' ',
      substr(n,instr(n,',')+1)))=to_char(bugno(+)) and
    decode(bugno(+),
      null, decode(instr(lower(n),'_fix_control'),
        0,'OK',
        decode(oj_helper_sim_bundle,
          null,'HIDE',
          'OK')),
      'OK')='OK' and
    (r_osf is null or instr(r_osf,os_family)>0) and
    (r_rac is null or r_rac = is_rac) and
    (r_ldt is null or r_ldt = is_ldt) and    
    (r_inm is null or r_inm = is_inm) and
    (r_asm is null or r_asm = is_asm) and
    (r_oes is null or r_oes = is_oes) and
    (r_abap is null or r_abap = is_abap) and
    (r_bw is null or r_bw = is_olap ) and
    (r_lac is null or r_lac = is_lac ) and
    (r_os is null or instr(r_os,platform_name)>0) and        
    (r_ps is null or instr(r_ps,decode(substr(version,1,3),
      '12.',substr(version,8,1),'?'))>0) and
    (r_rel is null or instr(r_rel,decode(substr(version,1,3),
      '12.',substr(version,4,1),'?'))>0)
),
ShouldParamsFinal as
( select
    startup_time,
    db_name,
    version||decode(sim_bundle,null,'','(man)') db_patch_set,
    decode(bundle_min,
      bundle_max, to_char(bundle_max),
      '['||bundle_min||'-'||bundle_max||']')||
    decode(sim_bundle,null,'','(man)')||' (v$sys_fix: '||
    decode(vdo_bundle_min,
      vdo_bundle_max, vdo_bundle_max,
      '['||vdo_bundle_min||'-'||vdo_bundle_max||']')||', dba_registry_...: '||
      dba_bundle||')' db_bundle_patch,
    decode(is_olap,'Y','OLAP','?','OLTP or OLAP','OLTP')||'(man)'||
    decode(is_abap,'Y',', ABAP',', not ABAP')||
      decode(sim_abap,null,'','(man)')||
    decode(is_rac,'Y',', RAC',', not RAC')||
      decode(sim_rac,null,'','(man)')||
    decode(is_asm,'Y',', ASM',', not ASM')||
      decode(sim_asm,null,'','(man)')||
    decode(is_oes,'Y',', OES',', not OES')||
      decode(sim_oes,null,'','(man)') db_environment,
    platform_name||decode(sim_os,null,'','(man)') platform_name,
    nvl(substr(
      decode(sign(dba_bundle-vdo_bundle_min),
        -1, '',', Registry Scripts')||
      decode(IsEvent_contains_colon,0,', Events','')||
      decode(IsFixControlReliable,1,', _fix_controls','')||
      decode(instr(',12,',','||substr(version,4,1)||substr(version,8,1)||','),
        0,'',', PS ever supported')||
      decode(instr(',12,',','||substr(version,4,1)||substr(version,8,1)||','),
        0,'',', PS still maintained')
    ,3), 'none') passed_checks,
    nvl(substr(
      decode(sign(dba_bundle-vdo_bundle_min),
        -1, ', Registry Scripts','')||
      decode(IsEvent_contains_colon,0,'',', Events')||
      decode(IsFixControlReliable,1,'',', _fix_controls')||
      decode(instr(',12,',','||substr(version,4,1)||substr(version,8,1)||','),
        0,', PS ever supported','')||
      decode(instr(',12,',','||substr(version,4,1)||substr(version,8,1)||','),
        0,', PS still maintained','')
    ,3), 'none') failed_checks,
    name,
    subname,
    decode(sign(bundle_min-restriction_min),
      -1, '-man-set to '||value||' if systems bundle patch is between '||restriction_min||' and '||restriction_max,
      decode(sign(restriction_max-bundle_max),
        -1, '-man-set to '||value||' if systems bundle patch is between '||restriction_min||' and '||restriction_max,
        value)) value,
      flags,
      remark,
      inst_id,
      is_rac,
      hide,
      bundle_min,
      bundle_max,
      restriction_min,
      restriction_max
    from
      ShouldRestrictionAndHeuristics,
      BASIS_INFO
    where
      hide='N'
),
MaintSAPSpecialParamsRaw as
( select '#'||
'_ADVANCED_INDEX_COMPRESSION_OPTIONS#_AWR_MMON_DEEP_PURGE_ALL_EXPIRED#'||
'_ENABLE_NUMA_SUPPORT#_FILE_SIZE_INCREASE_INCREMENT#'||
'_FIX_CONTROL 5099019#_FIX_CONTROL 5705630#_FIX_CONTROL 6055658#'||
  '_FIX_CONTROL 6120483#_FIX_CONTROL 6399597#_FIX_CONTROL 6430500#'||
  '_FIX_CONTROL 6440977#_FIX_CONTROL 6626018#_FIX_CONTROL 6972291#'||
  '_FIX_CONTROL 7168184#_FIX_CONTROL 7658097#'||   
  '_FIX_CONTROL 8937971#_FIX_CONTROL 9196440#'||
  '_FIX_CONTROL 9495669#_FIX_CONTROL 13077335#'||
  '_FIX_CONTROL 13627489#_FIX_CONTROL 14255600#_FIX_CONTROL 14595273#'||  
  '_FIX_CONTROL 14846352#_FIX_CONTROL 18405517#_FIX_CONTROL 20355502#'||
  '_FIX_CONTROL 22540411#'||
'_KTB_DEBUG_FLAGS#_MUTEX_WAIT_SCHEME#_MUTEX_WAIT_TIME#'||
'_OPTIM_PEEK_USER_BINDS#_OPTIMIZER_ADAPTIVE_CURSOR_SHARING#'||
  '_OPTIMIZER_AGGR_GROUPBY_ELIM#_OPTIMIZER_BATCH_TABLE_ACCESS_BY_ROWID#'||
  '_OPTIMIZER_EXTENDED_CURSOR_SHARING_REL#_OPTIMIZER_REDUCE_GROUPBY_KEY#'||
  '_OPTIMIZER_USE_FEEDBACK#'||  
'_SECUREFILES_CONCURRENCY_ESTIMATE#_SUPPRESS_IDENTIFIERS_ON_DUPKEY#'|| 
'_USE_SINGLE_LOG_WRITER#'|| 
'EVENT 10027#EVENT 10028#EVENT 10142#EVENT 10183#EVENT 10191#'||
  'EVENT 10995#EVENT 38068#EVENT 38085#EVENT 38087#EVENT 44951#'
    val
  from
    dual
),
SysNormalParamsPerInstByLine as
( select
    inst_id,
    lower(name) name,
    ' ' subname,
    concat(lpad(isdefault,5),value) sort_string,
    ismodified
  from
    gv$parameter2
  where
    name not in ('event','_fix_control')
),
SysSpecialParamsPerInstByLine as
( select
    inst_id,
    name,
    substr(trim(translate(value,
      chr(10)||chr(13)||chr(9),'   ')),1,decode(name,'event',5,instr(trim(value),':')-1)) subname,
    concat('FALSE',trim(translate(value,
      chr(10)||chr(13)||chr(9),'  '))) sort_string,
    ismodified
  from
  ( select
      inst_id,
      name,
      substr(decode(name,'event',':',',')||value,
        instr(decode(name,'event',':',',')||value,decode(name,'event',':',','),1,nr)+1,
        decode(instr(decode(name,'event',':',',')||value,decode(name,'event',':',','),1,nr+1),
         0,length(decode(name,'event',':',',')||value),
         instr(decode(name,'event',':',',')||value,decode(name,'event',':',','),1,nr+1)-1)-
       decode(instr(decode(name,'event',':',',')||value,decode(name,'event',':',','),1,nr),
         0,length(decode(name,'event',':',',')||value),
         instr(decode(name,'event',':',',')||value,decode(name,'event',':',','),1,nr))) value,
      ismodified
    from
      gv$parameter2,
      NumGen
    where
      name in ('event','_fix_control')
  )
  where
    value is not null
),
SAPSpecialParamsPerInstByLine as
( select
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
  ( select
      inst_id,
      '*** INFORMATION '||lpad(rownum,2)||
      ' ***' n
    from
      gv$mystat
    where
      rownum < 12 union (
    select
      inst_id,
      n
    from
    ( select
        substr(val,instr(val,'#',1,nr-0)+1,
          instr(val,'#',1,nr+1)-instr(val,'#',1,nr-0)-1) n
      from
        MaintSAPSpecialParamsRaw,
        NumGen
      where
        substr(val,instr(val,'#',1,nr-0)+1,
          instr(val,'#',1,nr+1)-instr(val,'#',1,nr-0)-1) is not null
    ),
    gv$instance)
  )
),
IsParamsFinal as
( select
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
    select * from SysNormalParamsPerInstByLine union
    (select * from SysSpecialParamsPerInstByLine) union
    (select * from SAPSpecialParamsPerInstByLine)
  )
  group by
    inst_id,
    name,
    subname
)
select
  name,
  substr(order_recommendation,3) recommendation,
  substr(flags,1,1) "I",
  substr(flags,2,1) "U",
  remark,
  is_set,
  is_value,
  should_be_value,
  substr(order_recommendation,1,1) "ID",
  inst_id
from
(
  select
    decode(substr(i.name,1,3),
      '***',-1,i.inst_id) inst_id,
    decode(substr(i.name,1,3),
      '***',upper(i.name),
      decode(i.subname,
        ' ',i.name,
        i.name||' ('||i.subname||')')) name,
    decode(substr(i.name,1,3),
      '***','* '||
        decode(substr(i.name,17,2),
          ' 1',
'Parameter Check for Oracle 12 based on Note/Version: 1888485/'||m.NoteVersion,
          ' 2',
'Parameter Check last changed: '||m.LastChanged,
          ' 3',
'Parameter Check Execution: '||to_char(sysdate,'YYYY-MM-DD HH24:MI:SS'),
          ' 4','DB Startup: '||to_char(startup_time,'YYYY-MM-DD HH24:MI:SS'),
          ' 5','DB SID: '||db_name||' ' ||decode(is_rac,
'Y',' (information section from instance '||i.inst_id||')',
            ''),
          ' 6','DB Patchset: '||db_patch_set,
          ' 7','DB Bundle Patch: '||db_bundle_patch,
          ' 8','DB Environment: '||db_environment,
          ' 9','DB Platform: '||platform_name,
          '10','Passed Checks: '||passed_checks,
          '11','Failed Checks: '||failed_checks),
      decode(i.ismodified,
        'FALSE', decode(i.isdefault,
          'TRUE',decode(s.value,
            null,
'Q ok (is not set; mentioned with other prerequisites/not mentioned in note)',
            decode(substr(s.value,1,5),
              '-man-',
'E check if default value "'||i.value||'" is suitable ('||substr(s.value,6)||')',
              '-aut-',
'H automatic check ok; doublecheck if default value "'||i.value||'" is suitable ('||substr(s.value,6)||')',
              '-any-',
'P ok (is not set; any value recommended)',
              '-del-',
'K ok (is not set; not to be set as explicitly mentioned in note)',
              decode(upper(i.value),
                upper(s.value),
'J add explicitly with default value "'||s.value||'"',
'B add with value "'||s.value||'"'))),
          decode(s.value,
            null,
'G check why set but mentioned with other prerequisites/not mentioned in note',
            decode(substr(s.value,1,5),
              '-man-',
'F check if value "'||i.value||'" is suitable ('||substr(s.value,6)||')',
              '-aut-',
'I automatic check ok; doublecheck if value "'||i.value||'" is suitable ('||substr(s.value,6)||')',
              '-any-',
'O ok (is set; any value recommended)',
              '-del-',
'C delete (is set; not to be set as explicitly mentioned in note)',
              decode(
                decode(
                  substr(replace(upper(i.value),' ',''),1,length(
                    substr(replace(upper(s.value),' ',''),1,
                    instr(replace(upper(s.value),' ',''),'[')-1))),
                  substr(replace(upper(s.value),' ',''),1,
                    instr(replace(upper(s.value),' ',''),'[')-1),'X',
                  ' ')||
                decode(
                  substr(replace(upper(i.value),' ',''),-length(
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
                      to_number(i.value)-to_number(substr(s.value,3))+1,
                    0)),
                  1,
'M ok (is set correctly >=)',
                  decode(sign(
                    decode(rpad('between ',length(s.value),'X'),
                      replace(translate(s.value,'1234567890','XXXXXXXXXX'),' and ','XXXXX'),
                        to_number(i.value)-to_number(substr(s.value,9,instr(s.value,' and ')-9))+1,
                      0))*sign(
                    decode(rpad('between ',length(s.value),'X'),
                      replace(translate(s.value,'1234567890','XXXXXXXXXX'),' and ','XXXXX'),
                        to_number(substr(s.value,instr(s.value,' and ')+5))-to_number(i.value)+1,
                      0)),
                    1,
'N ok (is set correctly between)',
'D change value to "'||s.value||'"')))))),
      decode(
        decode(substr(i.name,1,4),'nls_',0,1)+
        instr(',nls_length_semantics,nls_nchar_conv_excp,',','||i.name||','),
          0,
'R ok (ignored dynamically changed parameter)',
'A parameter was dynamically changed; no reliable recommendation can be given'))) order_recommendation,
    decode(substr(i.name,1,3),
      '***',' ',
      decode(i.isdefault,
        'TRUE','N',
        'Y')) is_set,
    i.value is_value,
    decode(substr(s.value,1,5),
      '-man-',substr(s.value,6),
      '-aut-',substr(s.value,6),
      '-any-','any value',
      '-del-','deleted '||chr(102)||'rom parameter file',
              s.value) should_be_value,
    s.remark,
    s.flags
  from
    ShouldParamsFinal s,
    IsParamsFinal i,
    MaintInfo m
  where
    i.inst_id=s.inst_id(+) and
    i.name=s.name(+) and
    i.subname=s.subname(+)
) union all
( select /* dummy select due to SQL editor bug */
  null,null,null,null,null,null,null,null,null,null from dual where 1=0 )
order by
  id,
  i,
  u,
  name,
  inst_id
));