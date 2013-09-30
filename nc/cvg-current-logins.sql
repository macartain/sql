set serveroutput on

-- Create temporary table listing roles granted to users and roles
create table tmp_rolegrants as
select grantee, nvl2(username, 'U', 'R') type, granted_role
from   dba_users,
       dba_role_privs
where  grantee = username (+);
create index tmp_rolegrants_ak1 on tmp_rolegrants(granted_role, grantee);

-- Create temporary table listing table privileges granted to roles
create table tmp_roletablegrants as
select distinct role
from   dba_tab_privs, dba_roles
where  owner = USER
and    role = grantee;

declare
    cursor c_loggedonusers is
        select v.sid, v.username, substr(v.program, 1, 30) program
        from   v$session v
        where  username in (select grantee username
                            from   tmp_rolegrants
                            where  granted_role in (select granted_role
                                                    from   tmp_rolegrants
                                                    connect by prior grantee = granted_role
                                                    start with granted_role in (select role from tmp_roletablegrants))
                            and    type = 'U'
                            union all
                            select username
                            from   dba_users, dba_tab_privs
                            where  owner = USER
                            and    username = grantee
                            union all
                            select USER
                            from   dual)
        and    audsid <> SYS_CONTEXT('USERENV', 'SESSIONID')
        and    sid||', '||serial# not in (select session_id
                                          from   dba_queue_schedules);

    v_user c_loggedonusers%ROWTYPE;
begin
    open c_loggedonusers;
    fetch c_loggedonusers into v_user;
    if c_loggedonusers%NOTFOUND then
        dbms_output.put_line('No other users with access to the current user''s tables are logged on.');
    else
        dbms_output.put_line('ORA-99999: Logged on users detected -');
        dbms_output.put_line('.');
        dbms_output.put_line('Session ID Username                       Program');
        dbms_output.put_line('---------- ------------------------------ ----------------------------------');

        while c_loggedonusers%FOUND
        loop
            dbms_output.put(rpad(v_user.sid, 11));
            dbms_output.put(rpad(v_user.username, 31));
            dbms_output.put(rpad(v_user.program, 35));
            dbms_output.new_line;

            fetch c_loggedonusers into v_user;
        end loop;

    end if;
    close c_loggedonusers;
end;
/

-- Drop temporary objects
drop table tmp_rolegrants;
drop table tmp_roletablegrants;
