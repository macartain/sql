--
-- Script to remove unused synonyms.
--

set serveroutput on size 1000000
declare

type tab_type is table of varchar2(32767) index by binary_integer;
v_commands  tab_type;

begin

execute immediate q'+
    select 'drop '||decode (s.owner,'PUBLIC','PUBLIC SYNONYM ',
    'SYNONYM '||s.owner||'.')||s.synonym_name
    from dba_synonyms  s
    where table_owner not in('SYSTEM','SYS')
    and db_link is null
    and not exists
         (select  1
          from dba_objects o
          where s.table_owner=o.owner
          and s.table_name=o.object_name)+'
    bulk collect into v_commands;

if (v_commands.count() > 0)
then
    for i in 1 .. v_commands.count()
    loop
    begin
        execute immediate v_commands(i);
    exception
        when others then
        dbms_output.put_line('-->'||v_commands(i));
        dbms_output.put_line('Error encountered when dropping synonyms.');
        dbms_output.put_line(dbms_utility.format_error_stack);
    end;
    end loop;
end if;

exception
    when others then
    dbms_output.put_line('Error encountered');
end;
/

