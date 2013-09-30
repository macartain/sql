REM *
REM * ====================== IMPORTANT ================================
REM *
REM * THIS SCRIPT IS AN EXAMPLE ONLY. IT MUST BE TAILORED FOR SITE USE
REM *
REM * The example uses Locally Managed Tablespaces with uniform extents

REM * save output to a log file
set termout on
set echo on

REM * The database should already be started up at this point

-- connect SYS/change_on_install as SYSDBA

REM * =================================================================
REM * DATA
REM * =================================================================
REM * Create a tablespace for database tools.
REM *
CREATE TABLESPACE DATA 
DATAFILE '/oradata/oradata02/GNVREP/data.dbf'
SIZE 1050M REUSE
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 256K
SEGMENT SPACE MANAGEMENT AUTO ;
exit;
