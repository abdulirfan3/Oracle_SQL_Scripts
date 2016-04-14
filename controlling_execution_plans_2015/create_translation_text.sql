----------------------------------------------------------------------------------------
--
-- File name:   create_translation_text.sql
--
-- Purpose:     Create (actually Register) SQL Translation.
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for 3 values.
--
--              translation_profile: the name of the translation profile to register with
--
--              sql_text: the original sql text that is to be replaced 
--
--              sql_text2: the replacement text 
--
-- Description: 
--
--              This script allows a statements text to be replaced on the fly. It's based 
--              on the dbms_sql_translator functionality added in DB 12.1 that was originally
--              written to be part of SQL Developer. The intent of dbms_sql_translate was to 
--              translate SQL generate by aps written for other RDBMS's to Oracle specific 
--              syntax (Sybase to Oracle for example).
--
--              Note: this is a first cut that only allows text
--
--              See create_translation.sql for a version that uses sql_id
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
--



accept trans_profile -
       prompt 'Enter value for sql_translation_profile (FOO): ' -
       default 'FOO'
accept sql_text -
       prompt 'Enter value for sql_text_to_replace (null): ' -
       default 'X0X0X0X0'
accept sql_text2 -
       prompt 'Enter value for translated sql_text (null): ' -
       default 'X0X0X0X0'

exec dbms_sql_translator.register_sql_translation('&&trans_profile',q'[&&sql_text]',q'[&&sql_text2]');
undef trans_profile
undef sql_text
undef sql_text2

