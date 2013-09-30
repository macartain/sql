set pages 20
col sid FOR a10
col opname FOR a20 word_wrap
col target FOR a25
col progress FOR a25
col message FOR a80 word_wrap
col remain for 999
col mins for 999
col prog for a4
col qcsid for 9999

-- select sid||','||serial# sid, sofar || '/' || totalwork || ' ' || units as progress, (100/(totalwork/sofar)) || '%' as prog,
select sid||','||serial# sid, qcsid, SQL_ID, sofar || '/' || totalwork || ' ' || units as progress,
to_char(start_time,'MONDD-hh24:mi:ss') strt,
to_char(last_update_time, 'MONDD-hh24:mi:ss') updat,
time_remaining/60 as remain, elapsed_seconds/60 as mins, message
from V$SESSION_LONGOPS
order by last_update_time
/
