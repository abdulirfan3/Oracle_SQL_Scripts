col value format 999,999,999,999,999
prompt
prompt Memory info from v$pgastat
select * FROM V$PGASTAT;

prompt
prompt Displays the work areas that are active (or executing)
prompt

SELECT TO_NUMBER(DECODE(sid, 65535, null, sid)) sid,
       operation_type operation,
       TRUNC(expected_size/1024) esize,
       TRUNC(actual_mem_used/1024) mem,
       TRUNC(max_mem_used/1024) "max mem",
       number_passes pass,
       TRUNC(TEMPSEG_SIZE/1024) tempsize
  FROM V$SQL_WORKAREA_ACTIVE
 ORDER BY 1,2;
 
/*
The output of this query might look like the following:

SID         OPERATION     ESIZE       MEM   MAX MEM  PASS   TSIZE
--- ----------------- --------- --------- --------- ----- -------
  8   GROUP BY (SORT)       315       280       904     0
  8         HASH-JOIN      2995      2377      2430     1   20000
  9   GROUP BY (SORT)     34300     22688     22688     0
 11         HASH-JOIN     18044     54482     54482     0
 12         HASH-JOIN     18044     11406     21406     1  120000
In this example, the output shows that:

Session 12 (SID column) is running a hash-join operation (OPERATION column) in a work area running in one-pass size (PASS column)

The maximum amount of memory that the PGA memory manager expects this hash-join operation to use is 18044 KB (ESIZE column)

The work area is currently using 11406 KB of memory (MEM column)

The work area used up to 21406 KB of PGA memory (MAX MEM column) in the past

The work area spilled to a temporary segment of 120000 KB (TSIZE column)
*/

prompt
prompt shows the number of work areas executed with optimal, one-pass, and multi-pass memory size since instance startup
prompt 

SELECT low_optimal_size/1024 low_kb,
       (high_optimal_size+1)/1024 high_kb,
       optimal_executions, onepass_executions, multipasses_executions
  FROM V$SQL_WORKAREA_HISTOGRAM
 WHERE total_executions != 0;
 
/*
The result of the query might look like the following:

LOW_KB HIGH_KB OPTIMAL_EXECUTIONS ONEPASS_EXECUTIONS MULTIPASSES_EXECUTIONS
------ ------- ------------------ ------------------ ----------------------
     8      16             156255                  0                      0
    16      32                150                  0                      0
    32      64                 89                  0                      0
    64     128                 13                  0                      0
   128     256                 60                  0                      0
   256     512                  8                  0                      0
   512    1024                657                  0                      0
  1024    2048                551                 16                      0
  2048    4096                538                 26                      0
  4096    8192                243                 28                      0
  8192   16384                137                 35                      0
 16384   32768                 45                107                      0
 32768   65536                  0                153                      0
 65536  131072                  0                 73                      0
131072  262144                  0                 44                      0
262144  524288                  0                 22                      0
In this example, the output shows that—in the 1 MB to 2 MB bucket—551 work areas ran 
in optimal size, while 16 ran in one-pass size and none ran in multi-pass size. 
It also shows that all work areas under 1 MB were able to run in optimal size.

*/