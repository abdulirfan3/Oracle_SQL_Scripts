--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

-----------------------------------------------------------
function mcf_fmt_with_comma(p_left_digits number, p_rite_digits number)
return varchar2
is
  l_left varchar2(50);
begin
  if :OPT_NUMBER_COMMAS = 'Y' then
    l_left := ltrim( rpad ('9', mod(p_left_digits, 3), '9') || replace (rpad ('9', 3 * trunc(p_left_digits / 3), '9') , '999', ',999'), ',');
  else
    l_left := rpad ('9', p_left_digits, '9');
  end if;
  return l_left || rtrim (rpad ('.', p_rite_digits+1, '9'), '.');
end mcf_fmt_with_comma;

-----------------------------------------------------------
procedure mcf_reset (
  p_default_execs        number, 
  p_stat_default_decimals int, 
  p_stex_default_decimals int -- if null => do not display stat/exec
)
is
  l_stat_left_digits int := 29 - p_stat_default_decimals - 1;
  l_stat_rite_digits int :=      p_stat_default_decimals;
  l_stex_left_digits int := 29 - p_stex_default_decimals - 1;
  l_stex_rite_digits int :=      p_stex_default_decimals;
begin
  mcf_m_default_execs := p_default_execs;
  -- formats
  mcf_m_stat_fmt := mcf_fmt_with_comma( l_stat_left_digits, l_stat_rite_digits );
  mcf_m_stex_fmt := null;
  if p_stex_default_decimals is not null then 
    mcf_m_stex_fmt := mcf_fmt_with_comma( l_stex_left_digits, l_stex_rite_digits );
  end if;
  -- state
  mcf_m_lines.delete;
  mcf_m_lines_out.delete;
end mcf_reset;
 
-----------------------------------------------------------
procedure mcf_add_line_char (p_name varchar2, p_stat varchar2, p_stex varchar2) 
is
  l_line mcf_t_line;
begin
  l_line.mcf_m_name      := p_name;
  l_line.mcf_m_stat      := p_stat;
  l_line.mcf_m_stex := nvl (p_stex, ' ');
  mcf_m_lines(mcf_m_lines.count) := l_line;
end mcf_add_line_char;

-----------------------------------------------------------
procedure mcf_add_line (p_name varchar2, p_stat number, p_execs number default -1)
is
  l_execs number;
begin
  -- ignore if p_stat is null
  if p_stat is null then
    return;
  end if;
  
  -- use defaults if p_execs = -1
  if p_execs = -1 then
    l_execs := mcf_m_default_execs;
  else
    l_execs := p_execs;
  end if;
  -- handle execs = 0 by suppressing output
  if l_execs = 0 then
    l_execs := null;
  end if;
  -- format and add
  mcf_add_line_char (p_name, trim(to_char (p_stat, mcf_m_stat_fmt)), trim(to_char (p_stat / l_execs, mcf_m_stex_fmt))); 
end mcf_add_line;

-----------------------------------------------------------
procedure mcf_prepare_output (p_num_columns int) 
is
  l_height number;
  l_max_name      int;
  l_max_stat      int;
  l_max_stex int;
  l_i_start int;
  l_i_stop  int;
  l_separ_line varchar2(200 char);
  l_temp varchar2(200 char);
  l_display_stex boolean default true;
begin
  mcf_m_lines_out.delete;
  
  if mcf_m_stex_fmt is null then
    l_display_stex := false;
  end if;
  
  l_height := ceil ( (mcf_m_lines.count-1) / p_num_columns); 
  
  for c in 0..p_num_columns-1 loop
    l_max_name := length (mcf_m_lines(0).mcf_m_name);
    l_max_stat := length (mcf_m_lines(0).mcf_m_stat);
    l_max_stex := length (mcf_m_lines(0).mcf_m_stex);
    l_i_start := c*l_height+1;
    l_i_stop  := least ( (c+1)*l_height, mcf_m_lines.count-1 );
    
    for i in l_i_start .. l_i_stop loop
      if length (mcf_m_lines(i).mcf_m_name) > l_max_name then l_max_name := length (mcf_m_lines(i).mcf_m_name); end if;
      if length (mcf_m_lines(i).mcf_m_stat) > l_max_stat then l_max_stat := length (mcf_m_lines(i).mcf_m_stat); end if;
      if length (mcf_m_lines(i).mcf_m_stex) > l_max_stex then l_max_stex := length (mcf_m_lines(i).mcf_m_stex); end if;
    end loop;
    
    l_separ_line := '-' || rpad ('-', l_max_name+2, '-')
                        || rpad ('-', l_max_stat+2, '-');
    if l_display_stex then                     
      l_separ_line := l_separ_line || rpad ('-', l_max_stex+2, '-');
    end if;
    
    mcf_m_lines_out(mcf_m_lines_out.count) := l_separ_line;
    l_temp := '|'      || rpad (mcf_m_lines(0).mcf_m_name, l_max_name, ' ') || ' |'
                       || rpad (mcf_m_lines(0).mcf_m_stat, l_max_stat, ' ') || ' |';
    if l_display_stex then
      l_temp := l_temp || rpad (mcf_m_lines(0).mcf_m_stex, l_max_stex, ' ') || ' |';
    end if;
    mcf_m_lines_out(mcf_m_lines_out.count) := l_temp;                                      
    mcf_m_lines_out(mcf_m_lines_out.count) := l_separ_line;
    for i in l_i_start .. l_i_stop loop
      l_temp := '|'      || rpad (mcf_m_lines(i).mcf_m_name, l_max_name, ' ') || ' |'
                         || lpad (mcf_m_lines(i).mcf_m_stat, l_max_stat, ' ') || ' |';
      if l_display_stex then
        l_temp := l_temp || lpad (mcf_m_lines(i).mcf_m_stex, l_max_stex, ' ') || ' |';
      end if;
      mcf_m_lines_out(mcf_m_lines_out.count) := l_temp;
    end loop;
    mcf_m_lines_out(mcf_m_lines_out.count) := l_separ_line;
  end loop;
  
  --for i in 0..mcf_m_lines_out.count-1 loop
  --  dbms_output.put_line (mcf_m_lines_out(i)|| ' | ');
  --end loop;
 
  mcf_m_output_height := l_height + 4;
end mcf_prepare_output;

-----------------------------------------------------------
function mcf_next_output_line
return varchar2
is
  l_out varchar2(200 char);
  i int;
begin
  if mcf_m_lines_out.count = 0 then
    return null;
  end if;
  i := mcf_m_lines_out.first;
  loop
     l_out := l_out || mcf_m_lines_out(i);
     mcf_m_lines_out.delete (i);
     i := i + mcf_m_output_height;
     exit when not mcf_m_lines_out.exists(i);
     l_out := l_out || ' ';
  end loop;
  return l_out;
end mcf_next_output_line;
  
-----------------------------------------------------------
procedure mcf_test 
is
  l_out varchar2(200 char);
begin
  mcf_reset (p_default_execs => 10, p_stat_default_decimals => 0, p_stex_default_decimals => 1);
  mcf_add_line_char ('gv$sql statname', 'total', 'total/exec');
  mcf_add_line ('s0', 0, null);
  mcf_add_line ('s1____________________', 1);
  mcf_add_line ('s2', 2, 10);
  mcf_add_line ('s3______________', 3, 10);
  mcf_add_line ('s4', 4, 10);
  mcf_prepare_output (p_num_columns => 2);
  loop
    l_out := mcf_next_output_line;
    exit when l_out is null;
    dbms_output.put_line (l_out);
  end loop;
end mcf_test;

-----------------------------------------------------------
procedure mcf_n_reset 
is
begin
  mcf_m_n_lines.delete;
  mcf_m_n_lines_out.delete;
end mcf_n_reset;

-----------------------------------------------------------
procedure mcf_n_add_line (c1  varchar2 default null, c2  varchar2 default null, c3  varchar2 default null,
                      c4  varchar2 default null, c5  varchar2 default null, c6  varchar2 default null,
                      c7  varchar2 default null, c8  varchar2 default null, c9  varchar2 default null,
                      c10 varchar2 default null, c11 varchar2 default null, c12 varchar2 default null)
is
  l_line mcf_t_n_line;
begin
  l_line(1)  := c1;  l_line(2)  := c2;  l_line(3) := c3;
  l_line(4)  := c4;  l_line(5)  := c5;  l_line(6) := c6;
  l_line(7)  := c7;  l_line(8)  := c8;  l_line(9) := c9;
  l_line(10) := c10; l_line(11) := c11; l_line(12) := c12;
  mcf_m_n_lines (mcf_m_n_lines.count) := l_line;
end mcf_n_add_line;

-----------------------------------------------------------
procedure mcf_n_prepare_output (c1_align  varchar2 default 'right', c2_align  varchar2 default 'right', c3_align  varchar2 default 'right',
                            c4_align  varchar2 default 'right', c5_align  varchar2 default 'right', c6_align  varchar2 default 'right',
                            c7_align  varchar2 default 'right', c8_align  varchar2 default 'right', c9_align  varchar2 default 'right',
                            c10_align varchar2 default 'right', c11_align varchar2 default 'right', c12_align varchar2 default 'right',
                            p_separator varchar2 default ' ')
is
  type mcf_t_lengths is table of int index by binary_integer;
  type mcf_t_aligns  is table of varchar2(5) index by binary_integer;
  l_lengths mcf_t_lengths;
  l_aligns  mcf_t_aligns;
  l_line    varchar2(300 char);
begin
  mcf_m_n_lines_out.delete;
  
  if mcf_m_n_lines.count = 0 then
    return;
  end if;
  
  -- get max columns lengths
  for i in mcf_m_n_lines.first .. mcf_m_n_lines.last loop
    for j in mcf_m_n_lines(i).first .. mcf_m_n_lines(i).last loop
      if not l_lengths.exists(j) then
        l_lengths(j) := 0;
      end if;
      l_lengths(j) := greatest (l_lengths(j), nvl( length (mcf_m_n_lines(i)(j)) , 0)  );
    end loop;
  end loop;
  
  l_aligns(1)  := lower ( c1_align); l_aligns(2)  := lower ( c2_align); l_aligns(3)  := lower ( c3_align);
  l_aligns(4)  := lower ( c4_align); l_aligns(5)  := lower ( c5_align); l_aligns(6)  := lower ( c6_align);
  l_aligns(7)  := lower ( c7_align); l_aligns(8)  := lower ( c8_align); l_aligns(9)  := lower ( c9_align);
  l_aligns(10) := lower (c10_align); l_aligns(11) := lower (c11_align); l_aligns(12) := lower (c12_align);
  
  for i in mcf_m_n_lines.first .. mcf_m_n_lines.last loop
    l_line := '';
    for j in mcf_m_n_lines(i).first .. mcf_m_n_lines(i).last loop
      if l_lengths(j) > 0 then 
        l_line := l_line || case when l_aligns(j) = 'right' 
                                 then lpad ( nvl(mcf_m_n_lines(i)(j), ' '), l_lengths(j) )
                                 else rpad ( nvl(mcf_m_n_lines(i)(j), ' '), l_lengths(j) )
                            end
                         || p_separator;
      end if;
    end loop;
    mcf_m_n_lines_out (mcf_m_n_lines_out.count) := substr (l_line, 1, length (l_line) - length (p_separator));
  end loop;
end mcf_n_prepare_output;

-----------------------------------------------------------
function mcf_n_next_output_line 
return varchar2
is
  l_out varchar2 (300 char);
begin
  if mcf_m_n_lines_out.count = 0 then
    return null;
  end if;
  l_out := mcf_m_n_lines_out (mcf_m_n_lines_out.first);
  mcf_m_n_lines_out.delete   (mcf_m_n_lines_out.first);
  return l_out;
end mcf_n_next_output_line;

-----------------------------------------------------------
procedure mcf_n_test
is
  l_out varchar2 (300 char);
begin
  mcf_n_reset;
  mcf_n_add_line ('uno', 'due', null, 'quattro');
  mcf_n_add_line ('1', '2', null, 4);
  mcf_n_prepare_output (c2_align => 'left', p_separator => '|');
  loop
    l_out := mcf_n_next_output_line;
    exit when l_out is null;
    dbms_output.put_line ('"'||l_out||'"');
  end loop;
end mcf_n_test;

