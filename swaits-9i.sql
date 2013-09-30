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
order by LOGON_TIME desc
/