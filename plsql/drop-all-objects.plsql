begin
for f in (
select object_type, object_name from user_objects
where object_type in (
‘MATERIALIZED VIEW’)) loop
execute immediate
‘drop materialized view “‘||f.object_name||’” preserve table’;
end loop;
for f in (
select table_name from user_tables) loop
execute immediate
‘drop table “‘||f.table_name||’” cascade constraints’;
end loop;
for f in (
select object_type, object_name from user_objects
where object_type in (
‘DIMENSION’,'CLUSTER’,'SEQUENCE’,
‘VIEW’,'FUNCTION’,'PROCEDURE’,
‘PACKAGE’,'SYNONYM’,'DATABASE LINK’,
‘INDEXTYPE’)
and object_name like ‘SYS_%$’) loop
execute immediate ‘drop ‘||
f.object_type||’ “‘||f.object_name||’”‘;
end loop
for f in (
select object_type, object_name from user_objects
where object_type in (
‘JAVA SOURCE’)) loop
execute immediate ‘drop ‘||
f.object_type||’ “‘||f.object_name||’”‘;
end loop;
for f in (
select object_type, object_name from user_objects
where object_type in (
‘JAVA RESOURCE’)) loop
execute immediate ‘drop ‘||
f.object_type||’ “‘||f.object_name||’”‘;
end loop;
for f in (
select object_type, object_name from user_objects
where object_type in (
‘JAVA CLASS’)) loop
execute immediate ‘drop ‘||
f.object_type||’ “‘||f.object_name||’”‘;
end loop;
for f in (select object_type, object_name from user_objects
where object_type in (
‘TYPE’,'OPERATOR’)) 
loop
execute immediate ‘drop ‘||f.object_type||’ “‘||f.object_name||’” force’;
end loop;
end;
