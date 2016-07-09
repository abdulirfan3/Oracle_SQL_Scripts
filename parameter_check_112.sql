
select null name, null recommendation, null "I", null "U", null remark, null is_set,
  null is_value, null should_be_value, null "ID", null inst_id from dual where 1 = 0
union all (
select null name, null recommendation, null "I", null "U", null remark, null is_set,
  null is_value, null should_be_value, null "ID", null inst_id from dual where 1 = 0
) union all ( select * from (
with BASIS_INFO as
( select /*+MATERIALIZE*/
    decode(substr(upper(is_olap),1,1),
      'Y','Y',
      '?','?',
      'N') is_olap,
    decode(substr(sim_patch,9,1),
      '/',substr(sim_patch,1,8),null) sim_patch_set,
    decode(substr(sim_patch,9,1),
      '/',substr(sim_patch,10),null) sim_bundle,
    platform_name sim_os,
    decode(instr('YN',upper(substr(sim_abap,1,1))),0,'',
      upper(substr(sim_abap,1,1))) sim_abap,
    decode(instr('YN',upper(substr(sim_rac,1,1))),0,'',
      upper(substr(sim_rac,1,1))) sim_rac,
    decode(instr('YN',upper(substr(sim_exa,1,1))),0,'',
      upper(substr(sim_exa,1,1))) sim_exa,
    decode(instr('YN',upper(substr(sim_asm,1,1))),0,'',
      upper(substr(sim_asm,1,1))) sim_asm
  from
  ( select
      '<OLAP System? [n]>' is_olap,
      '<Simulate Patch []>' sim_patch,
      '<Simulate OS []>' sim_os,
      '<Simulate ABAP []>' sim_abap,
      '<Simulate RAC []>' sim_rac,
      '<Simulate ASM []>' sim_asm,
      '<Simulate Exadata []>' sim_exa
    from
      dual
  ),
    v$transportable_platform
  where
    sim_os=platform_name(+)
),
MaintInfo as
( select
     '94' NoteVersion,
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
||'_AWR_MMON_DEEP_PURGE_ALL_EXPIRED#TRUE#PS[4]###'
||'_B_TREE_BITMAP_PLANS#FALSE#PS[1]OSF[U]FIX[-201009]EXA[F]:'
  ||'PS[1]OSF[W]FIX[-5]#2p#'
  ||'avoid bitmap operations when using B*TREE indexes#'
||'_BUG16850197_ENABLE_FIX_FOR_13602883#1#'
  ||'PS[3]OSF[U]FIX[201311-201311]EXA[F]#2f#'
  ||'avoids instance crash with ORA-600: [kjruch:resp]#'
||'_DISABLE_CELL_OPTIMIZED_BACKUPS#TRUE#PS[2]OSF[U]EXA[T]:'
  ||'PS[3]FIX[-201312]OSF[U]EXA[T]###'
||'_ENABLE_NUMA_SUPPORT#'
  ||'-man-set optionally to TRUE after successful test##2p##'
||'_FIFTH_SPARE_PARAMETER#1#PS[2]OSF[U]FIX[201212-201304]EXA[F]#2p#'
  ||'consider blck chg track during inc. Backups#'
||'_FILE_SIZE_INCREASE_INCREMENT#2143289344#'
  ||'PS[3]OSF[U]FIX[-201301]EXA[T]###'
||'_FIRST_SPARE_PARAMETER#1#PS[3]OSF[W]FIX[14-]:'
  ||'PS[2]OSF[U]FIX[201011-201104]EXA[F]#2p#'
  ||'avoid high CPU consumption for Mutex requests#'
||'_FIX_CONTROL,4728348#4728348:OFF#PS[1]OSF[U]FIX[-201101]EXA[F]:'
  ||'PS[1]OSF[W]FIX[-10]:PS[2]OSF[U]FIX[-201102]EXA[F]#1f#'
  ||'avoid wrong values; note 1547676#'
||'_FIX_CONTROL,5099019#5099019:ON##2p#'
  ||'dbms_stats counts leaf blocks correctly#'
||'_FIX_CONTROL,5705630#5705630:ON##2p#'
  ||'use optimal OR concatenation; note 176754#'
||'_FIX_CONTROL,6055658#6055658:OFF#PS[34]:PS[2]OSF[W]FIX[6-]:'
  ||'PS[1]OSF[W]FIX[12-]:PS[12]OSF[U]FIX[201105-]EXA[F]:'
  ||'PS[2]OSF[U]FIX[201106-]EXA[T]#2p#'
  ||'calculate correct join card. with histograms#'
||'_FIX_CONTROL,6120483#6120483:OFF##2p##'
||'_FIX_CONTROL,6399597#6399597:ON##2p#'
  ||'sort group by instead of hash group by; note 176754#'
val from dual ) union all ( select '#'
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
||'_FIX_CONTROL,8937971#8937971:ON#PS[34]:PS[2]OSF[W]:'
  ||'PS[1]OSF[W]FIX[6-]:PS[2]OSF[U]FIX[201011-]EXA[F]:'
  ||'PS[2]OSF[U]FIX[201106-]EXA[T]:PS[1]OSF[U]FIX[201009-]EXA[F]#2f#'
  ||'correct clause definition dbms_metadata.get_ddl#'
||'_FIX_CONTROL,9196440#9196440:ON#PS[34]:PS[2]OSF[W]:'
  ||'PS[1]OSF[W]FIX[4-]:PS[2]OSF[U]FIX[201011-]EXA[F]:'
  ||'PS[2]OSF[U]FIX[201106-]EXA[T]:PS[1]OSF[U]FIX[201009-]EXA[F]#2p#'
  ||'fixes low distinct keys in index stats#'
||'_FIX_CONTROL,9495669#9495669:ON#PS[34]:PS[2]OSF[W]:'
  ||'PS[1]OSF[W]FIX[4-]:PS[2]OSF[U]FIX[201011-]EXA[F]:'
  ||'PS[2]OSF[U]FIX[201106-]EXA[T]:PS[1]OSF[U]FIX[201006-]EXA[F]#2p#'
  ||'disable histogram use for join cardinality#'
||'_FIX_CONTROL,12693573#12693573:OFF#PS[2]EXA[T]FIX[201203-]:'
  ||'PS[3]EXA[T]FIX[201203-201306]#2p##'
||'_FIX_CONTROL,13077335#13077335:ON#PS[34]OSF[W]FIX[3-]:PS[4]OSF[U]:'
  ||'PS[3]OSF[U]FIX[201202-]EXA[F]:PS[2]OSF[U]FIX[201201-]EXA[F]:'
  ||'PS[23]OSF[U]FIX[201203-]EXA[T]:PS[2]OSF[W]FIX[16-]#2p#'
  ||'correct long varchar cardinality calculation with histgr#'
||'_FIX_CONTROL,13627489#13627489:ON#PS[4]:PS[3]OSF[W]FIX[7-]:'
  ||'PS[3]OSF[U]FIX[201207-]:PS[2]OSF[W]FIX[20-]:'
  ||'PS[2]OSF[U]EXA[F]FIX[201208-]:PS[2]OSF[U]EXA[T]FIX[201207-]#2p#'
  ||'use good access for merge in dbms_redefinition#'
val from dual ) union all ( select '#'
||'_FIX_CONTROL,14255600#14255600:ON#PS[4]:PS[3]OSF[W]FIX[17-]:'
  ||'PS[3]OSF[U]FIX[201303-]:PS[2]OSF[W]FIX[25-]:'
  ||'PS[2]OSF[U]EXA[F]FIX[201305-]:PS[2]OSF[U]EXA[T]FIX[201306-]#2p#'
  ||'statistic collection during index creation#'
||'_FIX_CONTROL,14595273#14595273:ON#PS[4]:PS[3]OSF[W]FIX[17-]:'
  ||'PS[3]OSF[U]EXA[F]FIX[201302-]:PS[3]OSF[U]EXA[T]FIX[201303-]#2p##'
||'_FIX_CONTROL,14764840#14764840:OFF#PS[4]OSF[U]EXA[T]FIX[201411-]###'
||'_FIX_CONTROL,16015637#16015637:OFF#PS[4]OSF[U]EXA[T]FIX[201411-]###'
||'_FIX_CONTROL,16825679#16825679:ON#PS[4]OSF[U]EXA[T]FIX[201411-]###'
||'_FIX_CONTROL,17736165#17736165:OFF#PS[4]OSF[U]EXA[T]FIX[201411-]###'
||'_FIX_CONTROL,17799716#17799716:OFF#PS[4]OSF[U]EXA[T]FIX[201411-]###'
||'_FIX_CONTROL,18115594#18115594:OFF#PS[4]OSF[U]EXA[T]FIX[201411-]###'
||'_FIX_CONTROL,18134680#18134680:OFF#PS[4]OSF[U]EXA[T]FIX[201411-]###'
||'_FIX_CONTROL,18304693#18304693:OFF#PS[4]OSF[U]EXA[T]FIX[201411-]###'
||'_FIX_CONTROL,18365267#18365267:OFF#PS[4]OSF[U]EXA[T]FIX[201411-]###'
||'_FIX_CONTROL,18405517#18405517:2#PS[4]OSF[W]FIX[7-]:'
  ||'PS[3]OSF[W]FIX[32-]:PS[34]OSF[U]FIX[201408-]#2p##'
||'_FIX_CONTROL,18798414#18798414:OFF#PS[4]OSF[U]EXA[T]FIX[201411-]###'
||'_GC_OVERRIDE_FORCE_CR#FALSE#'
  ||'PS[3]OSF[U]RAC[T]EXA[F]FIX[201402-201406]:'
  ||'PS[3]OSF[U]RAC[T]EXA[T]FIX[201403-201406]:'
  ||'PS[3]OSF[W]RAC[T]FIX[28-32]#1f#'
  ||'can lead to outage of DB (note 2048023)#'
||'_IN_MEMORY_UNDO#FALSE#PS[1]#1f##'
||'_KTB_DEBUG_FLAGS#8##1f#'
  ||'avoid invalid index block SCNs on STDBY; note 2005311#'
||'_MUTEX_WAIT_TIME#10#PS[34]:PS[2]OSF[W]FIX[8-]:'
  ||'PS[2]OSF[U]EXA[F]FIX[201105-]:PS[2]OSF[U]EXA[T]FIX[201106-]#2p#'
  ||'controls mutex spins/waits; note 1588876#'
val from dual ) union all ( select '#'
||'_MUTEX_WAIT_TIME#4#PS[2]OSF[W]FIX[-7]#2p#'
  ||'controls mutex spins/waits; note 1588876#'
||'_MUTEX_WAIT_SCHEME#1#PS[34]:PS[2]OSF[W]:'
  ||'PS[2]OSF[U]EXA[F]FIX[201105-]:PS[2]OSF[U]EXA[T]FIX[201106-]#2p#'
  ||'controls mutex spins/waits; note 1588876#'
||'_NINTH_SPARE_PARAMETER#1#PS[3]OSF[U]EXA[T]FIX[201212-201304]:'
  ||'PS[2]OSF[U]EXA[T]FIX[201212-201302]:PS[2]OSF[U]FIX[23-]#2p#'
  ||'consider blck chg track during inc. Backups#'
||'_OPTIM_PEEK_USER_BINDS#FALSE##1p#avoid bind value peeking#'
||'_OPTIMIZER_ADAPTIVE_CURSOR_SHARING#FALSE##2p##'
||'_OPTIMIZER_EXTENDED_CURSOR_SHARING_REL#NONE##2p##'
||'_OPTIMIZER_USE_CBQT_STAR_TRANSFORMATION#FALSE#PS[3]FIX[-0]:'
  ||'PS[2]OSF[U]FIX[-201109]:PS[2]OSF[W]FIX[-12]:PS[1]#1f##'
||'_OPTIMIZER_USE_FEEDBACK#FALSE##2p#'
  ||'avoid preference of index supporting inlist#'
||'_SECOND_SPARE_PARAMETER#1#PS[1]OSF[U]EXA[F]FIX[201011-]#2p#'
  ||'Avoid high CPU consumption for Mutex requests#'
||'_SECUREFILES_CONCURRENCY_ESTIMATE#50#PS[34]#2p#'
  ||'Avoids buffer busy waits (free list) during LOB inserts#'
||'AUDIT_FILE_DEST#/oracle/[SID]/saptrace/audit#OSF[U]###'
||'AUDIT_FILE_DEST#[DRIVE]:\oracle\[SID]\saptrace\audit#OSF[W]###'
||'BACKGROUND_DUMP_DEST#-del-####'
||'CLUSTER_DATABASE#TRUE#RAC[T]###'
||'COMMIT_LOGGING#-del-##1f##'
||'COMMIT_WAIT#-del-##1f##'
||'COMMIT_WRITE#-del-##1f##'
||'COMPATIBLE#11.2.0#ASM[F]#1f##'
||'COMPATIBLE#'
  ||'-man-SAP default on ASM: 11.2.0.2.0 (see also note 1739274)#'
  ||'ASM[T]#1f##'
||'CONTROL_FILE_RECORD_KEEP_TIME#>=30####'
||'CONTROL_FILES#-man-three copies on different disk areas####'
||'CORE_DUMP_DEST#-del-####'
||'DB_BLOCK_SIZE#8192####'
||'DB_CACHE_SIZE#-man-appropriately set####'
val from dual ) union all ( select '#'
||'DB_CREATE_FILE_DEST#+DATA#ASM[T]###'
||'DB_CREATE_ONLINE_LOG_DEST_1#+DATA#ASM[T]###'
||'DB_CREATE_ONLINE_LOG_DEST_2#+RECO#ASM[T]###'
||'DB_FILE_MULTIBLOCK_READ_COUNT#-del-##1p##'
||'DB_FILES#-man-set larger than short term expected datafiles####'
||'DB_NAME#[SID]####'
||'DB_RECOVERY_FILE_DEST#+RECO#ASM[T]###'
||'DB_RECOVERY_FILE_DEST_SIZE#-man-appropriately set#ASM[T]###'
||'DIAGNOSTIC_DEST#/oracle/[SID]/saptrace#OSF[U]###'
||'DIAGNOSTIC_DEST#[DRIVE]:\oracle\[SID]\saptrace#OSF[W]###'
||'DISK_ASYNCH_IO#'
  ||'-man-set to FALSE with standard filesystem (not on OnlineJFS; note 798194)#'
  ||'OS[HP-UX IA (64-bit),HP-UX (64-bit)], ASM[F]###'
||'EVENT,10027#10027##2f#avoid process state dump at deadlock#'
||'EVENT,10028#10028##2f#do not wait while writing deadlock trace#'
||'EVENT,10142#10142##2p#avoid btree bitmap conversion plans#'
||'EVENT,10183#10183##1p#avoid rounding during cost calculation#'
||'EVENT,10191#10191##2f#avoid high CBO memory consumption#'
||'EVENT,10198#10198#PS[23]OSF[U]FIX[201306-]EXA[T]:'
  ||'PS[23]OSF[U]FIX[201305-]EXA[F]:PS[3]OSF[W]FIX[20-]#1f#'
  ||'avoid ora-60 deadlocks (note 1847870)#'
||'EVENT,10995#10995 level 2##2f#'
  ||'avoid flush shared pool during online reorg#'
||'EVENT,31991#31991#PS[4]OSF[U]:PS[4]OSF[W]FIX[2-]:'
  ||'PS[3]OSF[U]EXA[F]FIX[201208-]:PS[3]OSF[U]EXA[T]FIX[201207-]:'
  ||'PS[3]OSF[W]FIX[8-]:PS[2]OSF[U]FIX[201207-]:PS[2]OSF[W]FIX[20-]::#'
  ||'2p#avoid too many recursive calls#'
||'EVENT,38068#38068 level 100##2p#'
  ||'long raw statistic; implement note 948197#'
||'EVENT,38085#38085##2p#'
  ||'consider cost adjust for index fast full scan#'
||'EVENT,38087#38087##1f#avoid ora-600 at star transformation#'
val from dual ) union all ( select '#'
||'EVENT,44951#44951 level 1024##2p#'
  ||'avoid HW enqueues during LOB inserts#'
||'EVENT,64000#64000 level 25#PS[34]OSF[U]FIX[201508-]:'
  ||'PS[4]OSF[W]FIX[17-]###'
||'FILESYSTEMIO_OPTIONS#SETALL##1p#note  793113#'
||'HPUX_SCHED_NOAGE#178#RAC[F]#2p#performance#'
||'LOCAL_LISTENER#'
  ||'-man-set to (ADDRESS = (PROTOCOL=TCP) (HOST=[hostname]>) (PORT=[port]))#'
  ||'RAC[F]###'
||'LOG_ARCHIVE_DEST_1#LOCATION=+[DGNAME]/[SID]/ORAARCH#ASM[T]RAC[T]###'
||'LOG_ARCHIVE_DEST_1#LOCATION=+ARCH#ASM[T]RAC[F]###'
||'LOG_ARCHIVE_DEST_1#LOCATION=/oracle/[SID]/oraarch/[SID]arch#'
  ||'OSF[U]ASM[F]##note 966073#'
||'LOG_ARCHIVE_DEST_1#'
  ||'LOCATION=[drive]:\oracle\[SID]\oraarch\[SID]arch#OSF[W]ASM[F]##'
  ||'note 966073#'
||'LOG_ARCHIVE_FORMAT#%t_%s_%r.dbf####'
||'LOG_BUFFER#-del-#ASM[T]EXA[F]###'
||'LOG_BUFFER#-man-depends on number of CPUs; details in note 1627481#'
  ||'ASM[F]EXA[F]##CPU_COUNT=[CPU_COUNT]#'
||'LOG_BUFFER#-man-set to at least 128MB; details in note 1627481#'
  ||'EXA[T]##CPU_COUNT=[CPU_COUNT]#'
||'LOG_CHECKPOINTS_TO_ALERT#TRUE####'
||'MAX_DUMP_FILE_SIZE#20000####'
||'NLS_LENGTH_SEMANTICS#-del-##2f##'
||'OPEN_CURSORS#between 800 and 2000####'
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
val from dual ) union all ( select '#'
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
  ||'ABAP[T]###'
||'REMOTE_OS_AUTHENT#-del-#ABAP[F]###'
||'REPLICATION_DEPENDENCY_TRACKING#-any-####'
||'SESSIONS#-man-2*PROCESSES###PROCESSES=[PROCESSES]#'
||'SHARED_POOL_SIZE#appropriately set; note 690241####'
||'SPFILE#-any-####'
||'STAR_TRANSFORMATION_ENABLED#TRUE#PS[2]OSF[U]FIX[201110-]:'
  ||'PS[2]OSF[W]FIX[12-]:PS[3]OSF[U]EXA[T]:'
  ||'PS[3]OSF[U]EXA[F]FIX[201112-]:PS[3]OSF[W]FIX[1-]:PS[4]#1p##'
||'UNDO_RETENTION#-man-appropriately set####'
||'UNDO_TABLESPACE#PSAPUNDO#RAC[F]###'
||'UNDO_TABLESPACE#-man-appropriately set#RAC[T]###'
||'USE_LARGE_PAGES#-man-can be set according to note 1672954#'
  ||'PS[234], OS[Linux IA (64-bit),Linux x86 64-bit]###'
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
    decode(instr(' '||r,'EXA[T]'),
      0,decode(instr(' '||r,'EXA[F]'),
        0,'','N'),'Y') r_exa,
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
    para_max
  from
  ( select
      inst_id,
      max(decode(name,'cpu_count',value,null)) cpu_count,
      max(decode(name,'shared_pool_size',value,null))/1024/1024 shared_pool_size_mb,
      max(decode(name,'sga_target',value,null)) sga_target,
      max(decode(name,'cluster_database',nvl(sim_rac,
        decode(value,'TRUE','Y','N')),null)) cluster_database,  
      max(decode(name,'log_buffer',value,null)) log_buffer,
      max(decode(name,'db_cache_size',value,null)) db_cache_size,
      ( max(decode(name,'cpu_count',value,null))/4*500+
        max(decode(name,'sga_max_size',value,null))/1024/1024/1024*5+300)*
        decode(max(decode(name,'cluster_database',nvl(sim_rac,
        decode(value,'TRUE','Y','N')),null)), 'Y', 1.2, 1) calculated_shared_pool_size_mb
    from
      gv$parameter2,
      BASIS_INFO
    where
      name in ('cluster_database','cpu_count',
        'db_cache_size','log_buffer','sga_max_size',
        'sga_target','shared_pool_size')
    group by
      inst_id
  ) a,
  ( select
      inst_id,
      max(decode(name,'processes',value,null)) processes,
      max(decode(name,'parallel_max_servers',value,null)) para_max
    from
      gv$parameter2
    where
      name in ('processes','parallel_max_servers')
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
        '2,1,201108,999912,000013,000014,12591120'  v1,
        '2,1,201105,201107,000011,000011,6055658'   v2,
        '2,1,201009,201104,000005,000010,8937971'   v3,
        '2,1,201006,201008,000000,000004,9495669'   v4,
        '2,1,000000,201005,000000,000004,-1'        v5,
        '2,2,201308,201311,000026,000027,14712222'  v6,
        '2,2,201305,201305,000025,000025,14723910'  v7,
        '2,2,201302,201302,000024,000024,13891981'  v8,
        '2,2,201209,201301,000021,000022,14255600'  v9,
        '2,2,201208,201208,000020,000020,13627489' v10,
        '2,2,201205,201207,000018,000018,13777823' v11,
        '2,2,201203,201204,000018,000018,13594712' v12,
        '2,2,201202,201202,000016,000016,13524237' v13,
        '2,2,201201,201201,000016,000016,13077335' v14,
        '2,2,201110,201112,000012,000012,12827166' v15,
        '2,2,201108,201109,000008,000009,12591120' v16,
        '2,2,201106,201107,000008,000009,11892888' v17,
        '2,2,201105,201105,000004,000004,6055658'  v18,
        '2,2,201103,201104,000000,000003,11699884' v19,
        '2,2,201011,201102,000000,000003,10134677' v20,
        '2,2,000000,201010,000000,000003,-1'       v21,
        '2,3,201508,999912,000039,000039,20355502' v44,
        '2,3,201502,201505,000036,000037,18876528' v22,
        '2,3,201408,201411,000032,000034,18405517' v23,
        '2,3,201406,201406,000031,000031,18035463' v24,
        '2,3,201312,201402,000028,000028,16470836' v25,
        '2,3,201311,201311,000026,000026,16976121' v26,
        '2,3,201308,201309,000022,000022,16092378' v27,
        '2,3,201306,201306,000020,000020,14712222' v28,
        '2,3,201303,201305,000019,000019,14723910' v29,
        '2,3,201302,201302,000016,000016,13891981' v30,
        '2,3,201211,201301,000013,000013,14467202' v31,
        '2,3,201210,201210,000010,000010,14255600' v32,
        '2,3,201207,201209,000008,000008,13627489' v33,
        '2,3,201205,201206,000005,000005,13777823' v34,
        '2,3,201203,201204,000003,000003,13594712' v35,
        '2,3,201202,201202,000002,000002,13524237' v36,
        '2,3,201112,201201,000000,000001,12622441' v37,
        '2,3,000000,201111,000000,000001,-1'       v38,
        '2,4,201605,201605,160419,160419,22272439' v46,          
        '2,4,201511,201602,000020,160119,21833220' v45,
        '2,4,201508,201508,000015,000015,20355502' v43,
        '2,4,201408,201505,000007,000015,18405517' v39,
        '2,4,201406,201406,000005,000005,18035463' v40,
        '2,4,201402,201402,000002,000002,16470836' v41,
        '2,4,000000,201401,000000,000001,-1'       v42,
        null v47, null v48, null v49, null v50
        from dual)
        unpivot (val for nr in (v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,
        v16,v17,v18,v19,v20,v21,v22,v23,v24,v25,v26,v27,v28,v29,v30,v31,v32,v33,v34,v35,v36,
        v37,v38,v39,v40,v41,v42,v43,v44,v45,v46,v47,v48,v49,v50)) bf,
      ( select bugno from v$system_fix_control union ( select -1 bugno from dual)) fc,
      v$instance i
    where
      to_number(substr(val,33))=fc.bugno and
      substr(i.version,1,8)='11.'||substr(val,1,1)||'.0.'||substr(val,3,1)
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
        ( substr(h.comments,1,6) ='Patch ' or
          substr(h.comments,1,12)='11.2.0.3 BP ' or
          substr(h.comments,1,19)='WinBundle 11.2.0.4.' or
          substr(h.comments,1,11)='SBP 11.2.0.') and
        substr(i.version,1,8) = substr(h.version, 1, 8) and
        action='APPLY'
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
    nvl(max(sim_exa),nvl(max(decode(event,
      'cell single block physical read','Y',null)),'N')) is_exa
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
    owner like 'SAP%' and table_name = 'T000' or    
    owner = 'SYS' and table_name = 'TAB$'
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
    is_exa,
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
    (r_asm is null or r_asm = is_asm) and
    (r_exa is null or r_exa = is_exa) and
    (r_abap is null or r_abap = is_abap) and
    (r_bw is null or r_bw = is_olap ) and
    (r_os is null or instr(r_os,platform_name)>0) and        
    (r_ps is null or instr(r_ps,decode(substr(version,1,7),
      '11.2.0.',substr(version,8,1),'?'))>0)
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
      '['||vdo_bundle_min||'-'||vdo_bundle_max||']')||', dba_reg_hist: '||
      dba_bundle||')' db_bundle_patch,
    decode(is_olap,'Y','OLAP','?','OLTP or OLAP','OLTP')||'(man)'||
    decode(is_abap,'Y',', ABAP',', not ABAP')||
      decode(sim_abap,null,'','(man)')||
    decode(is_rac,'Y',', RAC',', not RAC')||
      decode(sim_rac,null,'','(man)')||
    decode(is_asm,'Y',', ASM',', not ASM')||
      decode(sim_asm,null,'','(man)')||
    decode(is_exa,'Y',', EXADATA',', not EXADATA')||
      decode(sim_exa,null,'','(man)') db_environment,
    platform_name||decode(sim_os,null,'','(man)') platform_name,
    nvl(substr(
      decode(sign(dba_bundle-vdo_bundle_min),
        -1, '',', Registry Scripts')||
      decode(IsEvent_contains_colon,0,', Events','')||
      decode(IsFixControlReliable,1,', _fix_controls','')||
      decode(is_rac,'N','',
        decode(instr(upper(platform_name),'WIN'),
          0,decode(instr('11.2.0.2 11.2.0.3',substr(version,1,8)),
            0,'',
            decode(sign(bundle_min-1203),-1,'',', RAC Bug')),
          decode(substr(version,1,8),
            '11.2.0.2',decode(sign(bundle_min-18),-1,'',', RAC Bug'),
            '11.2.0.3',decode(sign(bundle_min-3),-1,'',', RAC Bug'),
            ', RAC Bug')))||
      decode(instr('1234',substr(version,8,1)),0,'',
        ', PS ever supported')||
      decode(instr('4',substr(version,8,1)),0,'',
        ', PS still maintained')
    ,3), 'none') passed_checks,
    nvl(substr(
      decode(sign(dba_bundle-vdo_bundle_min),
        -1, ', Registry Scripts','')||
      decode(IsEvent_contains_colon,0,'',', Events')||
      decode(IsFixControlReliable,1,'',', _fix_controls')||
      decode(is_rac,'N','',
        decode(instr(upper(platform_name),'WIN'),
          0,decode(instr('11.2.0.2 11.2.0.3',substr(version,1,8)),
            0,'',
            decode(sign(bundle_min-1203),-1,', RAC Bug','')),
          decode(substr(version,1,8),
            '11.2.0.2',decode(sign(bundle_min-18),-1,', RAC Bug',''),
            '11.2.0.3',decode(sign(bundle_min-3),-1,', RAC Bug',''),
            '')))||
      decode(instr('1234',substr(version,8,1)),0,
        ', PS ever supported','')||
      decode(instr('4',substr(version,8,1)),0,
        ', PS still maintained','')
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
  '_FIX_CONTROL 14764840#_FIX_CONTROL 16015637#_FIX_CONTROL 16825679#'||
  '_FIX_CONTROL 17736165#_FIX_CONTROL 17799716#_FIX_CONTROL 18115594#'||
  '_FIX_CONTROL 18134680#_FIX_CONTROL 18304693#_FIX_CONTROL 18365267#'||
  '_FIX_CONTROL 18405517#_FIX_CONTROL 18798414#_FIX_CONTROL 20228468#'||
'_GC_OVERRIDE_FORCE_CR#'||
'_IN_MEMORY_UNDO#_KTB_DEBUG_FLAGS#_MUTEX_WAIT_SCHEME#_MUTEX_WAIT_TIME#'||
'_NINTH_SPARE_PARAMETER#_OPTIM_PEEK_USER_BINDS#'||
  '_OPTIMIZER_ADAPTIVE_CURSOR_SHARING#_OPTIMIZER_EXTENDED_CURSOR_SHARING_REL#'||
  '_OPTIMIZER_USE_CBQT_STAR_TRANSFORMATION#_OPTIMIZER_USE_FEEDBACK#'||
'_SECOND_SPARE_PARAMETER#_SECUREFILES_CONCURRENCY_ESTIMATE#'||
'EVENT 10027#EVENT 10028#EVENT 10142#EVENT 10183#EVENT 10191#EVENT 10198#'||
  'EVENT 10995#EVENT 31991#EVENT 38068#EVENT 38085#EVENT 38087#EVENT 44951#'||
  'EVENT 64000#'
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
'Parameter Check for Oracle 11.2 based on Note/Version: 1431798/'||m.NoteVersion,
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
      '-del-','deleted f'||'rom parameter file',
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