-- gnv date
select gnvgen.SYSTEMDATE from dual;

-- sessions
alter system kill session '148,412';
ALTER SYSTEM DISCONNECT SESSION '132,772' IMMEDIATE;

alter user geneva_admin account unlock;

-- AWR/statspack
EXEC dbms_workload_repository.create_snapshot;
awrrpt.sql

EXEC statspack.snap;
spreport.sql

-- spfiles
CREATE pfile FROM spfile; -- creates init${SID}.ora in $OH/dbs
create pfile='tstvod8.ora' from spfile; -- give it your own name - default location or else specify full path
create spfile from memory; -- 11g - will create it in default location

-- recyclebin
SELECT OBJECT_NAME, ORIGINAL_NAME, TYPE FROM RECYCLEBIN;
ALTER SYSTEM SET recyclebin = OFF deferred; -- deferred needed for 11g - means all subsequent sessions
purge recyclebin;

-- case sensitive passwds
alter system set sec_case_sensitive_logon=false scope=both; -- 11g

-- trace files - 11g
alter system  set "_trace_files_public"=TRUE scope=spfile;

-------------------------------------------------------------------------------
-- dirs
-------------------------------------------------------------------------------
CVG_INFINYS_PFCREATE DIRECTORY CVG_INFINYS_PF AS '/bcv1/infinys/infroot/cvg_infinys_pf';
GRANT READ, WRITE ON DIRECTORY CVG_INFINYS_PF TO PUBLIC;
mkdir /bcv1/infinys/infroot/cvg_infinys_pf

select table_name,grantee,privilege
from dba_tab_privs
where table_name = 'CVG_INFINYS_PF';

-------------------------------------------------------------------------------
-- alert log at 11g
-------------------------------------------------------------------------------
col ORIGINATING_TIMESTAMP for a32
col message_text for a140 wrap
select ORIGINATING_TIMESTAMP, message_text from X$DBGALERTEXT;

-------------------------------------------------------------------------------
-- adrci at 11g
-------------------------------------------------------------------------------
show homes
set home <path from above>
adrci> show alert

To display the last 10, 30 entries of the alert log and then interactive
adrci> show alert -tail
adrci> show alert -tail 30
SHOW ALERT -TAIL -F

This displays only alert log messages that contain the string 'ORA-600'
SHOW ALERT -P "MESSAGE_TEXT LIKE '%ORA-600%'"

show problem
show incident
show incident -mode detail -p "incident_id=24068"
show trace <tracefilepath-noquotes>

show tracefile -(r)t

show control
set control (LONGP_POLICY = 2190)
set control (SHORTP_POLICY = 360) -- age in hours 360=15 days
purge -age 2880 -type trace -- age in minutes = 1 day = 1440, 1 week=10080>

-------------------------------------------------------------------------------
-- db links
-------------------------------------------------------------------------------
col host for a35
col DB_LINK for a20
col USERNAME for a12
col owner for a16
select * from dba_db_links
order by created asc;

select db_link from user_db_links;
drop DATABASE LINK test;

CREATE DATABASE LINK bundlesync_to_gen53
 CONNECT TO geneva_admin IDENTIFIED BY geneva_admin USING
 '(DESCRIPTION=(ADDRESS_LIST=(
   ADDRESS=(PROTOCOL=TCP)(HOST=hocdt02n)(PORT=1521)))
   (CONNECT_DATA=(SERVICE_NAME=vodsi3)))'
/

grant execute on dbms_output to public;
grant execute on dbms_lock to public;
grant execute on dbms_scheduler to public;
grant CREATE JOB to GENEVA_ADMIN;

On VODSI3:
grant execute on dbms_output to public;

select * from geneva_admin.gparams@BUNDLESYNC_TO_GEN53;

-------------------------------------------------------------------------------
-- 11g ACL
-------------------------------------------------------------------------------
Packages requiring ACLs:
UTL_TCP
UTL_SMTP
UTL_MAIL
UTL_HTTP
UTL_INADDR

BEGIN
	DBMS_NETWORK_ACL_ADMIN.create_acl(
		acl          => 'VDC_test_system_ACL.xml', 
		description  => 'VDC RBM4.3 test system - installed CAM JAN2010',
		principal    => 'GENEVA_ADMIN',
		is_grant     => TRUE, 
		privilege    => 'connect',
		start_date   => SYSTIMESTAMP,
		end_date     => NULL);

	DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
		acl => 'VDC_test_system_ACL.xml',
		principal => 'GENEVA_ADMIN',
		is_grant => true,
		privilege => 'resolve');

	DBMS_NETWORK_ACL_ADMIN.assign_acl(
		acl         => 'VDC_test_system_ACL.xml',
		host        => '*', 
		lower_port  => NULL,
		upper_port  => NULL); 

	COMMIT;
END;
/

SELECT HOST, LOWER_PORT, UPPER_PORT, STATUS PRIVILEGE
FROM USER_NETWORK_ACL_PRIVILEGES
WHERE host IN
   (SELECT * FROM
      TABLE(DBMS_NETWORK_ACL_UTILITY.DOMAINS('*.emea.com'))) AND
      PRIVILEGE = 'connect'
ORDER BY DBMS_NETWORK_ACL_UTILITY.DOMAIN_LEVEL(host) DESC, LOWER_PORT;

-- clear gparams cache in pl/sql
execute gnvsessiongparams.clearCache;

-------------------------------------------------------------------------------
-- 11g passwd expiry
-------------------------------------------------------------------------------
SELECT profile
  FROM dba_users
 WHERE username = 'IPF_ADMIN';
 
select * from dba_profiles where profile='DEFAULT';
 
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

-------------------------------------------------------------------------------
-- triggers
-------------------------------------------------------------------------------

select status, trigger_body from dba_triggers where TRIGGER_NAME='GNV_ACCESS_CTRL';

alter table GENEVA_ADMIN.TAB disable all triggers; 
alter trigger sys.GNV_ACCESS_CTRL disable;