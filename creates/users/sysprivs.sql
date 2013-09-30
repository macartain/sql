-- *********************************************************
-- File: sysprivs.sql
--
-- Script to grant specific required privileges to Geneva or
-- Event schema owner users.
--
-- THIS SCRIPT MUST BE RUN AS USER "SYS", or a suitably
-- privileged user, to explicitly grant privileges to the
-- schema owner user. This is because Oracle does not use
-- privileges from granted roles within stored procedures.
--
-- This script should be run with a single parameter giving the
-- user to whom the privileges are to be granted.
--
-- Version: @(#) (%full_filespec: sysprivs.sql-5:sql:CB1#1 %)
--
-- Copyright (c) Convergys, 2004
-- Convergys refers to Convergys Corporation or any of its wholly owned
-- subsidiaries.
-- *********************************************************

define gUser = &&1
set verify off

prompt
prompt Granting privileges to &&gUser user...
prompt

grant select on sys.dba_roles       to &&gUser;
grant select on sys.dba_role_privs  to &&gUser;
grant select on sys.dba_tab_privs   to &&gUser;
grant select on sys.dba_profiles    to &&gUser with grant option;
grant select on sys.dba_USERS       to &&gUser with grant option;
grant select on sys.dba_TABLESPACES to &&gUser with grant option;

grant alter session                 to &&gUser;
grant grant any roles               to &&gUser;
grant create role                   to &&gUser;
grant create sequence               to &&gUser;

grant execute on DBMS_ALERT         to &&gUser;
grant execute on DBMS_PIPE          to &&gUser;

prompt
prompt *************************************************
prompt Granting privileges on Advanced Queuing packages.
prompt *************************************************
prompt
prompt NOTE:
prompt If there are other users on this database instance with active queues,
prompt it may fail with a timeout waiting for a lock (Oracle error 04021).
prompt This is due to Oracle locking the package during message propagation.
prompt
prompt A workaround is to temporarily disable queues with the following:
prompt
prompt   alter system set job_queue_processes=0 scope=memory;
prompt
prompt Ensure that the parameter is reset to a suitable value after this
prompt script completes, or queue message propagation and job execution will
prompt not operate.
prompt

grant execute on dbms_aq            to &&gUser with grant option;
grant execute on dbms_aqadm         to &&gUser;

prompt
prompt Finished granting privileges.
prompt
