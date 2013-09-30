set lines 180
col id for 99 trunc
COL "SID,serial" FOR A10
col user for a10
col osuser for a10
COL "OS PID" FOR A12
col sql_text for a23 trunc
col secs_waited for 999,999
col state for a13 trunc
col wait_object for a12 trunc
col prog for a21 trunc

select a.inst_id ID, a.sid||','||a.serial# "SID,serial",substr(a.username,1,10) usr,substr(osuser,1,10) osuser, substr(a.program,1,21) prog,
TO_CHAR(LOGON_TIME,'DDMONYY-HH24:MI') logon,substr(event,1,30) evnt,
SECONDS_IN_WAIT secs_waited, state, a.sql_id,object_name wait_object,sql_text
from gv$session a,gv$process b , gv$sql s, dba_objects o
where a.paddr=b.addr
and a.sql_id=s.sql_id (+)
and a.row_wait_obj#=o.object_id (+)
and a.inst_id=b.inst_id
and s.inst_id=a.inst_id
and s.inst_id=b.inst_id
and lower(a.username) like '%&USERNAME%'
order by 1,3,4,5;
