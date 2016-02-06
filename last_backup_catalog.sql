ACCEPT database prompt 'Enter DB name or hit enter to get all DB backup: '
Prompt
prompt +------------------------------------+
prompt | Last backup time from Rman Catalog |
Prompt +------------------------------------+
prompt

column completed format a16 justify center
column Database format a10
column dbid format a12 justify center


select * from (
select    f.Database,
    dbid,
    completed "Last DB Backup",
    ' ' || g.arctime "Last Arc Backup"
from    (select    Database,
        db_key,
        lpad(' ',(10-length(dbid))/2 )|| dbid as dbid,
        completed
     from    (select    a.db_name Database,
            b.db_key,
            b.dbid,
            a.completed
         from    (select    db_name,
                max(completion_time) completed
             from    rman.rc_backup_datafile
             group by db_name) a,
                 rman.rc_database b
         where    a.db_name = b.name)
         order by 3 desc) f,
    (select    max(completion_time) arctime,
        db_key
     from    rman.bs
     where    bck_type = 'L'
     group by db_key) g
where    f.db_key = g.db_key (+)
order by 3 desc)
where database like upper(nvl('%&database%',database));
