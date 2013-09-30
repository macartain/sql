-- *********************************************************
-- File: createrole.sql
--
-- Script to create all of the roles used in Geneva.
--
-- In order to make this script rerunnable it is necessary to trap
-- any errors. Therefore a PL/SQL procedure is created to create the role.
--
-- This script is only run once per database - not once per schema.
--
-- This script is NOT included in the "allroles.sql" script, since it is
-- run before that script.
--
-- Version: @(#) (%full_filespec: createrole.sql-20:sql:CB1#1 %)
--
-- Copyright (c) Convergys, 2003
-- Convergys refers to Convergys Corporation or any of its wholly owned
-- subsidiaries.
-- *********************************************************

set echo off
set termout on
prompt
prompt Creating CREATEROLE procedure...
set termout off
set echo on

-- If theRole already exists then do nothing.
-- Otherwise create the role with no privileges

create or replace procedure createRole (theRole varchar2)
as
    e_role_name_conflicts exception;
    pragma exception_init(e_role_name_conflicts, -1921);
begin
    execute immediate 'create role ' || theRole;
exception
    when e_role_name_conflicts
        then null;
end createRole;
/
show errors procedure createrole

-- Create each of the Geneva roles

set termout on

execute createRole ('GENEVAADMIN');
execute createRole ('GENEVAAPP');
execute createRole ('GENEVABATCH');
execute createRole ('GENEVAPUBLIC');
execute createRole ('GENEVASECURITY');
execute createRole ('GENEVAVERSION');

commit;

-- ********************************************************
-- End of createrole.sql
-- ********************************************************
