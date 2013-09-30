accept GENUSER CHAR prompt "Please enter the new user name: ";
accept SUPPORT CHAR prompt "Please enter the tablespace: ";

create user &&GENUSER identified by &&GENUSER
   default tablespace &&SUPPORT
   temporary tablespace TEMP
   quota unlimited on &&SUPPORT
   quota unlimited on TEMP;

grant create session to &&GENUSER;
grant dba to &&GENUSER with admin option;

grant select on sys.dba_roles to &&GENUSER;
grant select on sys.dba_role_privs to &&GENUSER;
grant select on sys.dba_tab_privs to &&GENUSER;
grant grant any roles to &&GENUSER;
grant create role to &&GENUSER;
grant create sequence to &&GENUSER;
grant select on sys.dba_profiles to &&GENUSER with grant option;
grant select on sys.dba_USERS to &&GENUSER with grant option;
grant select on sys.dba_TABLESPACES to &&GENUSER with grant option;
grant execute on DBMS_ALERT to &&GENUSER;

grant GENEVAADMIN to &&GENUSER with admin option;
grant GENEVABATCH to &&GENUSER with admin option;
grant GENEVAAPP to &&GENUSER with admin option;
grant GENEVAVERSION to &&GENUSER with admin option;
grant GENEVASECURITY to &&GENUSER with admin option;

grant execute on dbms_aq to &&GENUSER with grant option;
grant execute on dbms_aqadm to &&GENUSER;
grant alter session to &&GENUSER;
grant grant any roles to &&GENUSER;
grant create role to &&GENUSER;
grant create sequence to &&GENUSER;
grant execute on DBMS_PIPE to &&GENUSER;

-- set verify off
-- set head off
-- column directory_path new_value gCDTdirPath
-- select directory_path
-- from   dba_directories
-- where  directory_name = 'CDT_DIR';
-- 
-- grant read  on directory CDT_DIR to &&GENUSER;
-- grant write on directory CDT_DIR to &&GENUSER;
-- 
-- execute dbms_java.grant_permission(UPPER('&&GENUSER'),'SYS:java.io.FilePermission', '&&gCDTdirPath' || '/*','read');
-- execute dbms_java.grant_permission(UPPER('&&GENUSER'),'SYS:java.io.FilePermission', '&&gCDTdirPath' || '/*','write');
