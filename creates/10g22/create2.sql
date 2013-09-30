REM * 
REM * ====================== IMPORTANT ==============================
REM * 
REM * THIS SCRIPT MUST BE REVIEWED AND TAILORED FOR SITE USE
REM *
REM * Set terminal output and command echoing on
REM *

set termout on
set echo on

spool /Disk0/app/oracle/admin/TW10G08/create/create2.log

connect SYS/change_on_install as SYSDBA

create tablespace USERS LOGGING datafile
'/Disk2/oradata/TW10G08/users01.dbf' size 2000M REUSE
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 256K
SEGMENT SPACE MANAGEMENT AUTO;

spool off
exit;

