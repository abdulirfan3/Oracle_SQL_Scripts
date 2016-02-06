prompt run exec DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO (if want up to date info)
prompt info is held in memory and flushed to dba_tab_modifications at certain interval
prompt info is delete when stats are gathered for that segment
prompt look at header of the file for more info
prompt

/*
This information is initially held in memory and only later pushed into 
DBA_TAB_MODIFICATIONS and so you may not see the latest information. 
Under oracle 9 this information is flushed down every 15 minutes I believe, 
under 10.1 it is 3 hours and under 10.2 onwards the information is only flushed 
down when stats are gathered against the segment OR you manually flush the 
information down to the database.

When statistics are gathered on a segment, any corresponding rows in D
BA_TAB_MODIFOCATIONS is deleted, not updated to zeros, and is recreated only when relevent 
inserts,updates, deletes or truncates occur on the segment.

*/

select table_name,PARTITION_NAME,inserts,updates,deletes,truncated,timestamp
from dba_tab_modifications
where table_owner=upper('&table_owner') and table_name= upper('&table_name');


/*
-- how to use it to get a very fast count of rows in a VERY large table
select dbta.owner||'.'||dbta.table_name       tab_name
     ,dbta.num_rows                  anlyzd_rows
     ,to_char(dbta.last_analyzed,'dd/mm/yyyy hh24:mi:ss')  last_anlzd
     ,nvl(dbta.num_rows,0)+nvl(dtm.inserts,0)
      -nvl(dtm.deletes,0)               tot_rows
  ,nvl(dtm.inserts,0)+nvl(dtm.deletes,0)+nvl(dtm.updates,0) chngs
  ,(nvl(dtm.inserts,0)+nvl(dtm.deletes,0)+nvl(dtm.updates,0))
    /greatest(nvl(dbta.num_rows,0),1)      pct_c
  ,dtm.truncated                  trn
from         dba_tables            dbta
-- replace below with all_tab_modifications if you need
left outer join sys.dba_tab_modifications dtm
   on  dbta.owner         = dtm.table_owner
   and dbta.table_name    = dtm.table_name
   and dtm.partition_name is null
where dbta.table_name ='&table_name'
and dbta.owner     ='&table_owner';
*/
