--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

type mcf_t_line         is record (mcf_m_name varchar2(40), mcf_m_stat varchar2(40), mcf_m_stex varchar2(40));
type mcf_t_line_arr     is table of mcf_t_line index by binary_integer;
type mcf_t_output_array is table of varchar2(150) index by binary_integer;

type mcf_t_n_line         is table of varchar2(150) index by binary_integer;
type mcf_t_n_line_arr     is table of mcf_t_n_line index by binary_integer;
type mcf_t_n_output_array is table of varchar2(300) index by binary_integer;

mcf_m_default_execs         number;

mcf_m_stat_fmt varchar2(50);
mcf_m_stex_fmt varchar2(50);

mcf_m_lines         mcf_t_line_arr;
mcf_m_lines_out     mcf_t_output_array;
mcf_m_output_height int;

mcf_m_n_lines     mcf_t_n_line_arr;
mcf_m_n_lines_out mcf_t_n_output_array;

