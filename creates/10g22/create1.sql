REM *
REM * ===================== IMPORTANT ===============================
REM *
REM * THIS SCRIPT MUST BE REVIEWED AND TAILORED FOR SITE USE
REM *
REM * Set terminal output and command echoing on
REM *

set echo on
spool /Disk0/app/oracle/admin/TW10G08/create/create1.log

REM * Start the <sid> instance (ORACLE_SID here must be set to <sid>).
REM *

connect SYS/change_on_install as SYSDBA
startup nomount pfile="/Disk0/app/oracle/admin/TW10G08/pfile/init.ora";

create database TW10G08
maxinstances 1
maxloghistory 1
maxlogfiles 32
maxlogmembers 3
maxdatafiles 100
DATAFILE '/Disk2/oradata/TW10G08/system01.dbf' SIZE 500M REUSE
   AUTOEXTEND ON NEXT 1240K MAXSIZE 5000M
EXTENT MANAGEMENT LOCAL
SYSAUX DATAFILE '/Disk2/oradata/TW10G08/sysaux.dbf' SIZE 500M REUSE
   AUTOEXTEND ON NEXT 1240K MAXSIZE 8000M
DEFAULT TEMPORARY TABLESPACE TEMP
  TEMPFILE '/Disk2/oradata/TW10G08/temp01.dbf' SIZE 50M REUSE
  AUTOEXTEND ON NEXT 640K MAXSIZE 1000M
UNDO TABLESPACE "UNDOTBS1"
  DATAFILE '/Disk2/oradata/TW10G08/undotbs01.dbf' SIZE 200M REUSE
  AUTOEXTEND ON NEXT 5120K MAXSIZE 5000M
CHARACTER SET WE8ISO8859P15
NATIONAL CHARACTER SET AL16UTF16
LOGFILE GROUP 1('/Disk2/oradata/TW10G08/redo01a.rdo',
		'/Disk2/oradata/TW10G08/redo01b.rdo') SIZE 50M REUSE,
	GROUP 2('/Disk2/oradata/TW10G08/redo02a.rdo',
		'/Disk2/oradata/TW10G08/redo02b.rdo') SIZE 50M REUSE,
	GROUP 3('/Disk2/oradata/TW10G08/redo03a.rdo',
		'/Disk2/oradata/TW10G08/redo03b.rdo') SIZE 50M REUSE;
spool off
exit;
