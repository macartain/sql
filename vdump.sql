set serveroutput on
declare
    e_no_getVersion exception; pragma EXCEPTION_INIT(e_no_getVersion, -00904);
	cnt     number;
	str     varchar2(32767);
	ver     varchar2(32767);

	cursor code_objs is
		select distinct do.object_name
		from dba_objects do
		where do.owner='GENEVA_ADMIN'
		and do.object_type='PACKAGE'
		order by do.object_name;
begin
    dbms_output.enable(1000000);
	for obj in code_objs
	loop
		str := 'select '|| obj.object_name ||'.getVersion from dual';
		begin
			execute immediate str into ver;
		exception
		when e_no_getVersion then ver:='NOT DEFINED';
			when others then
				dbms_output.put_line('Ooops ' || sqlerrm);
		end;		
		dbms_output.put_line(obj.object_name|| ' - '||ver);
	end loop;
end;
/
