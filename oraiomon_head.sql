--clear scr
select replace(head,'.',' ') from (
select
'.........READ............READ..........READ.........WRITE............READ...........WRITE...........WRITE' as head from dual
union all
select
'.SINGLE.BLOCK......MULTIBLOCK...DIRECT.PATH...DIRECT.PATH.....DIRECT.TEMP.....DIRECT.TEMP......LOG.WRITER' as head from dual
union all
select
'....MS.IOPS/s.......MS.IOPS/s.....MS.IOPS/s.....MS.IOPS/s.......MS.IOPS/s.......MS.IOPs/s.......MS.IOPS/s' as head from dual
union all
select
'---------------------------------------------------------------------------------------------------------' as head from dual
);