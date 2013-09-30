-- --------------------------------------------------------------------
-- Create trace account
-- --------------------------------------------------------------------
create user trcuser
identified by "trcuser"
default tablespace USERS
temporary tablespace TEMP
profile DEFAULT;

-- Grant/Revoke object privileges
grant select on SYS.DBA_PROFILES to trcuser;
grant select on SYS.DBA_ROLES to trcuser;
grant select on SYS.DBA_ROLE_PRIVS to trcuser;
grant select on SYS.DBA_TABLESPACES to trcuser;
grant select on SYS.DBA_TAB_PRIVS to trcuser;
grant select on SYS.DBA_USERS to trcuser;
grant execute on SYS.DBMS_ALERT to trcuser;
grant execute on SYS.DBMS_AQ to trcuser;
grant execute on SYS.DBMS_AQADM to trcuser;
grant execute on SYS.DBMS_AQ_BQVIEW to trcuser;
grant execute on SYS.DBMS_PIPE to trcuser;
-- Grant/Revoke role privileges
grant connect to trcuser;
-- Grant/Revoke system privileges
grant alter session to trcuser;
grant alter tablespace to trcuser;
grant create role to trcuser;
grant create sequence to trcuser;
grant create table to trcuser;
grant create trigger to trcuser;
grant grant any role to trcuser;
grant unlimited tablespace to trcuser;
grant genevabatch to trcuser;

-- tracing role
grant plustrace to trcuser;
-- May need as sys:
-- @$ORACLE_HOME/sqlplus/admin/plustrce.sql

-- tracing perms
grant execute on DBMS_MONITOR to trcuser;
grant execute on DBMS_WORKLOAD_REPOSITORY to trcuser;

-- --------------------------------------------------------------------
-- Logon trigger - starts session trace
-- --------------------------------------------------------------------
create or replace trigger CVG_SESSION_TRACE_ON
AFTER LOGON ON DATABASE
WHEN (USER='GENEVA_ADMIN')
declare
   stmt varchar2(100);
   hname varchar2(20);
   uname varchar2(20);
begin
	select sys_context('USERENV','HOST'),
	sys_context('USERENV','SESSION_USER') 
	into hname,uname from dual;
	stmt := 'alter session set tracefile_identifier='||hname||'_'||uname; 
	EXECUTE IMMEDIATE stmt;  
	EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever,level 12'''; 
end;
/

-- --------------------------------------------------------------------
-- Logoff trigger - stops session trace
-- --------------------------------------------------------------------
create or replace trigger CVG_SESSION_TRACE_OFF
BEFORE LOGOFF ON DATABASE
when(user='GENEVA_ADMIN')
begin
	execute immediate 'alter session set events ''10046 trace name context off''';
end;
/

-- --------------------------------------------------------------------
-- Logon trigger - starts PX trace
-- --------------------------------------------------------------------
create or replace trigger CVG_PXTRACE_ON
AFTER LOGON ON DATABASE
WHEN (USER='GENEVA_ADMIN')
declare
   stmt varchar2(100);
   hname varchar2(20);
   uname varchar2(20);
begin
	select sys_context('USERENV','HOST'),
	sys_context('USERENV','SESSION_USER') 
	into hname,uname from dual;
	stmt := 'alter session set tracefile_identifier= PXTRACE_'||hname||'_'||uname; 
	EXECUTE IMMEDIATE stmt;  
	EXECUTE IMMEDIATE 'alter session set "_px_trace"="compilation","low"';
end;
/

-- --------------------------------------------------------------------
-- Logoff trigger - stops PX trace
-- --------------------------------------------------------------------
create or replace trigger CVG_PXTRACE_OFF
BEFORE LOGOFF ON DATABASE
when(user='GENEVA_ADMIN')
begin
	EXECUTE IMMEDIATE 'alter session set "_px_trace"="none"';
end;
/

-- --------------------------------------------------------------------
-- Trace switches
-- --------------------------------------------------------------------
-- Enable trigger with:
alter trigger geneva_admin.CVG_SESSION_TRACE_ON enable;
alter trigger geneva_admin.CVG_SESSION_TRACE_OFF enable;
alter trigger geneva_admin.CVG_SESSION_TRACE_ON disable;
alter trigger geneva_admin.CVG_SESSION_TRACE_OFF disable;

alter trigger CVG_PXTRACE_ON enable;
alter trigger CVG_PXTRACE_OFF enable;
alter trigger CVG_PXTRACE_ON disable;
alter trigger CVG_PXTRACE_OFF disable;

select OWNER, TRIGGER_NAME, TRIGGER_TYPE, STATUS 
from dba_triggers
where TRIGGER_NAME like 'CVG%';

-- --------------------------------------------------------------------
-- Trace methods summary
-- --------------------------------------------------------------------
-- First three are the 'official' 9i methods which only allow trace at level 1:
-- init parameter sql_trace -- too wide scoped
-- dbms_session. set_sql_trace
-- dbms_system.set_sql_trace_in_session
-- Undocumented byut reliable versions are as follows:

-- alter session set events - 9i, own session only
-- ----------------------------------------------------------------------------
alter session set events '10046 trace name context forever,level 12';
alter session set events '10046 trace name context off';

-- dbms_system.set_ev - 9i, any session
-- ----------------------------------------------------------------------------
exec dbms_system.set_ev(428,2110,10046,12,'');
exec dbms_system.set_ev(428,2110,10046,0,'');

-- As of 10g several fully documented methods exist and should be used instead:

-- dbms_monitor.session_trace_enable - 10g+ - by default, comes with DBA role
-------------------------------------------------------------------------------
-- PROCEDURE SESSION_TRACE_ENABLE
-- Argument Name                  Type                    In/Out Default?
--  ------------------------------ ----------------------- ------ --------
--  SESSION_ID                     BINARY_INTEGER          IN     DEFAULT
--  SERIAL_NUM                     BINARY_INTEGER          IN     DEFAULT
--  WAITS                          BOOLEAN                 IN     DEFAULT
--  BINDS                          BOOLEAN                 IN     DEFAULT
--  PLAN_STAT                      VARCHAR2                IN     DEFAULT

-- pre-trace
alter session set tracefile_identifier='up_to_255_chars'; -- {inst_name}_{process_name}_{process_id}_{tracefile_id_if_set}.trc
alter session set max_dump_file_size=unlimited;

exec dbms_monitor.session_trace_enable(428,2110,TRUE,TRUE); -- pass null, null for serial/sid
exec dbms_monitor.session_trace_disable(428,2110);

-- At 11g
select * from v$diag_info;

-- --------------------------------------------------------------------
-- Trace SQL statement
-- --------------------------------------------------------------------
http://oraclue.com/2009/03/24/oracle-event-sql_trace-in-11g/
http://blog.tanelpoder.com/2010/06/23/the-full-power-of-oracles-diagnostic-events-part-2-oradebug-doc-and-11g-improvements/
http://tech.e2sn.com/oracle/troubleshooting/oradebug-doc

alter session set events 'sql_trace [sql_id]';
--or
alter session set events 'sql_trace [sql_id|sql_id]';

--example
alter session set events 'sql_trace [707wu2umpfas7],wait=true,bind=true';
-- run query
alter session set events 'sql_trace [707wu2umpfas7]'off;

-- --------------------------------------------------------------------
-- Trace file analysis
-- --------------------------------------------------------------------
-- Interpreting Raw SQL_TRACE output [ID 39817.1]		

-------------------------------------------------------------------------------
-- OS Watcher
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- TKPROF
-------------------------------------------------------------------------------
DATABASE=trcuser/trcuser@tsgtest
RATE -a "-plugInPath '/Disk1/home/tsgtest/work/lib/RMFP.so' -commitSize 100 -bufferSize 110"

TRCUSER@TSGTEST > @?/rdbms/admin/utlxplan
tkprof tsgtest_ora_16329_HOCPI03N_TRCUSER.trc rate.out EXPLAIN=geneva_admin/geneva table=trcuser.plan_table SYS=NO sort=PRSELA, EXEELA, FCHELA 
tkprof file.trc reclaim-update.out EXPLAIN=$DATABASE sort=PRSELA,EXEELA,FCHELA
tkprof file.trc EXPLAIN=geneva_admin/geneva01

PRSELA, EXEELA, FCHELA - elapsed - (always use this according to Antognini)
PRSCPU, EXECPU, FCHCPU - cpu
PRSDSK, EXEDSK, FCHDSK - PIOs

SORT - Sorts traced SQL statements in descending order of specified sort option before listing them into the output file. If more than one option is specified, then the output is sorted in descending order by the sum of the values specified in the sort options. If you omit this parameter, then TKPROF lists statements into the output file in order of first use.

-------------------------------------------------------------------------------
-- OraSRP
-------------------------------------------------------------------------------
-- http://oracledba.ru/orasrp/

orasrp.exe --google-charts "X:\project\BT\retail-avalon\custom-BDD\v2\voip_ora_22475.trc" tsttrc.html
orasrp.exe --text "X:\project\BT\retail-avalon\custom-BDD\v2\voip_ora_22475.trc" tsttrc.txt

-------------------------------------------------------------------------------
-- TDV$XTAT
-------------------------------------------------------------------------------
-- from: http://antognini.ch/top/downloadable-files/

/home/cmccarta/personal/scripts/database/trace/TDVXTAT/tvdxtat -i "X:\project\BT\retail-avalon\custom-BDD\v2\voip_ora_22475.trc" -o tsttrc.html

-------------------------------------------------------------------------------
-- TRACE_REPORT
-------------------------------------------------------------------------------
-- by Brian Lomasky

/emea/ipg/personal/cmccarta/scripts/database/trace/trace_report /Disk1/app/oracle/admin/TSGTEST/udump/tsgtest_ora_16329_HOCPI03_TRCUSER.trc

-> tsgtest_ora_16329_HOCPI03N_TRCUSER.lst

-------------------------------------------------------------------------------
-- TRACE ANALYZER
-------------------------------------------------------------------------------
-- Note:224270.1 - Trace Analyzer TRCANLZR - Interpreting Raw SQL Traces with Binds and/or Waits generated by EVENT 10046

cd /emea/ipg/personal/cmccarta/scripts/database/trace/trca/run 
sqlplus trcuser/trcuser (user that generated the trace)
@trcanlzr.sql tsgtest_ora_16329_HOCPI03N_TRCUSER.trc (trc file has to be in input dir - udump in this case)
...copying trcanlzr report into local SQL*Plus client directory
...trcanlzr report was copied from server into local SQL*Plus directory
TRCUSER@TSGTEST > !ls
trcanlzr.log           trcanlzr.sql           trcanlzr_16329_1.html

TRCUSER@TSGTEST > Disconnected from Oracle Database 10g Enterprise Edition Release 10.2.0.3.0 - 64bit Production
With the Partitioning and Data Mining options
tsgtest@hocpi03n[TSGTEST] /emea/ipg/personal/cmccarta/scripts/database/trace/trca/run > lt
total 2608
-rwxrwxrwx   1 cmccarta   generic      13941 Mar  5 14:04 trcanlzr.sql
drwxrwxrwx   6 cmccarta   generic       1024 Apr 18 12:23 ..
drwxrwxrwx   2 cmccarta   generic       1024 Apr 18 23:22 .
-rw-r--r--   1 tsgtest    other         4240 Apr 18 23:22 trcanlzr.log
-rw-r--r--   1 tsgtest    other      1280573 Apr 18 23:22 trcanlzr_16329_1.html


-------------------------------------------------------------------------------
-- SQLTXPLAIN 
-------------------------------------------------------------------------------
Note:215187.1 - 


-------------------------------------------------------------------------------
-- RB Tracing
-------------------------------------------------------------------------------
export TRACE_ALL=true
export TRACE_LEVEL = FULL
export TRACE_RATE=ON
export TRACE_DUL=ON
export TRACE_RDISC=ON

Name                                      Null?    Type
----------------------------------------- -------- ----------------------------
MESSAGE_DOMAIN                            NOT NULL VARCHAR2(16)
TRACE_STATUS                              NOT NULL VARCHAR2(3)
MESSAGE_DOMAIN_TYPE                       NOT NULL NUMBER(2)
MESSAGE_DOMAIN_DESC                                VARCHAR2(255)

insert into GERCONFIGURATION values ('ORACLE','ON',1,null);
insert into gerconfiguration (message_domain, trace_status, message_domain_type, message_domain_desc)
values ('DUL', 'ON', 1, 'Performance testing - inserted by CAM - 21APR2011');


-------------------------------------------------------------------------------
-- AWR reports
-------------------------------------------------------------------------------

awrrpt.sql      -- basic AWR report
awrsqrpt.sql    -- Standard SQL statement Report
 
awrddrpt.sql    -- Period diff on current instance
 
awrrpti.sql     -- Workload Repository Report Instance (RAC)
awrgrpt.sql     -- AWR Global Report (RAC)
awrgdrpt.sql    -- AWR Global Diff Report (RAC)
 
awrinfo.sql     -- Script to output general AWR information

For most people the awrrpt.sql and awrsqrpt.sql are likely to be sufficient, but the “difference between two periods” can be very useful – especially if you do things like regularly forcing an extra snapshot at the start and end of the overnight batch so that you can (when necessary) find the most significant differences in behaviour between the batch runs on two different nights.

If you get into the ‘RAC difference report’ you’ll need a very wide page – and very good eyesight !

There are also a lot of “infrastructure and support” bits – some of the “input” files give you some nice ideas about how you can write your own code to do little jobs like: “run the most recent AWR report automatically”:

awrblmig.sql    -- AWR Baseline Migrate
awrload.sql     -- AWR LOAD: load awr from dump file
awrextr.sql     -- AWR Extract
 
awrddinp.sql    -- Get inputs for diff report
awrddrpi.sql    -- Workload Repository Compare Periods Report
 
awrgdinp.sql    -- Get inputs for global diff reports
awrgdrpi.sql    -- Workload Repository Global Compare Periods Report
 
awrginp.sql     -- AWR Global Input
awrgrpti.sql    -- Workload Repository RAC (Global) Report
 
awrinpnm.sql    -- AWR INput NaMe
awrinput.sql    -- Get inputs for AWR report
 
awrsqrpi.sql    -- Workload Repository SQL Report Instance