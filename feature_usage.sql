select name, version, detected_usages, total_samples, currently_used as "used", first_usage_date, last_usage_date, description 
from DBA_FEATURE_USAGE_STATISTICs
order by name asc;