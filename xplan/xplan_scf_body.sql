--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008-2012 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

procedure scf_init_state_for (
  p_state       in out nocopy scf_state_t,
  p_colname     varchar2,
  p_is_auxil    varchar2,
  p_is_hidden   varchar2,
  p_sep_top     varchar2,
  p_sep_mid     varchar2,
  p_sep_bot     varchar2,
  p_is_number   varchar2,
  p_self_src    varchar2,
  p_self_is_id  varchar2,
  p_self_is_pid varchar2
)
is
begin
  if not p_state.col_name_to_pos.exists (p_colname) then
    declare 
      l_col_state scf_col_state_t;
      l_col_pos int;
    begin
      if p_is_auxil not in ('Y', 'N') or p_is_auxil is null then
        raise_application_error (-20001, ' illegal p_is_auxil='||p_is_auxil);
      end if;
      if p_is_hidden not in ('Y', 'N') or p_is_hidden is null then
        raise_application_error (-20002, ' illegal p_is_hidden='||p_is_hidden);
      end if;
      if p_self_is_id not in ('Y', 'N') or p_self_is_id is null then
        raise_application_error (-20003, ' illegal p_self_is_id='||p_self_is_id);
      end if;
      if p_self_is_pid not in ('Y', 'N') or p_self_is_pid is null then
        raise_application_error (-20004, ' illegal p_self_is_pid='||p_self_is_pid);
      end if;
      l_col_pos := p_state.numcols;
      p_state.col_name_to_pos (p_colname) := l_col_pos;
      l_col_state.is_auxil  := p_is_auxil;
      l_col_state.is_hidden := p_is_hidden;
      l_col_state.sep_top   := p_sep_top;
      l_col_state.colname   := p_colname;
      l_col_state.sep_mid   := p_sep_mid;
      l_col_state.sep_bot   := p_sep_bot;
      l_col_state.is_number := p_is_number; 
      l_col_state.self_src  := p_self_src;
      p_state.cols(l_col_pos) := l_col_state;
      if p_self_is_id = 'Y' then
        p_state.self_col_pos_id := l_col_pos;
      end if;
      if p_self_is_pid = 'Y' then
        p_state.self_col_pos_pid := l_col_pos;
      end if;
      p_state.numcols := p_state.numcols + 1;
    end;
  end if;
end scf_init_state_for;

-- overloaded on "p_rowval"
procedure scf_add_elem (
  p_state     in out nocopy scf_state_t,
  p_colname   varchar2,
  p_rowval    varchar2,
  p_is_auxil  varchar2 default 'N',
  p_is_hidden varchar2 default 'N',
  p_sep_top   varchar2 default null,
  p_sep_mid   varchar2 default null,
  p_sep_bot   varchar2 default null
)
is 
  l_col_pos int;
begin
  scf_init_state_for (p_state, p_colname, p_is_auxil, p_is_hidden, p_sep_top, p_sep_mid, p_sep_bot, 'N', null, 'N' /* string cannot be id */, 'N' );
  l_col_pos := p_state.col_name_to_pos (p_colname);
  p_state.cols(l_col_pos).rows_v( p_state.cols(l_col_pos).rows_v.count ) := rtrim (p_rowval);
end scf_add_elem;

procedure scf_add_elem (
  p_state       in out nocopy scf_state_t,
  p_colname     varchar2,
  p_rowval      number,
  p_is_auxil    varchar2 default 'N',
  p_is_hidden   varchar2 default 'N',
  p_sep_top     varchar2 default null,
  p_sep_mid     varchar2 default null,                       
  p_sep_bot     varchar2 default null,
  p_self_is_id  varchar2 default 'N',
  p_self_is_pid varchar2 default 'N'
)
is 
  l_col_pos int;
begin
  scf_init_state_for (p_state, p_colname, p_is_auxil, p_is_hidden, p_sep_top, p_sep_mid, p_sep_bot, 'Y', null, p_self_is_id, p_self_is_pid);
  l_col_pos := p_state.col_name_to_pos (p_colname);
  p_state.cols(l_col_pos).rows_n( p_state.cols(l_col_pos).rows_n.count ) := p_rowval;
end scf_add_elem;

procedure scf_add_self (
  p_state       in out nocopy scf_state_t,
  p_colname     varchar2,
  p_self_src    varchar2 default null
)
is 
  l_col_pos int;
  l_col_state_src scf_col_state_t;
begin
  -- copy info from src column
  l_col_state_src := p_state.cols ( p_state.col_name_to_pos (p_self_src) );
  scf_init_state_for (p_state, p_colname, 'Y', 'N', l_col_state_src.sep_top, l_col_state_src.sep_mid, l_col_state_src.sep_bot, 'Y', p_self_src, 'N', 'N');
  -- set row to null
  l_col_pos := p_state.col_name_to_pos (p_colname);
  p_state.cols(l_col_pos).rows_n( p_state.cols(l_col_pos).rows_n.count ) := to_number(null);
end scf_add_self;

procedure scf_prepare_output (p_state in out nocopy scf_state_t)
is
  l_num_rows int;
  l_number_fmt varchar2(40 char) := 'FM9,999,999,999,999,999,999,999,990'; 
begin
  p_state.numcols_not_empty         := 0;
  p_state.num_notaux_cols_not_empty := 0;
  
  if p_state.numcols = 0 then        
    return;
  end if;
  
  -- adapt number format
  if :OPT_NUMBER_COMMAS = 'N' then
    l_number_fmt := replace(l_number_fmt, ',', '');
  end if;
  
  -- set l_num_rows
  if p_state.cols(0).is_number = 'Y' then
    l_num_rows := p_state.cols(0).rows_n.count;
  else
    l_num_rows := p_state.cols(0).rows_v.count;
  end if;
  
  -- sanity check: check that all cols have the same number of rows
  declare
    l_num_rows_curr int;
  begin
    for c in 1 .. p_state.cols.count-1 loop
      if p_state.cols(c).is_number = 'Y' then
        l_num_rows_curr := p_state.cols(c).rows_n.count;
      else
        l_num_rows_curr := p_state.cols(c).rows_v.count;
      end if;
      if l_num_rows_curr != l_num_rows then
        raise_application_error (-20001, 'num rows of first column "'||p_state.cols(0).colname
           ||'" and column "'||p_state.cols(c).colname||'" differ.');
      end if;
    end loop;
  end;
  
  -- calc self columns
  for c in 0 .. p_state.cols.count-1 loop
    if p_state.cols(c).self_src is not null then
      declare 
        l_pos_src int := p_state.col_name_to_pos (p_state.cols(c).self_src);
        l_pid number;
        l_p_row number;
        l_is_empty varchar2(1) := 'Y';
      begin
        -- build self global structures if not built yet
        if p_state.self_id_to_row.count = 0 then
          for r in 0 .. l_num_rows-1 loop
            p_state.self_id_to_row( p_state.cols(p_state.self_col_pos_id).rows_n(r) ) := r;
            p_state.self_pid_is_leaf(r) := 'Y';
          end loop;
          for r in 0 .. l_num_rows-1 loop
            l_pid := p_state.cols(p_state.self_col_pos_pid).rows_n(r);
             if l_pid is not null then
               p_state.self_pid_is_leaf( p_state.self_id_to_row( l_pid ) ) := 'N';
             end if;
          end loop;
        end if;
      
        -- copy source value, check if col is completely empty
        for r in 0 .. l_num_rows-1 loop
          p_state.cols(c).rows_n(r) := p_state.cols(l_pos_src).rows_n(r); 
          if l_is_empty = 'Y' and p_state.cols(c).rows_n(r) != 0 then
            l_is_empty := 'N';
          end if;
        end loop;
        
        if l_is_empty = 'N' then        
          -- subtract value from parent
          for r in 0 .. l_num_rows-1 loop
            l_pid := p_state.cols(p_state.self_col_pos_pid).rows_n(r);
            if l_pid is not null then
              l_p_row := p_state.self_id_to_row( l_pid );
              p_state.cols(c).rows_n(l_p_row) := p_state.cols(c).rows_n(l_p_row) 
                - p_state.cols(l_pos_src).rows_n( r ); 
            end if;
          end loop;
        else
          -- set all rows to null
          for r in 0 .. l_num_rows-1 loop
            p_state.cols(c).rows_n(r) := to_number(null);
          end loop;
        end if;
      end;
    end if;
  end loop;
  
  -- format number; remove useless decimal parts
  for c in 0 .. p_state.cols.count-1 loop
    if p_state.cols(c).is_number = 'Y' then
      declare 
        l_fmt varchar2(40 char) := l_number_fmt;
        l_var varchar2(40 char);
      begin
        -- add leading sign if self column
        if p_state.cols(c).self_src is not null then
          l_fmt := 'S' || l_fmt;
        end if;
        
        -- change format if number has a decimal part
        for r in 0 .. l_num_rows-1 loop
          if p_state.cols(c).rows_n(r) != trunc( p_state.cols(c).rows_n(r) ) 
          then
            l_fmt := l_fmt || '.0';
            exit;
          end if;
        end loop;
        
        for r in 0 .. l_num_rows-1 loop
          l_var := to_char( round(p_state.cols(c).rows_n(r), 1) , l_fmt) ;
          -- special display for self column
          if p_state.cols(c).self_src is not null then 
            if p_state.self_pid_is_leaf(r) = 'Y' then
              l_var := replace( l_var, '+', null );
            else
              if l_var = '+0' then
                l_var := '=';
              end if;
            end if;
          end if;
          p_state.cols(c).rows_v(r) := l_var;
        end loop;
      end;
    end if;
  end loop;

  
  for c in 0 .. p_state.cols.count-1 loop
    declare
      l_curr_max_length int := 0;
    begin
      -- calc max row length (set to zero for hidden columns)
      if p_state.cols(c).is_hidden = 'Y' then
        l_curr_max_length := 0;
      else
        for r in 0 .. l_num_rows-1 loop
          declare
            l_curr_row_lenght int := nvl(length (p_state.cols(c).rows_v(r)), 0);
          begin
            if l_curr_row_lenght > l_curr_max_length then
              l_curr_max_length := l_curr_row_lenght;
            end if;
          end;
        end loop;
      end if;
      -- set all column rows to '' if no info is contained
      if l_curr_max_length = 0 then
        --print ('col #'||c||' is empty');
        p_state.cols(c).sep_top := '';
        p_state.cols(c).colname := '';
        p_state.cols(c).sep_mid := '';
        p_state.cols(c).sep_bot := '';
      else
        p_state.numcols_not_empty := p_state.numcols_not_empty + 1;
        -- this is calc in order to ignore auxiliary columns (such as 'Id')
        if p_state.cols(c).is_auxil = 'N' then 
          p_state.num_notaux_cols_not_empty := p_state.num_notaux_cols_not_empty + 1;
        end if;
      end if;
      -- calc max row length, separators and colname included
      l_curr_max_length := greatest (
        nvl (length (p_state.cols(c).sep_top), 0),
        nvl (length (p_state.cols(c).colname), 0),
        nvl (length (p_state.cols(c).sep_mid), 0),
        nvl (length (p_state.cols(c).sep_bot), 0),
        l_curr_max_length
      );
      
      --print ('col #'||c||' max length='||l_curr_max_length);
      -- set separators, colname and rows to same (max) length
      p_state.cols(c).sep_top := rpad ( nvl(p_state.cols(c).sep_top, '-'), l_curr_max_length, '-');  
      p_state.cols(c).colname := rpad ( nvl(p_state.cols(c).colname, ' '), l_curr_max_length, ' '); 
      p_state.cols(c).sep_mid := rpad ( nvl(p_state.cols(c).sep_mid, '-'), l_curr_max_length, '-');
      p_state.cols(c).sep_bot := rpad ( nvl(p_state.cols(c).sep_bot, '-'), l_curr_max_length, '-');
      for r in 0 .. l_num_rows-1 loop
        declare
          l_curr_row_lenght int := length (p_state.cols(c).rows_v(r));
        begin
          if p_state.cols(c).is_number = 'Y' then
            p_state.cols(c).rows_v(r) := lpad ( nvl(p_state.cols(c).rows_v(r), ' '), l_curr_max_length, ' ');
          else
            p_state.cols(c).rows_v(r) := rpad ( nvl(p_state.cols(c).rows_v(r), ' '), l_curr_max_length, ' ');
          end if;
          --print ('"'||p_state.cols(c).rows_v(r)||'"');
        end;
      end loop;
    end;
  end loop;

end scf_prepare_output;

procedure scf_print_output (
  p_state               in out nocopy scf_state_t,
  p_no_info_msg         varchar2,
  p_no_not_aux_info_msg varchar2,
  p_note                varchar2 default null)
is
  l_line varchar2(1000 char);
begin
  scf_prepare_output (p_state);
  
  if p_state.numcols_not_empty = 0 then
    print (p_no_info_msg);
    return;
  end if;
  
  if p_state.num_notaux_cols_not_empty = 0 then
    print (p_no_not_aux_info_msg);
    return;
  end if;
  
  -- print top separator
  l_line := '-';
  for c in 0 .. p_state.cols.count-1 loop
    if p_state.cols(c).sep_top is not null then
      l_line := l_line || p_state.cols(c).sep_top || '-';
    end if;
  end loop;
  print (l_line);
  
  -- print colnames
  l_line := '|';
  for c in 0 .. p_state.cols.count-1 loop
    if p_state.cols(c).colname is not null then
      l_line := l_line || p_state.cols(c).colname || '|';
    end if;
  end loop;
  print (l_line);
  
  -- print middle separator
  l_line := '-';
  for c in 0 .. p_state.cols.count-1 loop
    if p_state.cols(c).sep_mid is not null then
      l_line := l_line || p_state.cols(c).sep_mid || '-';
    end if;
  end loop;
  print (l_line);
  
  -- print rows
  for r in 0 .. p_state.cols(0).rows_v.count-1 loop
    l_line := '|';
    for c in 0 .. p_state.cols.count-1 loop
      if p_state.cols(c).rows_v(r) is not null then
        l_line := l_line || p_state.cols(c).rows_v(r) || '|';
      end if;
    end loop;
    print (l_line);
  end loop;
  
  -- print bottom separator
  l_line := '-';
  for c in 0 .. p_state.cols.count-1 loop
    if p_state.cols(c).sep_bot is not null then
      l_line := l_line || p_state.cols(c).sep_bot || '-';
    end if;
  end loop;
  print (l_line);
  
  if trim(p_note) is not null then
    print (p_note);
  end if;
  
end scf_print_output;

procedure scf_reset (p_state out scf_state_t)
is
  l_state scf_state_t;
begin
  p_state := l_state;
end scf_reset;

procedure scf_test 
is
  l_plan scf_state_t;
begin
  scf_add_elem (l_plan, 'id', 1, 'top', 'middle', 'bottom');
  scf_add_elem (l_plan, 'Operation', 'TABLE ACCESS BY INDEX ROWID','','middle_op');
  scf_add_elem (l_plan, 'id', 2.11);     
  scf_add_elem (l_plan, 'Operation', 'INDEX RANGE SCAN');
  scf_add_elem (l_plan, 'id', to_number(null));
  scf_add_elem (l_plan, 'Operation', '');
  
  scf_print_output (l_plan, 'no plan found.', 'only aux plan infos found.');
end scf_test;

