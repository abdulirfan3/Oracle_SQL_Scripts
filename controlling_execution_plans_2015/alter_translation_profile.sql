/*
EDITIONABLE 
FOREIGN_SQL_SYNTAX
TRANSLATION_ERROR
TRANSLATION_ERROR
TRANSLATE_NEW_SQL
TRACE_TRANSLATION
TRANSLATOR Name of the SQL translation profile attribute that specifies the translator package 
ATTR_VALUE_TRUE 
ATTR_VALUE_FALSE 
*/
exec DBMS_SQL_TRANSLATOR.SET_ATTRIBUTE('&profile_name','&attribute','&value');
