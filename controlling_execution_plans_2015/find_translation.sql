set serverout on
ALTER SESSION SET SQL_TRANSLATION_PROFILE = FOO;
DECLARE
translated_text CLOB;
BEGIN
DBMS_SQL_TRANSLATOR.TRANSLATE_SQL(
sql_text => '&sql_text',
translated_text => translated_text);
dbms_output.put_line('Translated text         : '||translated_text);
END;
/
set serverout off
