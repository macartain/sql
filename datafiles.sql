accept x_tspace prompt "Like tablespace : "

declare
  cursor c_t_spaces is
    select *
    from dba_tablespaces
    where tablespace_name like upper( '%' || '&x_tspace' || '%' )
    order by tablespace_name;

  cursor c_d_files ( x_t_space in dba_data_files.tablespace_name%type ) is
    select *
    from dba_data_files
    where tablespace_name = x_t_space
    order by file_id;

  cursor c_f_space ( x_file_id in dba_free_space.file_id%type ) is
    select nvl( sum( bytes ), 0 )
    from dba_free_space
    where file_id = x_file_id;
  ln_free_space number;

  ls_out_string varchar2( 255 );
  ls_t_space_string varchar2( 255 );
  ls_full_file_name varchar2( 255 );
  li_fname_len integer := 40;

  ln_total_bytes number := 0;
  ln_total_free  number := 0;

begin

  for i_c_t_spaces in c_t_spaces loop
    ls_t_space_string :=  'TABLESPACE : ' || i_c_t_spaces.tablespace_name || ' ' ||
                          '( ' || i_c_t_spaces.contents || ', '  ||
                          i_c_t_spaces.status || ')';
    dbms_output.put_line( ls_t_space_string );
    dbms_output.put_line( rpad( '-', length( ls_t_space_string ), '-' ) );

    dbms_output.put_line( '  Id' || ' ' ||
                          rpad( 'File Name', li_fname_len ) || ' ' ||
                          rpad( 'Status', 9 ) || ' ' ||
                          '    Size (M)' || ' ' ||
                          '    Free (M)' || ' ' ||
                          ' Auto' || ' ' ||
                          'Full File Name (if relevant)' );
    dbms_output.put_line( '  --' || ' ' ||
                          rpad( '---------', li_fname_len ) || ' ' ||
                          rpad( '------', 9 ) || ' ' ||
                          '    --------' || ' ' ||
                          '    --------' || ' ' ||
                          ' ----' || ' ' ||
                          '---------------------------' );



    ls_out_string := rpad( i_c_t_spaces.tablespace_name, 30 ) || ' ';

    for i_c_d_files in c_d_files( i_c_t_spaces.tablespace_name ) loop
      ln_free_space := 0;
      open c_f_space( i_c_d_files.file_id );
      fetch c_f_space into ln_free_space;
      close c_f_space;

      if length( i_c_d_files.file_name ) >= li_fname_len then
        ls_full_file_name := i_c_d_files.file_name;
      else
        ls_full_file_name := '';
      end if;

      dbms_output.put_line( to_char( i_c_d_files.file_id, '999' ) || ' ' ||
                            rpad( substr( i_c_d_files.file_name,
                                  greatest( length( i_c_d_files.file_name ) - li_fname_len + 1, 1 ) ), li_fname_len )  || ' ' ||
                            rpad( i_c_d_files.status, 9 ) || ' ' ||
                            to_char( ( i_c_d_files.bytes / ( 1024 * 1024 ) ), '999,999,999' ) || ' ' ||
                            to_char( ( ln_free_space / ( 1024 * 1024 ) ), '999,999,999' ) || ' ' ||
                            '  ' || rpad( i_c_d_files.autoextensible, 3 ) || ' ' ||
                            ls_full_file_name );


      ln_total_bytes := ln_total_bytes + i_c_d_files.bytes;
      ln_total_free := ln_total_free + ln_free_space;

    end loop;

    dbms_output.put_line( chr(10) );

  end loop;

  dbms_output.put_line( 'Total allocated : ' || to_char( ln_total_bytes / ( 1024 * 1024 ), '999,999,999,999' ) || ' MB' );
  dbms_output.put_line( 'Total free      : ' || to_char( ln_total_free / ( 1024 * 1024 ), '999,999,999,999' ) || ' MB' );
  dbms_output.put_line( 'Total used      : ' || to_char( ( ln_total_bytes - ln_total_free ) / ( 1024 * 1024 ), '999,999,999,999' ) || ' MB' );

end;