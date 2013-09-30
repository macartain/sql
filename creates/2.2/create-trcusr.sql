-- Create the user
create user trcusr
identified by "trcusr"
default tablespace DATA
temporary tablespace TEMP
profile DEFAULT;
-- Grant/Revoke object privileges
grant select on SYS.DBA_PROFILES to trcusr with grant option;
grant select on SYS.DBA_ROLES to trcusr;
grant select on SYS.DBA_ROLE_PRIVS to trcusr;
grant select on SYS.DBA_TABLESPACES to trcusr with grant option;
grant select on SYS.DBA_TAB_PRIVS to trcusr;
grant select on SYS.DBA_USERS to trcusr with grant option;
grant execute on SYS.DBMS_ALERT to trcusr;
grant execute on SYS.DBMS_AQ to trcusr with grant option;
grant execute on SYS.DBMS_AQADM to trcusr;
grant execute on SYS.DBMS_AQ_BQVIEW to trcusr;
grant execute on SYS.DBMS_PIPE to trcusr;
-- Grant/Revoke role privileges
grant connect to trcusr;
grant dba to trcusr;
-- Grant/Revoke system privileges
grant alter session to trcusr;
grant alter tablespace to trcusr;
grant create role to trcusr;
grant create sequence to trcusr;
grant create table to trcusr;
grant grant any role to trcusr;
grant unlimited tablespace to trcusr;

-- Set up logging tables

create table trcusr.session_event_history 
tablespace USERS
as 
select b.sid,
       b.serial#,
       b.username,
       b.osuser,
       b.paddr,
       b.process,
       b.program,
       b.logon_time,
       b.type,
       a.event,
       a.total_waits,  
       a.total_timeouts, 
       a.time_waited, 
       a.average_wait, 
       a.max_wait, 
       sysdate as logoff_timestamp
from   v$session_event a, v$session b
where  1 = 2;

create table ulog 
tablespace USERS
as 
select username,
	   sid as logsid,
	   program,
       sysdate as logon_time
from v$session
where 1=2;

-- select username, logsid, program, to_char(logon_time, 'MM-DD-YYYY HH24:MI:SS') from ulog order by logon_time asc;

create table sesstat_history 
tablespace users
as
select c.username, 
       c.osuser,
       a.sid,
       c.serial#,
       c.paddr,
       c.process,
       c.logon_time,
       a.statistic#,
       b.name,
       a.value,
       sysdate as logoff_timestamp
from   v$sesstat a, v$statname b, v$session c
where  1 = 2;


-- create trigger

create or replace trigger trcusr.logoff_trig
before logoff on database
declare
  logoff_sid    pls_integer;
  logoff_time   date         := sysdate;
begin
  select sid 
  into   logoff_sid 
  from   v$mystat
  where  rownum < 2;

  insert into trcusr.session_event_history
        (sid, serial#, username, osuser, paddr, process,
         logon_time, type, event, total_waits, total_timeouts, 
         time_waited, average_wait, max_wait, logoff_timestamp)
  select a.sid, b.serial#, b.username, b.osuser, b.paddr, b.process,
         b.logon_time, b.type, a.event, a.total_waits, a.total_timeouts,
         a.time_waited, a.average_wait, a.max_wait, logoff_time
  from   v$session_event a, v$session b
  where  a.sid      = b.sid
  and    b.username = login_user
  and    b.sid      = logoff_sid;
  
  end;
  /
