-- Create the user
create user GENEVA_ADMIN
  identified by "geneva"
    default tablespace DATA
      temporary tablespace TEMP
        profile DEFAULT;
        -- Grant/Revoke object privileges
        grant select on SYS.DBA_PROFILES to GENEVA_ADMIN with grant option;
        grant select on SYS.DBA_ROLES to GENEVA_ADMIN;
        grant select on SYS.DBA_ROLE_PRIVS to GENEVA_ADMIN;
        grant select on SYS.DBA_TABLESPACES to GENEVA_ADMIN with grant option;
        grant select on SYS.DBA_TAB_PRIVS to GENEVA_ADMIN;
        grant select on SYS.DBA_USERS to GENEVA_ADMIN with grant option;
        grant execute on SYS.DBMS_ALERT to GENEVA_ADMIN;
        grant execute on SYS.DBMS_AQ to GENEVA_ADMIN with grant option;
        grant execute on SYS.DBMS_AQADM to GENEVA_ADMIN;
        grant execute on SYS.DBMS_AQ_BQVIEW to GENEVA_ADMIN;
        grant execute on SYS.DBMS_PIPE to GENEVA_ADMIN;
        -- Grant/Revoke role privileges
        grant connect to GENEVA_ADMIN;
        grant dba to GENEVA_ADMIN;
        -- Grant/Revoke system privileges
        grant alter session to GENEVA_ADMIN;
        grant alter tablespace to GENEVA_ADMIN;
        grant create role to GENEVA_ADMIN;
        grant create sequence to GENEVA_ADMIN;
        grant create table to GENEVA_ADMIN;
        grant grant any role to GENEVA_ADMIN;
        grant unlimited tablespace to GENEVA_ADMIN;


