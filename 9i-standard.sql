-- --------------------------------------------------------------------
-- swaits
-- --------------------------------------------------------------------
set pages 200
set lines 180
col user for a13
col osuser for a14
COL "SID,serial" FOR A10
col status FOR a10
COL "OS PID" FOR A12
COL PROGRAM FOR A35
col event for a30
col wt for 999,999
col sql_text for a45 trunc
SELECT TO_CHAR(LOGON_TIME,'dd/mm hh24:mm:ss') logon, nvl(vs.username, '-') "user", osuser, vs.sid||','||vs.serial# "SID,serial",  vs.PROGRAM, SECONDS_IN_WAIT as wt,   event, sql_text
from v$session vs full outer join v$process vp
on vs.paddr = vp.addr
join v$session_wait sw on sw.sid=vs.sid
left join v$sqlarea sq on vs.sql_hash_value = sq.hash_value
order by LOGON_TIME desc;

-- --------------------------------------------------------------------
-- longops
-- --------------------------------------------------------------------

select sid||','||serial# sid, qcsid, sofar || '/' || totalwork || ' ' || units as progress,
to_char(start_time,'MONDD-hh24:mi:ss') strt,
to_char(last_update_time, 'MONDD-hh24:mi:ss') updat,
time_remaining/60 as remain, elapsed_seconds/60 as mins, message
from V$SESSION_LONGOPS
order by last_update_time

-- --------------------------------------------------------------------
-- sessi	ons  
-- --------------------------------------------------------------------
select sesion.sid,
       sesion.username,
       optimizer_mode,
       hash_value,
       address,
       cpu_time,
       elapsed_time,
       sql_text
  from v$sqlarea sqlarea, v$session sesion
 where sesion.sql_hash_value = sqlarea.hash_value
   and sesion.sql_address    = sqlarea.address
   and sesion.username is not null

-- --------------------------------------------------------------------
-- sundo  
-- --------------------------------------------------------------------
select TO_CHAR(BEGIN_TIME, 'ddmonyy-HH24:MI') begin_tm, TO_CHAR(end_time, 'ddmonyy-HH24:MI') end_tm
, undotsn, undoblks, txncount, maxquerylen/60 as mxtim, maxconcurrency as maxcon, nospaceerrcnt
from v$undostat
-- for last hour
-- where begin_time > sysdate-(1/24)
order by BEGIN_TIME
