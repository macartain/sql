REM * 
REM * ====================== IMPORTANT ==============================
REM * 
REM * THIS SCRIPT MUST BE REVIEWED AND TAILORED FOR SITE USE
REM *
REM * Set terminal output and command echoing on
REM *

set termout on
set echo on

spool /Disk2/app/oracle/admin/VODSI4/create/create2.log

connect SYS/change_on_install as SYSDBA

create tablespace tools datafile
'/Disk4/oradata/VODSI4/tools01.dbf' size 50M REUSE
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 256K
SEGMENT SPACE MANAGEMENT AUTO;

create tablespace DATA LOGGING datafile
'/Disk4/oradata/VODSI4/data01.dbf' size 10000M REUSE
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 256K
SEGMENT SPACE MANAGEMENT AUTO;

spool off

