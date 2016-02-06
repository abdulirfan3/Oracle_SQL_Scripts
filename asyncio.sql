set linesize 999
set pagesize 999
set numwidth 14
set numformat 999G999G999G990
alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss';
column inst format a4
with subq as
  (select 'ASYNC',
          to_char(inst_id) inst,
          substr(filename,1,60),
          open_time,
          close_time,
          elapsed_time/100,
          substr(device_type,1,10) devtype,
          set_count,
          set_stamp,
          maxopenfiles agg,
          buffer_size,
          buffer_count,
          buffer_size*buffer_count buffer_mem,
          io_count,
          total_bytes,
          bytes,
          decode(nvl(close_time,sysdate),
          open_time,
          null,
          io_count*buffer_size/((nvl(close_time,sysdate)-open_time)*86400))*1 rate,
          effective_bytes_per_second eff
   from gv$backup_async_io where type<>'AGGREGATE'
   union all
   select 'SYNC',
          to_char(inst_id),
          substr(filename,1,60),
          open_time,
          close_time,
          elapsed_time/100,
          substr(device_type,1,10) devtype,
          set_count,
          set_stamp,
          maxopenfiles agg,
          buffer_size,
          buffer_count,
          buffer_size*buffer_count buffer_mem,
          io_count,
          total_bytes,
          bytes,
          decode(nvl(close_time,sysdate),
          open_time,
          null,io_count*buffer_size/((nvl(close_time,sysdate)-open_time)*86400))*1 rate,
          effective_bytes_per_second eff
   from gv$backup_sync_io where type<>'AGGREGATE')
  select subq.*,
         io_count*buffer_size/((nvl(close_time,sysdate)-open_time)*86400+agg)*1 rate_with_create,
         decode(buffer_mem,0,null,rate/buffer_mem)*1000 efficiency
  from subq order by open_time;
