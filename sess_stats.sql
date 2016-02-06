prompt "provide SID and stat name like physical read, logical read, CPU etc or hit enter for all ..."
accept sid prompt "Enter the sid: "
select sn.name, st.value
from v$sesstat st, v$statname sn
where
st.statistic# = sn.statistic#
and st.sid= '&SID'
and sn.name like '%&stat_name%'
order by 2;