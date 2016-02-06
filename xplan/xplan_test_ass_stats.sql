--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

create or replace type tttt as object (
  dummy_attribute number,
  static function f (p varchar2) return varchar2
);
/
show errors

create or replace type body tttt as
  static function f (p varchar2) 
  return varchar2
  is
  begin
    return p;
  end f;
end;
/
show errors

disassociate statistics from types tttt;
associate statistics with types tttt default selectivity 0.003, default cost (300,30,3);
  
-- following are dummified from http://www.oracle-developer.net/display.php?id=426#

create or replace type stats_ot as object (

   dummy_attribute number,

   static function odcigetinterfaces (
                   p_interfaces out sys.odciobjectlist
                   ) return number,

   static function odcistatsselectivity (
                   p_pred_info      in  sys.odcipredinfo,
                   p_selectivity    out number,
                   p_args           in  sys.odciargdesclist,
                   p_start          in  varchar2,
                   p_stop           in  varchar2,
                   p_promo_category in  varchar2,
                   p_env            in  sys.odcienv
                   ) return number,

   static function odcistatsfunctioncost (
                   p_func_info      in  sys.odcifuncinfo,
                   p_cost           out sys.odcicost,
                   p_args           in  sys.odciargdesclist,
                   p_promo_category in  varchar2,
                   p_env            in  sys.odcienv
                   ) return number
);
/
show errors

create or replace type body stats_ot as

   static function odcigetinterfaces (
                   p_interfaces out sys.odciobjectlist
                   ) return number is
   begin
      p_interfaces := sys.odciobjectlist(
                         SYS.ODCIObject ('SYS', 'ODCISTATS2')
                         );
      RETURN ODCIConst.success;
   end odcigetinterfaces;

   static function odcistatsselectivity (
                   p_pred_info        in  sys.odcipredinfo,
                   p_selectivity      out number,
                   p_args             in  sys.odciargdesclist,
                   p_start            in  varchar2,
                   p_stop             in  varchar2,
                   p_promo_category   in  varchar2,
                   p_env              in  sys.odcienv
                   ) return number is
   begin
      p_selectivity := 0.1;
      return odciconst.success;
   end odcistatsselectivity;

   static function odcistatsfunctioncost (
                   p_func_info      in  sys.odcifuncinfo,
                   p_cost           out sys.odcicost,
                   p_args           in  sys.odciargdesclist,
                   p_promo_category in  varchar2,
                   p_env            in  sys.odcienv
                   ) return number is
   begin
      p_cost := sys.odcicost(null, null, null, null);
      p_cost.cpucost     := 100;
      p_cost.iocost      := 10;
      p_cost.networkcost := 0;
      return odciconst.success;
   end odcistatsfunctioncost;

end;
/
show errors

create or replace function plsql_func (p varchar2)
return varchar2
is
begin
  return p;
end plsql_func;
/

disassociate statistics from functions plsql_func;
associate statistics with functions plsql_func using stats_ot;

drop table t;
create table t (x varchar2(100));
insert into t (x) values ('giulio cesare');
insert into t (x) values ('marco antonio');

create index t_ind_ctx on t(x) indextype is ctxsys.context;

select * from t where contains( x, 'giulio' )  > 0;


alter system flush shared_pool;

define SQL_TEST="select /*+ xplan_test_marker */ tttt.f(x) from t where plsql_func('X') = 'X' and contains(x, 'giulio') > 0"

declare l_x number := 0; l_y number := 0; 
begin /* xplan_exec_marker sga_xplan_exec */ for r in (&SQL_TEST.) loop null; end loop; end;
/

@xplan "%xplan_test_marker%" "plan_stats= last ,access_predicates=Y,lines=150,module=,action=,dbms_xplan=n,plan_details=n,plan_env=y,tabinfos=y"
