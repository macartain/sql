accept x_active_only prompt "Show only active sessions [Y/N] :"

declare
  ls_active_only varchar2(1) := nvl( upper( '&x_active_only' ), 'N' );

  type t_rec_sess_data is record ( sid number, enq_request number, log_reads number, phys_writes number, unknown number );
  type t_table_sess_data is table of t_rec_sess_data index by binary_integer;

  t_sess_data_1 t_table_sess_data;
  t_sess_data_2 t_table_sess_data;

  -- 2003/04/08
  -- some statistic# values have changed between 8i and 9i, e.g. 44, formerly 'physical writes' is now 'consistent changes'
  -- this script updated to allow for that

  ln_enq_req_num number;
  ln_log_reads number;
  ln_phys_writes number;

  cursor c_sesstat is
    select *
    from v$sesstat
    where (    statistic# = ln_enq_req_num  -- 'enqueue requests'
            or statistic# = ln_log_reads   -- 'session logical reads'
            or statistic# = ln_phys_writes  -- 'physical writes'
          );

  cursor c_session is
    select *
    from v$session
  where username is not null;

  lr_session v$session%rowtype;

  ls_hdr1 varchar2( 1000 ) := rpad( '    ', 30 ) || ' ' || '     ' || '         Enqueue Reqs                 Logical Reads                    Phys Writes';
  ls_hdr2 varchar2( 1000 ) := rpad( 'User', 30 ) || ' ' || '  Sid' || '      Before       After              Before       After              Before       After';
  ls_hdr3 varchar2( 1000 ) := rpad( '----', 30 ) || ' ' || '  ---' || '      --------    --------            --------    --------            --------    --------';

  ls_data_line varchar2( 1000 );

  ls_active varchar2( 20 );

  ls_enq_request_diff varchar2( 100 );
  ls_log_reads_diff varchar2( 100 );
  ls_phys_writes_diff varchar2( 100 );

begin

  -- this will error if the name no longer exists in v$statname
  select statistic# into ln_enq_req_num from v$statname where name = 'enqueue requests';
  select statistic# into ln_log_reads from v$statname where name = 'session logical reads';
  select statistic# into ln_phys_writes from v$statname where name = 'physical writes';

  dbms_output.put_line( '1st data check ; ' || to_char( sysdate, 'yyyy/mm/dd hh24:mi:ss' ) );

  for i in c_sesstat loop
    if not t_sess_data_1.exists( i.sid ) then
      t_sess_data_1( i.sid ).sid := i.sid;
      t_sess_data_1( i.sid ).enq_request := 0;
      t_sess_data_1( i.sid ).log_reads := 0;
      t_sess_data_1( i.sid ).phys_writes := 0;
      t_sess_data_1( i.sid ).unknown := 0;
    end if;

    if i.statistic# = ln_enq_req_num then
      t_sess_data_1( i.sid ).enq_request := i.value;
    elsif i.statistic# = ln_log_reads then
      t_sess_data_1( i.sid ).log_reads := i.value;
    elsif i.statistic# = ln_phys_writes then
      t_sess_data_1( i.sid ).phys_writes := i.value;
    else
      t_sess_data_1( i.sid ).unknown := i.value;
    end if;
  end loop;

  dbms_lock.sleep( 30 );

  dbms_output.put_line( '2nd data check ; ' || to_char( sysdate, 'yyyy/mm/dd hh24:mi:ss' ) || chr(10) );

  for i in c_sesstat loop
    if not t_sess_data_2.exists( i.sid ) then
      t_sess_data_2( i.sid ).sid := i.sid;
      t_sess_data_2( i.sid ).enq_request := 0;
      t_sess_data_2( i.sid ).log_reads := 0;
      t_sess_data_2( i.sid ).phys_writes := 0;
      t_sess_data_2( i.sid ).unknown := 0;
    end if;

    if i.statistic# = ln_enq_req_num then
      t_sess_data_2( i.sid ).enq_request := i.value;
    elsif i.statistic# = ln_log_reads then
      t_sess_data_2( i.sid ).log_reads := i.value;
    elsif i.statistic# = ln_phys_writes then
      t_sess_data_2( i.sid ).phys_writes := i.value;
    else
      t_sess_data_2( i.sid ).unknown := i.value;
    end if;
  end loop;


  dbms_output.put_line( ls_hdr1 );
  dbms_output.put_line( ls_hdr2 );
  dbms_output.put_line( ls_hdr3 );


  for i in c_session loop

    ls_active := '-';

    ls_data_line := rpad( i.username, 20 ) || ' ' || to_char( i.sid, '9999' );

    if t_sess_data_1.exists( i.sid ) and t_sess_data_2.exists( i.sid ) then

      if nvl( t_sess_data_1( i.sid ).enq_request, 0 )  <> nvl( t_sess_data_2( i.sid ).enq_request, 0 ) then
        ls_enq_request_diff := to_char( t_sess_data_2( i.sid ).enq_request - t_sess_data_1( i.sid ).enq_request, '999,999' );
      else
        ls_enq_request_diff := '        ';
      end if;

      if nvl( t_sess_data_1( i.sid ).log_reads, 0 ) <> nvl( t_sess_data_2( i.sid ).log_reads, 0 ) then
        ls_log_reads_diff := to_char( t_sess_data_2( i.sid ).log_reads - t_sess_data_1( i.sid ).log_reads, '999,999' );
      else
        ls_log_reads_diff := '        ';
      end if;

      if nvl( t_sess_data_1( i.sid ).phys_writes, 0 ) <> nvl( t_sess_data_2( i.sid ).phys_writes, 0 ) then
        ls_phys_writes_diff := to_char( t_sess_data_2( i.sid ).phys_writes - t_sess_data_1( i.sid ).phys_writes, '999,999' );
      else
        ls_phys_writes_diff := '        ';
      end if;

      ls_data_line := ls_data_line || 
                      to_char( nvl( t_sess_data_1( i.sid ).enq_request, 0 ), '999,999,999' ) ||
                      to_char( nvl( t_sess_data_2( i.sid ).enq_request, 0 ), '999,999,999' ) ||
                      ls_enq_request_diff ||
                      to_char( nvl( t_sess_data_1( i.sid ).log_reads, 0 ), '999,999,999' ) ||
                      to_char( nvl( t_sess_data_2( i.sid ).log_reads, 0 ), '999,999,999' ) ||
                      ls_log_reads_diff ||
                      to_char( nvl( t_sess_data_1( i.sid ).phys_writes, 0 ), '999,999,999' ) ||
                      to_char( nvl( t_sess_data_2( i.sid ).phys_writes, 0 ), '999,999,999' ) ||
                      ls_phys_writes_diff ||' ' || 
                      to_char( i.program, '9999' );

                      if t_sess_data_1( i.sid ).enq_request  <> t_sess_data_2( i.sid ).enq_request or
                         t_sess_data_1( i.sid ).log_reads <> t_sess_data_2( i.sid ).log_reads or
                         t_sess_data_1( i.sid ).phys_writes <> t_sess_data_2( i.sid ).phys_writes then
                        ls_active := '*';
                      else
                        ls_active := ' ';
                      end if;

    elsif t_sess_data_1.exists( i.sid ) then
      ls_data_line := ls_data_line || 
                      to_char( t_sess_data_1( i.sid ).enq_request, '999,999,999' ) ||
                      '           -' ||
                      to_char( t_sess_data_1( i.sid ).log_reads, '999,999,999' ) ||
                      '           -' ||
                      to_char( t_sess_data_1( i.sid ).phys_writes, '999,999,999' ) ||
                      '           -';
    elsif t_sess_data_2.exists( i.sid ) then
      ls_data_line := ls_data_line || 
                      '           -' ||
                      to_char( t_sess_data_2( i.sid ).log_reads, '999,999,999' ) ||
                      '           -' ||
                      to_char( t_sess_data_2( i.sid ).phys_writes, '999,999,999' ) ||
                      '           -' ||
                      to_char( t_sess_data_2( i.sid ).enq_request, '999,999,999' );
    else
      ls_data_line := ls_data_line || ' no data found.';

    end if;

    if ls_active_only = 'Y' then
      if ls_active = '*' then
        dbms_output.put_line( ls_data_line || ' ' || ls_active );
      end if;
    else
      dbms_output.put_line( ls_data_line || ' ' || ls_active );
    end if;

  end loop;


null;

end;
/