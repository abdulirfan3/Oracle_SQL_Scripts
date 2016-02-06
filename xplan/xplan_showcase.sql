--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

set termout on echo on

drop table child purge;
drop table t purge;
drop table parent purge;

-- table parent
create table parent (rr varchar2(1) primary key);
insert into parent(rr) values ('x');

-- table t
create table t (x, padding, rr, constraint t_pk primary key (x,padding))
organization index
overflow
partition by range (x, padding) 
--subpartition by hash (padding, x) subpartitions 2
(
  partition p1 values less than (100,'A'),
  partition p2 values less than (200,'B'),    
  partition pother values less than (maxvalue,maxvalue)
)
as 
select rownum x, rpad(rownum, 300,'x') padding, rpad('x',1) rr from dual connect by level <= 1000;

create or replace view v as 
select x, padding, rr 
  from t
 where x > 0;
  
create or replace function plsql_func (p varchar2)
return varchar2
is
begin
  return p;
end plsql_func;
/
disassociate statistics from functions plsql_func;
associate statistics with functions plsql_func default selectivity 0.001, default cost (100,10,1);

alter table t add constraint t_uq_1 unique (padding);
alter table t add constraint t_uq_2 unique (padding,x);
alter table t add constraint t_parent_fk  foreign key (rr) references parent(rr);

create index t_idx on t(padding, x) local;
create index t_fbi on t(x, upper(x), padding) local;
create index t_fbi2 on t(x, case when x = 0 then 'pippo' when x = 1 then 'uuiio' when x = 3 then 'uuciio' when x = 4 then 'uuieio' else 'pppppp' end );

exec dbms_stats.gather_table_stats (user,'t',cascade=>true, method_opt=>'for all columns size 254', estimate_percent=>null, granularity=>'ALL');

-- table child
create table child (padding varchar2(3 char), constraint child_t_fk foreign key (padding) references t(padding));

alter session set statistics_level=all;
alter system flush shared_pool;
alter system flush buffer_cache;

--define SQL_TEST="select /*+ parallel(t,2) parallel_index(t,2) xplan_test_marker */ x,max(padding) from t where abs(x) = 2 and upper(x) = 2 and lower(x) = 2  and x*5=43 and x*4=43 and x*3=43 and x*2 = 43 group by x order by x"
define SQL_TEST="select /*+ index(t,t_fbi) ordered use_nl(v) xplan_test_marker */ t.rr, plsql_func(max(t.x)) from t, v where upper(t.x) >= '0' and t.x > l_y and v.rr ='x' group by t.rr order by t.rr"

alter session set workarea_size_policy=manual;
alter session set hash_area_size=2000000;
alter session set sort_area_size=2000000;                                     

alter session set events '10046 trace name context forever, level 12';

declare l_x number := 0; l_y number := 0; 
begin /* xplan_exec_marker sga_xplan_exec */ for r in (&SQL_TEST.) loop 
    null;
  end loop; 
end;
/

alter session set events '10046 trace name context off';

@xplan "%xplan_test_marker%" "plan_stats= last,access_predicates=Y,lines=150,module=,action=,dbms_xplan=n,plan_details=y,plan_env=y,tabinfos=y"
