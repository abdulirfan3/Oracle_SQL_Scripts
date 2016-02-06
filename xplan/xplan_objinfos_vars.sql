--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

-- list of all referenced non-table objects
type all_non_tab_objects_t is table of varchar2(200)  index by varchar2(110);
m_all_non_tab_objects      all_non_tab_objects_t;
-- list of all referenced non-table objects to be skipped
m_all_non_tab_objects_skip all_non_tab_objects_t;
-- list of all objects of unknown type for which an heuristic discovery
-- has been tempted 
m_all_non_tab_objects_unk all_non_tab_objects_t;
