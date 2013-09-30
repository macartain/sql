-- --------------------------------------------------------------------
-- Standard Support queries to dump perms
-- --------------------------------------------------------------------
set pages 9999 feed off veri off lines 500 trimspool on
accept thisuser prompt "Enter user to report: "
-- ((select the role(s) that a user has been assigned....?)
prompt ========================================================================
prompt Roles assigned to &&thisuser
prompt ========================================================================
select * from dba_role_privs where GRANTEE='&&thisuser'
order by GRANTED_ROLE;
-- (see all the 'grants' that have been assigned to a user....? )
prompt ========================================================================
prompt Grants to &&thisuser
prompt ========================================================================
select * from dba_sys_privs 
where grantee = '&&thisuser'
or GRANTEE in (
	select GRANTED_ROLE from dba_role_privs where GRANTEE='&&thisuser')
order by grantee, PRIVILEGE;
-- And Objects - counts for executables as well as tables
prompt ========================================================================
prompt Object Grants to &&thisuser
prompt ========================================================================
SELECT grantee, privilege, owner, table_name
FROM dba_tab_privs
where grantee = '&&thisuser'
or GRANTEE in (
	select GRANTED_ROLE from dba_role_privs where GRANTEE='&&thisuser')
order by grantee, PRIVILEGE, owner, table_name;

-- --------------------------------------------------------------------
-- Extract public synonyms for rebuild - only exported with FULL exp
-- --------------------------------------------------------------------
select 'create public synonym ' || synonym_name || ' for ' || table_owner || '.' || table_name || ';'
from dba_synonyms
where owner = 'PUBLIC'
and table_owner = 'GENEVA_ADMIN';

-- --------------------------------------------------------------------
-- User settings
-- --------------------------------------------------------------------
col TEMPORARY_TABLESPACE for a12
col DEFAULT_TABLESPACE for a12
select username,  to_char(created, 'DD-MM-YYYY HH24:MI:SS') created, DEFAULT_TABLESPACE, temporary_tablespace, account_status 
from dba_users
order by created asc;

-- --------------------------------------------------------------------
-- Grants for a privilege - e.g. SELECT ANY TABLE
-- --------------------------------------------------------------------
select
  lpad(' ', 3*level) || c "Privilege, Roles and Users"
from
  (
  /* THE PRIVILEGES */
    select 
      null   p, 
      name   c
    from 
      system_privilege_map
    where
      name like upper('%&enter_privliege%')
  /* THE ROLES TO ROLES RELATIONS */ 
  union
    select 
      granted_role  p,
      grantee       c
    from
      dba_role_privs
  /* THE ROLES TO PRIVILEGE RELATIONS */ 
  union
    select
      privilege     p,
      grantee       c
    from
      dba_sys_privs
  )
start with p is null
connect by p = prior c;

-- --------------------------------------------------------------------
-- CVG biz roles
-- --------------------------------------------------------------------
col GENEVA_USER_ORA for a21
col BUSINESS_ROLE_DESC for a75

select GENEVA_USER_ORA, BUSINESS_ROLE_NAME, BUSINESS_ROLE_DESC
from GENEVAUSERHASBUSINESSROLE guhbr inner join BUSINESSROLE br on
guhbr.BUSINESS_ROLE_ID=br.BUSINESS_ROLE_ID
order by GENEVA_USER_ORA ; 

-- --------------------------------------------------------------------
-- Java perm setting
-- --------------------------------------------------------------------

execute Dbms_Java.grant_permission('GENEVA_ADMIN', 'SYS:java.io.FilePermission', '/home/infinys/ENV10/logs/eventlog', 'read ,write, execute, delete');
execute Dbms_Java.grant_permission('GENEVA_ADMIN', 'SYS:java.io.FilePermission', '/home/infinys/ENV10/logs/eventlog/-', 'read ,write, execute, delete');
execute Dbms_Java.Grant_Permission('GENEVA_ADMIN', 'SYS:java.lang.RuntimePermission', 'writeFileDescriptor', '');
execute Dbms_Java.Grant_Permission('GENEVA_ADMIN', 'SYS:java.lang.RuntimePermission', 'readFileDescriptor', '');
commit;
 
execute gnvsessiongparams.clearCache;

select distinct GRANTEE from dba_role_privs where GRANTED_ROLE='DBA';