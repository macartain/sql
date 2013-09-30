
-- --------------------------------------------------------------------
-- ASH 
-- --------------------------------------------------------------------
-- v$active_session_history - in-memory circular buffer - active sessions per second
-- 		- at 66% full or hourly records 1/10 samples to...
-- dba_hist_active_sess_history - defaults to 7 days history 

-- --------------------------------------------------------------------
-- ASH 
-- --------------------------------------------------------------------
-- most active SQL in last hour
select sql_id, count(*), round(count(*)/sum(count(*)) over (), 2)pctload
from v$active_session_history
where sample_time > sysdate -1/24
and session_type <> 'BACKGROUND'
group by sql_id
order by count(*) desc;

-- most I/O intensive SQL in last minute
select ash.sql_id, count(*) 
from v$active_session_history ash, v$event_name evt
where ash.sample_time > sysdate-1/24/60
and ash.session_state = 'WAITING'
and ash.event_id = evt.event_id
and evt.wait_class = 'User I/O'
group by sql_id
order by count(*) desc;

-- --------------------------------------------------------------------
-- common stuff
-- --------------------------------------------------------------------
-- metadata
@?/rdbms/admin/awrinfo

select min(sample_time), max(sample_time) 
from v$active_session_history;

select * from v$sgastat where name like 'ASH buffers';

select TO_DATE(min(sample_time), 'DDMONYYYY HH24:MI:SS'), TO_DATE(max(sample_time), 'DDMONYYYY HH24:MI:SS')
from  dba_hist_active_sess_history;

-- --------------------------------------------------------------------
-- blocked sessions?
-- --------------------------------------------------------------------

select SESSION_ID,dsh.SQL_ID,SESSION_STATE,BLOCKING_SESSION,EVENT,TIME_WAITED,dsh.MODULE, 
       dsh.sample_time, dsh.program, dsh.sql_id , dsh.sql_child_number,
       s.SQL_TEXT
from dba_hist_active_sess_history dsh, v$sql s 
where dsh.sql_id=s.SQL_ID(+)
and dsh.sql_child_number=s.CHILD_NUMBER(+)
and sample_time between TO_DATE('07/03/2013 16:10:00', 'DD/MM/YYYY HH24:MI:SS') and TO_DATE('07/03/2013 16:20:00', 'DD/MM/YYYY HH24:MI:SS')
order by sample_time;

select SESSION_ID,dsh.SQL_ID,SESSION_STATE,BLOCKING_SESSION,EVENT,TIME_WAITED,dsh.MODULE, 
       dsh.sample_time, dsh.program, dsh.sql_id , dsh.sql_child_number,
       s.SQL_TEXT
from dba_hist_active_sess_history dsh, v$sql s 
where dsh.sql_id=s.SQL_ID(+)
and dsh.sql_child_number=s.CHILD_NUMBER(+)
and session_id=118
order by sample_time;

-- --------------------------------------------------------------------
-- dump to trace
-- --------------------------------------------------------------------
alter session set events 'immediate trace nameashdumplevel 10';

-- 10 ==> minutes of history you want to dump
-- Generated file can be loaded into database using supplied control file rdbms/demo/ashldr.ctl

-- --------------------------------------------------------------------
-- report
-- --------------------------------------------------------------------
 @?/rdbms/admin/ashrpt

