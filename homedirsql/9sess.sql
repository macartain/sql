set pages 200
set lines 180
col user for a13 trunc
col osuser for a12 trunc
COL "SID,serial" FOR A10
col status FOR a10
COL "ps PID" FOR A10 trunc
COL "Shadow PID" FOR A8
COL PROGRAM FOR A26 trunc
col child for 999 trunc

SELECT nvl(vs.username, '-') "user", osuser, vs.sid||','||vs.serial# "SID,serial", process "ps PID", type, status, vs.PROGRAM, vp.spid "Shadow PID", TO_CHAR(LOGON_TIME,'DDMON-hh24:mi:ss') logon
from v$session vs 
	full outer join v$process vp on vs.paddr = vp.addr
order by LOGON_TIME desc
/
