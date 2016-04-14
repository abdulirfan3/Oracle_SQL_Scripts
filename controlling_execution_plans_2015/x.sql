-- 10g2+

select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));

-- this is 10gR1 command:
--
-- select * from table(dbms_xplan.display_cursor(null,null,'RUNSTATS_LAST'));

-- in 9.2 use @xm <hash_value> <child_number> 
-- <child_number> can be % if you want all children
