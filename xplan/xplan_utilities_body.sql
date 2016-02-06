--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008, 2009 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

-----------------------------------------------------------
-- enables or disables buffer redirection to internal buffer.
-- In both cases, clears the buffer.
procedure enable_print_buffer (p_enable_or_disable varchar2 default 'ENABLE')
is
begin
  m_print_buffer.delete;
  if p_enable_or_disable = 'ENABLE' then 
    m_print_buffer_enabled := true;
  elsif p_enable_or_disable = 'DISABLE' then
    m_print_buffer_enabled := false;
  else
    raise_application_error (-20001, 'enable_print_buffer: p_enable_or_disable is not ENABLE or DISABLE.');
  end if;
end enable_print_buffer;

-----------------------------------------------------------
-- prints to dbms_output.put_line or to internal buffer
-- if requested
procedure print_or_buffer (p_line varchar2)
is
begin
  if m_print_buffer_enabled then
     m_print_buffer(m_print_buffer.count) := p_line;
  else
     dbms_output.put_line (p_line);
  end if;
end print_or_buffer;

-----------------------------------------------------------
-- transforms a statement into lines (with maxsize)
-- It's a pretty-printer as well. 
procedure print_stmt_lines (p_text varchar2)
--create or replace procedure str2lines (p_text varchar2)
is
  l_text        long   default rtrim(p_text);
  l_text_length number default length(l_text);
  l_pos         int    default 1;
  l_chunk_size  int    default &LINE_SIZE.;
  l_curr        varchar2(400);
  l_last        int;
begin
  &COMM_IF_GT_10G. if l_chunk_size > 255 then l_chunk_size := 255-5; end if;
   
  loop
    l_curr := substr (l_text, l_pos, l_chunk_size);
    exit when l_curr is null;
    
    -- chop at the FIRST newline, if any
    l_last := instr (l_curr, chr(10));
    -- if not, chop at the last pos if shorter than chunksize
    if l_last <= 0 and length(l_curr) < l_chunk_size then
      l_last := l_chunk_size;
    end if;
    -- if not, chop at the LAST blank, if any
    if l_last <= 0 then 
      l_last := instr (l_curr, ' ', -1);
    end if;
    -- if not, chop BEFORE an operator or separator
    if l_last <= 0 then 
      l_last := -1 + greatest (instr (l_curr      , '<=', -1), 
                               instr (l_curr      , '>=', -1),
                               instr (l_curr      , '<>', -1),
                               instr (l_curr      , '!=', -1),
                               instr (l_curr      , ':=', -1),
                               instr (l_curr      , '=' , -1), 
                               instr (l_curr      , '<' , -1),
                               instr (l_curr      , '>' , -1),
                               instr (l_curr      , ',' , -1),
                               instr (l_curr      , ';' , -1),
                               instr (l_curr      , '+' , -1),
                               instr (l_curr      , '-' , -1),
                               instr (l_curr      , '*' , -1),
                               instr (l_curr      , '/' , -1),
                               instr (l_curr      , '(' , -1),
                               instr (l_curr      , '/*', -1)
                               );
      -- handle clash of '=' and '<=', '>=','!=' or ':='; of '*' and '/*'
      if l_last > 2 and substr (l_curr, l_last, 2) in ('<=','>=','<>','!=','/*') then
        l_last := l_last-1;
      end if;              
    end if;
    -- last resort: don't chop
    if l_last <= 0 then
       l_last := l_chunk_size;
    end if;
    
    -- print (or buffer) line
    print_or_buffer ( rtrim ( substr (l_curr, 1, l_last), chr(10) ));
   
    -- advance current position
    l_pos := l_pos + l_last;
    exit when l_pos > l_text_length;
  end loop;

end print_stmt_lines;

-----------------------------------------------------------
-- print a line, breaking it if necessary
procedure print (p_text varchar2)
is
begin
  print_stmt_lines (p_text);
end print;

-----------------------------------------------------------
-- print a long (coming from a query) using print()
-- adapted from Tom's showlong: http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:665224430110
procedure print_long ( 
  p_query        varchar2,
  p_bind_1_name  varchar2,
  p_bind_1_value varchar2,
  p_bind_2_name  varchar2,
  p_bind_2_value varchar2)
as
    l_cursor    integer default dbms_sql.open_cursor;
    l_n         number;
    l_long_val  varchar2(32000);
    l_long_len  number;
    l_buflen    number := 32000;
    l_curpos    number := 0;
begin
    dbms_sql.parse( l_cursor, p_query, dbms_sql.native );
    dbms_sql.bind_variable( l_cursor, p_bind_1_name, p_bind_1_value );
    dbms_sql.bind_variable( l_cursor, p_bind_2_name, p_bind_2_value );

    dbms_sql.define_column_long(l_cursor, 1);
    l_n := dbms_sql.execute(l_cursor);

    if (dbms_sql.fetch_rows(l_cursor)>0)
    then
        loop
            dbms_sql.column_value_long(l_cursor, 1, l_buflen, 
                                       l_curpos , l_long_val,
                                       l_long_len );
            l_curpos := l_curpos + l_long_len;
            print ( l_long_val );
            exit when l_long_len = 0;
      end loop;
   end if;
   dbms_sql.close_cursor(l_cursor);
exception
   when others then
      if dbms_sql.is_open(l_cursor) then
         dbms_sql.close_cursor(l_cursor);
      end if;
      raise;
end print_long;

-----------------------------------------------------------
-- print a CLOB
procedure print_clob( p_clob clob)
is
  l_buffer long;
  l_amount binary_integer;
  l_offset int;
begin
  l_amount := 32767;
  l_offset := 1;
  loop
    dbms_lob.read( p_clob, l_amount, l_offset, l_buffer );
    print( l_buffer );
    exit when l_amount < 32767;
    l_offset := l_offset + l_amount;
  end loop;
exception 
  when no_data_found then
    null;
end print_clob;

-----------------------------------------------------------
function d2s (p_date date) return varchar2 
is
begin
  return to_char (p_date, 'yyyy/mm/dd hh24:mi:ss');
end d2s;

-----------------------------------------------------------
-- check whether the argument is an integer
function is_integer (p_s varchar2)
return boolean
is
begin
  return trim ( translate (p_s, '0123456789', '          ') ) is null;
end is_integer;

