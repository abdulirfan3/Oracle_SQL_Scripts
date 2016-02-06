SELECT  TRUNC(sample_time),
        machine           ,
        module            ,
        event             ,
        COUNT(*)          ,
        SUM(time_waited) time_waited
FROM    dba_hist_active_sess_history
WHERE   sample_time BETWEEN '04-DEC-12 10.00.00.000 PM' AND '04-DEC-12 11.00.00.000 PM'
GROUP BY TRUNC(sample_time),
        machine            ,
        module             ,
        event
ORDER BY 1,2,3
;