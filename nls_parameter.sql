COLUMN parameter FORMAT A45
COLUMN value FORMAT A45

PROMPT ***************************
PROMPT *** Database parameters ***
PROMPT ***************************
SELECT * FROM nls_database_parameters;

PROMPT
PROMPT
PROMPT ***************************
PROMPT *** Instance parameters ***
PROMPT ***************************
SELECT * FROM nls_instance_parameters;

PROMPT
PROMPT
PROMPT ***************************
PROMPT *** Session parameters ***
PROMPT ***************************
SELECT * FROM nls_session_parameters;


PROMPT
PROMPT
PROMPT *****************************************
PROMPT *** Same info as above just diff view ***
PROMPT *****************************************

@@nls_parameters2