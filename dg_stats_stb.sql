@@header
col name for a40
   col value for a40
   col unit for a40
   select
    NAME,
    VALUE,
    UNIT 
    from v$dataguard_stats
    union
    select null,null,' ' from dual
    union
    select null,null,'Time Computed: '||MIN(TIME_COMPUTED)
   from v$dataguard_stats;
	 
@dg_recovery_progress

@@footer