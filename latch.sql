SELECT   SUBSTR (NAME, 1, 25) "Latch", immediate_gets "Igets",
         immediate_misses "Imisses",
            ROUND ((  immediate_misses
                    / (immediate_gets + immediate_misses)
                    * 100
                   ),
                   0
                  )
         || '%' miss_ratio
    FROM v$latch
   WHERE immediate_gets != 0
order by 4 desc;