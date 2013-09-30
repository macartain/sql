accept RBUSER    CHAR prompt "Please enter the new user name: ";
accept TSPACE   CHAR prompt "Please enter the tablespace: ";

create user &&RBUSER identified by &&RBUSER
   default tablespace &&TSPACE
   temporary tablespace TEMP;

grant create session to &&RBUSER;
grant dba to &&RBUSER with admin option;

grant GENEVAADMIN    to &&RBUSER with admin option;
grant GENEVABATCH    to &&RBUSER with admin option;
grant GENEVAAPP      to &&RBUSER with admin option;
grant GENEVAVERSION  to &&RBUSER with admin option;
grant GENEVASECURITY to &&RBUSER with admin option;

grant execute on dbms_aq to &&RBUSER with grant option;
grant execute on dbms_aqadm to &&RBUSER;

grant execute on INF_ADMIN.INFINYS_PRIVS     to    &&RBUSER;
grant select  on INF_ADMIN.V_INFINYS_OBJECTS to    &&RBUSER;
grant execute on IPF_ADMIN.DATA_SECURITY     to    &&RBUSER;
grant select, insert, update, delete, references, alter, index on IPF_ADMIN.PFMESSAGE to &&RBUSER with grant option;
grant execute on IPF_ADMIN.SYSREG            to    &&RBUSER;
grant execute on IPF_ADMIN.AUDITLOG          to    &&RBUSER;

-- *************************************************
-- Granting common privileges to    &&RBUSER
-- *************************************************
grant select on sys.dba_roles       to    &&RBUSER;
grant select on sys.dba_role_privs  to    &&RBUSER;
grant select on sys.dba_tab_privs   to    &&RBUSER;
grant select on sys.dba_profiles    to &&RBUSER with grant option;
grant select on sys.dba_users       to &&RBUSER with grant option;
grant select on sys.dba_tablespaces to &&RBUSER with grant option;
grant select on sys.gv_$transaction to    &&RBUSER;

grant alter session                 to    &&RBUSER;
grant grant any roles               to    &&RBUSER;
grant create role                   to    &&RBUSER;
grant create sequence               to    &&RBUSER;
grant create table                  to    &&RBUSER;
grant create view                   to    &&RBUSER;
grant create trigger                to    &&RBUSER;
grant alter tablespace              to    &&RBUSER;

grant execute on dbms_alert         to    &&RBUSER;
grant execute on dbms_pipe          to    &&RBUSER;
grant execute on dbms_lock          to    &&RBUSER;
 
-- *************************************************
-- Granting privileges on Advanced Queuing packages.
-- *************************************************
grant execute on dbms_aq            to &&RBUSER with grant option;

-- **************************************************
-- Granting privileges on Streams packages and views.
-- **************************************************
dbms_streams_auth.grant_admin_privilege(grantee => &&RBUSER, grant_privileges => true);

grant execute on dbms_streams_adm    to &&RBUSER with grant option;
grant execute on dbms_capture_adm    to &&RBUSER with grant option;
grant execute on dbms_apply_adm      to &&RBUSER with grant option;
grant execute on dbms_propagation_adm    to &&RBUSER with grant option;

grant select on sys.dba_propagation  to &&RBUSER with grant option;
grant select on sys.dba_capture      to &&RBUSER with grant option;
grant select on sys.dba_apply        to &&RBUSER with grant option;
grant select on sys.dba_streams_rules    to &&RBUSER with grant option;

grant execute on dbms_streams_messaging  to &&RBUSER with grant option;
grant execute on dbms_streams        to &&RBUSER with grant option;
grant execute on dbms_rule_adm       to &&RBUSER with grant option;

