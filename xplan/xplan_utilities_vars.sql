--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

type print_buffer_t is table of varchar2(512 char) index by binary_integer;
m_print_buffer print_buffer_t;

m_print_buffer_enabled boolean default false;

