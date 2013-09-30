-- *********************************************************
-- File: roleprivs.sql
--
-- Script to grant specific privileges to Geneva Schema Owner user.
--
-- THIS SCRIPT MUST BE RUN AS USER "SYS", or a suitably
-- privileged user, to explicitly grant privileges to the
-- schema owner user. This is because Oracle does not use
-- privileges from granted roles within stored procedures.
--
-- Version: @(#) (%full_filespec: roleprivs.sql-13:sql:CB1#1 %)
--
-- Copyright (c) Convergys, 2002
-- Convergys refers to Convergys Corporation or any of its wholly owned
-- subsidiaries.
-- *********************************************************

@@sysprivs.sql GENEVA_ADMIN
