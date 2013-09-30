-- *********************************************************
-- File: securityrole.sql
--
-- Script to grant specific privileges to  GENEVASECURITY role.
--
-- THIS SCRIPT MUST BE RUN, AFTER THE SECURITY USER HAS BEEN CREATED 
-- (i.e. AFTER SUCCESSFUL COMPLETION OF MIGRATION/INSTALLATION), AND
--  AS USER "SYS" TO EXPLICITLY GRANT PRIVILEGES TO "GENEVASECURITY & 
--  GENEVAAPP ROLES". THIS IS TO OVERCOME THE ORACLE 'FEATURE' WHEREBY 
-- CERTAIN PRIVILEGES OBTAINED THROUGH GRANTED ROLES (SUCH AS DBA)
-- ARE NOT RECOGNISED WITHIN STORED PROCEDURES.  
--
-- Version: @(#) (%full_filespec: securityrole.sql-2:sql:1 %)
--
-- Copyright (c) Geneva Technology 2000
-- *********************************************************
prompt Granting DBA views to GENEVAAPP...
-- ======================================================================
-- Needs to be done before granting GENEVAAPP role to GENEVASECURITY ROLE
-- ======================================================================
grant select on sys.dba_profiles to GENEVAAPP;
grant select on sys.dba_USERS to GENEVAAPP;
grant select on sys.dba_TABLESPACES to GENEVAAPP;
grant select on sys.dba_ROLE_PRIVS to GENEVAAPP;

prompt GENEVASECURITY...
grant create SESSION to GENEVASECURITY with admin option;
grant create USER to GENEVASECURITY;
grant alter USER to GENEVASECURITY;
grant drop USER to GENEVASECURITY;
