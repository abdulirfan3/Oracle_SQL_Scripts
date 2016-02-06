--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009, 2012 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

type scf_array_of_varchar2_t       is table of varchar2(1000 char) index by binary_integer;
type scf_array_of_number_t         is table of number             index by binary_integer;
type scf_hash_of_varchar2_to_num_t is table of number             index by varchar2(30);

type scf_col_state_t is record (
  sep_top    varchar2(1000 char), -- separator: top
  colname    varchar2(1000 char), -- column name
  is_auxil   varchar2(1   char), -- Y=is auxiliary (print nothing if all non-auxiliary are empty)
  is_hidden  varchar2(1   char), -- Y=is hidden
  sep_mid    varchar2(1000 char), -- separator: middle
  sep_bot    varchar2(1000 char), -- separator: bottom
  is_number  varchar2(1   char), -- Y=is number
  self_src   varchar2(1000 char), -- null if not self column; otherwise name of source column 
  rows_v     scf_array_of_varchar2_t, -- row values - varchar2
  rows_n     scf_array_of_number_t    -- row values - number
);

type scf_array_of_col_state_t is table of scf_col_state_t index by binary_integer;

type scf_state_t is record (
  numcols                   int := 0,
  numcols_not_empty         int := null,
  num_notaux_cols_not_empty int := null,
  col_name_to_pos           scf_hash_of_varchar2_to_num_t,
  cols                      scf_array_of_col_state_t, 
  self_col_pos_id           int := null,
  self_col_pos_pid          int := null,
  self_id_to_row            scf_array_of_number_t,
  self_pid_is_leaf          scf_array_of_varchar2_t
);


