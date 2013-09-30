select to_char(snap_time,'mm/dd/yyyy hh24:mi:ss') snaptime
, max(decode(event,'db file scattered read', nvl(wait_ms,0), null)) wait_ms_dbfscatrd
, max(decode(event,'db file sequential read',nvl(wait_ms,0), null)) wait_ms_dbfseqrd
, max(decode(event,'db file scattered read', nvl(waits,0), null)) waits_dbfscatrd
, max(decode(event,'db file sequential read',nvl(waits,0), null)) waits_dbfseqrd
from
(
select ps.snap_time
, event
, case
when (total_waits - lag_total_waits > 0)
then round(( (time_waited_micro - lag_time_waited_micro) / (total_waits - lag_total_waits)) / 1000)
else -1
end wait_ms
, (total_waits - lag_total_waits) waits
, (time_waited_micro - lag_time_waited_micro) time_waited
from (
select se.snap_id
, event
, se.total_waits
, se.total_timeouts
, se.time_waited_micro
, lag(se.event) over (order by snap_id, event) lag_event
, lag(se.snap_id) over (order by snap_id, event) lag_snap_id
, lag(se.total_waits) over (order by snap_id, event) lag_total_waits
, lag(se.total_timeouts) over (order by snap_id, event) lag_total_timeouts
, lag(se.time_waited_micro) over (order by snap_id, event) lag_time_waited_micro
from perfstat.stats$system_event se
where event = 'db file sequential read'
and snap_id in (select snap_id from stats$snapshot
where snap_time > trunc(sysdate) - 1
)
union all
select se.snap_id
, event
, se.total_waits
, se.total_timeouts
, se.time_waited_micro
, lag(se.event) over (order by snap_id, event) lag_event
, lag(se.snap_id) over (order by snap_id, event) lag_snap_id
, lag(se.total_waits) over (order by snap_id, event) lag_total_waits
, lag(se.total_timeouts) over (order by snap_id, event) lag_total_timeouts
, lag(se.time_waited_micro) over (order by snap_id, event) lag_time_waited_micro
from perfstat.stats$system_event se
where event = 'db file scattered read'
and snap_id in (select snap_id from stats$snapshot
where snap_time > trunc(sysdate) -1
)
order by event, snap_id
) a
, perfstat.stats$snapshot ss
, perfstat.stats$snapshot ps
where a.lag_snap_id = ps.snap_id
and a.snap_id = ss.snap_id
and a.lag_total_waits != a.total_waits
and a.event = a.lag_event
order by a.snap_id, event
)
group by snap_time
;