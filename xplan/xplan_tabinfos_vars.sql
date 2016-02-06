--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

-- map from object id to base table object id
type cache_base_table_object_id_t is table of varchar2(20) index by varchar2(20); -- binary_integer is too small for object_id
m_cache_base_table_object_id cache_base_table_object_id_t;

-- map from object id to basic obj infos
type obj_infos_t is record (
  object_type varchar2(19),
  owner       varchar2(30),
  object_name varchar2(30)
);
type cache_obj_infos_t is table of obj_infos_t index by varchar2(20); -- binary_integer is too small for object_id
m_cache_obj_infos cache_obj_infos_t;

-- map from table object id to list of lines to be printed 
type cache_table_printed_infos_t is table of print_buffer_t index by varchar2(20); -- binary_integer is too small for object_id
m_cache_table_printed_infos cache_table_printed_infos_t;

-- map from gv$sql.program_id to type/owner/objectname
type cache_program_info_t is table of varchar2(100) index by binary_integer;
m_cache_program_info cache_program_info_t;

-- map from user_id to username
type cache_username_t is table of varchar2(30) index by binary_integer;
m_cache_username cache_username_t;

-- map from username to user_id 
type cache_user_id_t is table of varchar2(30) index by varchar2(30);
m_cache_user_id cache_user_id_t;

-- list of all referenced table object ids
-- (05/02/2009, to support tabinfos='bottom')
type all_referenced_object_ids_t is table of varchar2(1)  index by varchar2(30);
m_all_referenced_object_ids all_referenced_object_ids_t;
