REM *
REM * ===================== IMPORTANT ===============================
REM *
REM * THIS SCRIPT MUST BE REVIEWED AND TAILORED FOR SITE USE
REM *
REM * Set terminal output and command echoing on
REM *

set echo on
spool /Disk2/app/oracle/admin/VODSI4/create/create1.log

REM * Start the <sid> instance (ORACLE_SID here must be set to <sid>).
REM *

connect SYS/change_on_install as SYSDBA
startup nomount pfile="/Disk2/app/oracle/admin/VODSI4/pfile/initVODSI4.ora";

create database VODSI4
maxinstances 1
maxloghistory 1
maxlogfiles 32
maxlogmembers 3
maxdatafiles 100
DATAFILE '/Disk4/oradata/VODSI4/system01.dbf' SIZE 500M REUSE
   AUTOEXTEND ON NEXT 1240K MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
DEFAULT TEMPORARY TABLESPACE TEMP
  TEMPFILE '/Disk4/oradata/VODSI4/temp01.dbf' SIZE 50M REUSE
  AUTOEXTEND ON NEXT 640K MAXSIZE 5000M
UNDO TABLESPACE "UNDOTBS1"
  DATAFILE '/Disk4/oradata/VODSI4/undotbs01.dbf' SIZE 200M REUSE
  AUTOEXTEND ON NEXT 5120K MAXSIZE 5000M
CHARACTER SET WE8ISO8859P15
NATIONAL CHARACTER SET AL16UTF16
LOGFILE GROUP 1('/Disk4/oradata/VODSI4/redo01a.rdo',
        '/Disk4/oradata/VODSI4/redo01b.rdo') SIZE 50M REUSE,
    GROUP 2('/Disk4/oradata/VODSI4/redo02a.rdo',
        '/Disk4/oradata/VODSI4/redo02b.rdo') SIZE 50M REUSE,
    GROUP 3('/Disk4/oradata/VODSI4/redo03a.rdo',
        '/Disk4/oradata/VODSI4/redo03b.rdo') SIZE 50M REUSE;
spool off
exit;
