REM *
REM * ====================== IMPORTANT ================================
REM *
REM * THIS SCRIPT IS AN EXAMPLE ONLY. IT MUST BE TAILORED FOR SITE USE
REM *

REM * save output to a log file
set echo on

REM * start the instance
connect SYS/change_on_install as SYSDBA
startup nomount pfile="/oradata/oradata01/admin/GNVREP/pfile/init.ora";

REM * create the database
REM * This creates control files, SYSTEM tablespace and redo logs.
REM * 
REM * This example uses auto undo management. Note that this features was 
REM * was faulty in early versions of 9i. 
REM *

CREATE DATABASE GNVREP
	MAXINSTANCES 1
	MAXLOGHISTORY 1
	MAXLOGFILES 32
	MAXLOGMEMBERS 3
	MAXDATAFILES 200
	DATAFILE '/oradata/oradata02/GNVREP/system01.dbf' SIZE 500M REUSE 
	EXTENT MANAGEMENT LOCAL
	DEFAULT TEMPORARY TABLESPACE TEMP 
		TEMPFILE '/oradata/oradata02/GNVREP/temp01.dbf' SIZE 200M REUSE 
		EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M
	UNDO TABLESPACE UNDOTBS1 
		DATAFILE '/oradata/oradata02/GNVREP/undotbs01.dbf' SIZE 200M REUSE 
	CHARACTER SET WE8ISO8859P15
	NATIONAL CHARACTER SET AL16UTF16
	LOGFILE GROUP 1 ('/oradata/oradata02/GNVREP/redo01a.rdo',
		 				'/oradata/oradata02/GNVREP/redo01b.rdo' ) SIZE 25M REUSE,
			 GROUP 2 ('/oradata/oradata02/GNVREP/redo02a.rdo',
						'/oradata/oradata02/GNVREP/redo02b.rdo' ) SIZE 25M REUSE,
			 GROUP 3 ('/oradata/oradata02/GNVREP/redo03a.rdo',
	 					'/oradata/oradata02/GNVREP/redo03b.rdo' ) SIZE 25M REUSE,
			 GROUP 4 ('/oradata/oradata02/GNVREP/redo04a.rdo',
	 					'/oradata/oradata02/GNVREP/redo04b.rdo' ) SIZE 25M REUSE;
spool off
exit;


