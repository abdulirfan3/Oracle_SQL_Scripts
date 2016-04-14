var x clob
DECLARE
content CLOB;
BEGIN
DBMS_SQL_TRANSLATOR.EXPORT_PROFILE(
profile_name => '&translation_profile_name',
content => content);
:x := content;
END;
/
select xmltype(:x) "SQLTranslationProfile" from dual;
