select DB NAME,dbid,NVL(TO_CHAR(max(backuptype_db),'DD/MM/YYYY HH24:MI'),'01/01/0001:00:00') DBBKP,
NVL(TO_CHAR(max(backuptype_arch),'DD/MM/YYYY HH24:MI'),'01/01/0001:00:00') ARCBKP
from (
select a.name DB,dbid,
decode(b.bck_type,'D',max(b.completion_time),'I', max(b.completion_time)) BACKUPTYPE_db,
decode(b.bck_type,'L',max(b.completion_time)) BACKUPTYPE_arch
from rc_database a,bs b
where a.db_key=b.db_key
and b.bck_type is not null
and b.bs_key not in(Select bs_key from rc_backup_controlfile where AUTOBACKUP_DATE
is not null or AUTOBACKUP_SEQUENCE is not null)
and b.bs_key not in(select bs_key from rc_backup_spfile)
group by a.name,dbid,b.bck_type
) group by db,dbid
ORDER BY least(to_date(DBBKP,'DD/MM/YYYY HH24:MI'),to_date(ARCBKP,'DD/MM/YYYY HH24:MI'));