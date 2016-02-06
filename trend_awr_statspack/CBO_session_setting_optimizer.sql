select name, value
from  v$SES_OPTIMIZER_ENV
where SID = '&SID';