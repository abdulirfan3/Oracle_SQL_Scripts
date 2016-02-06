--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008-2012 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

set echo on
set trimspool on

/*
drop table t;

create table t (x int, y int);
create index t_x_idx on t(x);
insert into t(x,y) select rownum, rownum from dual connect by level <= 10000;
commit;
exec dbms_stats.gather_table_stats(user, 'T', cascade=>true, method_opt=>'for all columns size 1', estimate_percent=>null);
*/

--alter system flush shared_pool;

alter system flush buffer_cache;

alter session set statistics_level=all;

select /*+ index(t,t_x_idx) xplan_test_marker */ t.y, (select y from t t2 where t2.x = t.x) from t where x > 0;

select /*+ leading(t2) use_nl(t1,t2)  index(t2,t_x_idx) xplan_test_marker */ t1.*, t2.*
  from t t1, t t2
 where t1.x = t2.x
   and t1.y <= 1000;
   
update /*+ xplan_test_marker */ t set x = x;
rollback;

set autotrace traceonly statistics

insert /*+ append xplan_test_marker */ into t select rownum-1, rownum-1 from dual connect by level <= 100000;
rollback;

set autotrace off

@xplan "%xplan_test_marker%" "ti=n,oi=n,plan_details=y"

