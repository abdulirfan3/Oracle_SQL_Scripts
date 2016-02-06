COLUMN shared_pool_size_for_estimate format 9,999,999 heading "Shared|Pool|Size"
COLUMN shared_pool_size_factor format 99.99 heading "Factor|Greater or|Less Than|Current|Size"
COLUMN estd_lc_time_saved format 9,999,999,999 heading "Estimated|Database|Time|If Set"
COLUMN estd_lc_time_saved_factor format 99.99 heading "Estimated|Database|Time|Saved|Factor"

--TTITLE center 'Shared Pool Sizing Advice Report' skip 2

SELECT   shared_pool_size_for_estimate, shared_pool_size_factor,
         estd_lc_time_saved, estd_lc_time_saved_factor
    FROM v$shared_pool_advice
ORDER BY shared_pool_size_for_estimate;