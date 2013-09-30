-- -------------------------------------------------------------------------------
-- longops enhanced
-- -------------------------------------------------------------------------------
set pages 40
col sid FOR a10
col opname FOR a20 word_wrap
col target FOR a25
col progress FOR a25                            
col message FOR a40 word_wrap
col remain for 999999
col mins for 999
col perc for a4

select vs.sid||','||vs.serial# sid, vs.OSUSER, vs.PROGRAM,
vsl.sofar || '/' || vsl.totalwork || ' ' || vsl.units as progress, 
-- (100/(vsl.totalwork/vsl.sofar)) || '%' as prog,
to_char(vsl.start_time,'dd-mon-yy hh24:mi:ss') startdtm,
to_char(vsl.last_update_time, 'dd-mon-yy hh24:mi:ss') endtm,
vsl.time_remaining/60 as remain, vsl.elapsed_seconds/60 as mins, vsl.message
from V$SESSION_LONGOPS vsl, v$session vs
where vsl.SID=vs.SID
-- and vs.PROGRAM like '%P0%'
-- and vsl.TIME_REMAINING > 0
-- and vs.sid=134
order by program, vsl.START_TIME desc;
