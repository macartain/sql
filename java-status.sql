set pages 200
set lines 180
col OBJECT_NAME for a30
col owner for a14
select OWNER, OBJECT_NAME, STATUS, OBJECT_TYPE
from dba_objects
where OBJECT_TYPE like '%JAVA%'
and OWNER != 'SYS';
