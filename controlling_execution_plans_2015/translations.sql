break on sql_id skip 1
col owner for a10
col profile_name for a10
col sql_text for a30 word_wrap
col translated_text for a30 word_wrap
col rewrite_mode for a12
col rewrite_name for a150
col rewrite_mode for a150
col source_stmt for a150
col destination_stmt for a150
select owner, profile_name, sql_text, translated_text, sql_id
from DBA_SQL_TRANSLATIONS
where owner like nvl('&owner',owner)
and profile_name like nvl('&profile_name',profile_name)
and sql_text like nvl('&sql_text',sql_text)
and translated_text like nvl('&translated_text',translated_text);
-- order by sql_text, translated_text;
clear breaks
