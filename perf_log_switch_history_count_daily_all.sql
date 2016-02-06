-- | PURPOSE  : Reports on how often log switches occur in your database on a   |
-- |            daily basis. It will query all records contained in             |
-- |            v$log_history. This script is to be used with an Oracle 8       |
-- |            database or higher.                                             |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

Prompt
Prompt Redo Log Info
select group#, members, bytes/1024/1024 "MB" from v$log;
Prompt
Prompt

--SET PAGESIZE 100
SET VERIFY   off

COLUMN H00   FORMAT a3     HEADING '00'
COLUMN H01   FORMAT a3     HEADING '01'
COLUMN H02   FORMAT a3     HEADING '02'
COLUMN H03   FORMAT a3     HEADING '03'
COLUMN H04   FORMAT a3     HEADING '04'
COLUMN H05   FORMAT a3     HEADING '05'
COLUMN H06   FORMAT a3     HEADING '06'
COLUMN H07   FORMAT a3     HEADING '07'
COLUMN H08   FORMAT a3     HEADING '08'
COLUMN H09   FORMAT a3     HEADING '09'
COLUMN H10   FORMAT a3     HEADING '10'
COLUMN H11   FORMAT a3     HEADING '11'
COLUMN H12   FORMAT a3     HEADING '12'
COLUMN H13   FORMAT a3     HEADING '13'
COLUMN H14   FORMAT a3     HEADING '14'
COLUMN H15   FORMAT a3     HEADING '15'
COLUMN H16   FORMAT a3     HEADING '16'
COLUMN H17   FORMAT a3     HEADING '17'
COLUMN H18   FORMAT a3     HEADING '18'
COLUMN H19   FORMAT a3     HEADING '19'
COLUMN H20   FORMAT a3     HEADING '20'
COLUMN H21   FORMAT a3     HEADING '21'
COLUMN H22   FORMAT a3     HEADING '22'
COLUMN H23   FORMAT a3     HEADING '23'
COLUMN TOTAL FORMAT 999,999 HEADING 'Total'
COLUMN Day   FORMAT a9
COLUMN date  format a10

SELECT   a.date1 "Date",
         TO_CHAR (TO_DATE (a.date1, 'YYYY-MM-DD'), 'DAY') "Day",
         a.COUNT "Count", a.min# "Min#", a.max# "Max#", b.h00,
         b.h01 , b.h02 , b.h03 , b.h04 ,
         b.h05 , b.h06 , b.h07 , b.h08 ,
         b.h09 , b.h10 , b.h11 , b.h12 ,
         b.h13 , b.h14 , b.h15 , b.h16 ,
         b.h17 , b.h18 , b.h19 , b.h20 ,
         b.h21 , b.h22 , b.h23 
    FROM (SELECT   TO_CHAR (first_time, 'YYYY-MM-DD') date1, COUNT (1) COUNT,
                   MIN (recid) min#, MAX (recid) max#
              FROM v$log_history
          GROUP BY TO_CHAR (first_time, 'YYYY-MM-DD')) a,
         (SELECT   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             0, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h00,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             1, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h01,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             2, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h02,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             3, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h03,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             4, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h04,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             5, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h05,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             6, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h06,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             7, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h07,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             8, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h08,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             9, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h09,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             10, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h10,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             11, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h11,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             12, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h12,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             13, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h13,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             14, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h14,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             15, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h15,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             16, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h16,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             17, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h17,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             18, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h18,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             19, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h19,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             20, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h20,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             21, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h21,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             22, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h22,
                   NVL
                      (TO_CHAR (SUM (DECODE (TO_NUMBER (TO_CHAR (first_time,
                                                                 'HH24'
                                                                )
                                                       ),
                                             23, 1
                                            )
                                    )
                               ),
                       ' '
                      ) h23,
                   TO_CHAR (first_time, 'YYYY-MM-DD') date2
              FROM v$log_history
          GROUP BY TO_CHAR (first_time, 'YYYY-MM-DD')) b
   WHERE a.date1 = b.date2
ORDER BY a.date1;

/*
Prompt 

WITH redo_log_switch_times AS
     (SELECT   sequence#, first_time,
               LAG (first_time, 1) OVER (ORDER BY first_time) AS LAG,
                 first_time
               - LAG (first_time, 1) OVER (ORDER BY first_time) lag_time,
                 1440
               * (first_time - LAG (first_time, 1) OVER (ORDER BY first_time)
                 ) lag_time_pct_mins
          FROM v$log_history
      ORDER BY sequence#)
SELECT round(AVG (lag_time_pct_mins),2) avg_log_switch_per_min
  FROM redo_log_switch_times;
	*/