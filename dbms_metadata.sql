-- The DBMS_METADATA package provides the API for setting the environment parameters: 
-- DBMS_METADATA.SET_TRANSFORM_PARAM() procedure.
-- The private procedure SetEnvironment() contains all the environment setup code. The procedure is 
-- called from the package initialization section. Therefore, it only executes once per session which 
-- is all you need. You want to set it up once at the very beginning.
-- 
-- To Prevents the output from formatting with indentation and line feeds, use the following code,
-- – for all objects
-- dbms_metadata.set_transform_param(dbms_metadata.session_transform, ‘PRETTY’, false);
-- 
-- To generate segment attributes (physical attributes, storage attributes, tablespace, logging, etc.), 
-- storage and tablespace clauses for tables, and indexes’ object definitions:
-- – for tables and indexes
-- dbms_metadata.set_transform_param(dbms_metadata.session_transform, ‘SEGMENT_ATTRIBUTES’, true);
-- dbms_metadata.set_transform_param(dbms_metadata.session_transform, ‘STORAGE’, true);
-- dbms_metadata.set_transform_param(dbms_metadata.session_transform, ‘TABLESPACE’, true);
-- 
-- To prevent all of the non-referential and referential constraints from being included in the table’s DDL. 
-- It also suppresses emitting table constraints as separate ALTER TABLE (and, if necessary, CREATE INDEX) statements:
-- – for tables only
-- dbms_metadata.set_transform_param(dbms_metadata.session_transform, ‘CONSTRAINTS’, false);
-- dbms_metadata.set_transform_param(dbms_metadata.session_transform, ‘REF_CONSTRAINTS’, false);
-- dbms_metadata.set_transform_param(dbms_metadata.session_transform, ‘CONSTRAINTS_AS_ALTER’, false);
-- 
-- Here the example script,

SET LONG 10000
SET LINES 180
SET HEADING OFF
SET FEEDBACK OFF
SET PAGES 0
SET VERIFY OFF
SET TRIMSPOOL ON

EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(
DBMS_METADATA.SESSION_TRANSFORM,’PRETTY’,TRUE);
EXEC

DBMS_METADATA.SET_TRANSFORM_PARAM(
DBMS_METADATA.SESSION_TRANSFORM,’SQLTERMINATOR’,TRUE);
EXEC

DBMS_METADATA.SET_TRANSFORM_PARAM(
DBMS_METADATA.SESSION_TRANSFORM,’SEGMENT_ATTRIBUTES’,TRUE);
EXEC

DBMS_METADATA.SET_TRANSFORM_PARAM(
DBMS_METADATA.SESSION_TRANSFORM,’STORAGE’,FALSE);
EXEC

DBMS_METADATA.SET_TRANSFORM_PARAM(
DBMS_METADATA.SESSION_TRANSFORM,’TABLESPACE’,TRUE);
EXEC

DBMS_METADATA.SET_TRANSFORM_PARAM(
DBMS_METADATA.SESSION_TRANSFORM,’SPECIFICATION’,TRUE);
EXEC

DBMS_METADATA.SET_TRANSFORM_PARAM(
DBMS_METADATA.SESSION_TRANSFORM,’BODY’,TRUE);
EXEC

DBMS_METADATA.SET_TRANSFORM_PARAM(
DBMS_METADATA.SESSION_TRANSFORM,’CONSTRAINTS’,TRUE);
EXEC

SPOOL SCOTT_DDL.SQL
CONNECT SCOTT/TIGER;
SELECT DBMS_METADATA.GET_DDL (OBJECT_TYPE, OBJECT_NAME, USER)
FROM USER_OBJECTS
/
SPOOL OFF
