set newpage NONE
set space 0
set linesize 200
set pagesize 0
set echo off
set feedback off
set verify off
set heading off
set trimspool on
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS_AS_ALTER',true);
spool ddldump.sql
SELECT DBMS_METADATA.GET_DDL('PACKAGE','CVG_CAM_UTIL','GENEVA_ADMIN') FROM dual;
spool off
