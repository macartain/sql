-- *********************************************************
-- File: securityprivs.sql
--
-- Script to grant GENEVASECURITY role to the SECURITY user.
--
-- THIS SCRIPT MUST BE RUN, AFTER THE SECURITY USER HAS BEEN CREATED 
-- (i.e. AFTER SUCCESSFUL COMPLETION OF MIGRATION/INSTALLATION), AND
--  AS USER "SYS". 
--
-- Version: @(#) (%full_filespec: securityprivs.sql-3:sql:1 %)
--
-- Copyright (c) Geneva Technology 2000
-- *********************************************************
grant GENEVASECURITY to SECURITY with admin option;
grant GENEVAAPP to SECURITY with admin option;
