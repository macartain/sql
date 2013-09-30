-- --------------------------------------------------------------------
-- Instance waits
-- --------------------------------------------------------------------
set lines 200
set pages 120
col event for a48
col secs_per_wait for 999,999.99
col wait_class for a16
select event, wait_class, total_waits, total_timeouts, round(time_waited/6000) MINS_WAITED, round(average_wait/100,2) secs_per_wait
from v$system_event
where round(average_wait/100,2) > 0
--and wait_class != 'Idle'
order by decode (event, 'SQL*Net message from client', -1, time_waited) desc;

-- --------------------------------------------------------------------
-- Instance waits - same but for 9i
-- --------------------------------------------------------------------
select event, total_waits, total_timeouts, round(time_waited/6000) MINS_WAITED, round(average_wait/100,2) secs_per_wait
from v$system_event
where round(average_wait/100,2) > 0
order by MINS_WAITED desc
;

-- --------------------------------------------------------------------
-- Instance waits since startup
-- --------------------------------------------------------------------
select *
from v$system_event
where event like '%wait%'
order by 4 desc;

-- --------------------------------------------------------------------
-- Current wait per session (swaits)
-- --------------------------------------------------------------------
col evnt for a30
col usr for a10
col osuser for a14
col mach for a8
col prog for a20
col sid for 999
select sid,osuser,substr(a.username,1,10) usr,substr(a.program,1,20) prog,
TO_CHAR(LOGON_TIME,'dd/mm hh24:mm:ss') logon,sql_id,prev_sql_id,substr(event,1,30) evnt,pga_alloc_mem pga
from gv$session a,gv$process b where a.paddr=b.addr order by 2,5,1;

-- --------------------------------------------------------------------
-- Current wait per session (swaits) with sql
-- --------------------------------------------------------------------
col evnt for a45
col usr for a10
col osuser for a14
col mach for a8
col prog for a20
col sid for 999999
col sql for a40
select sid,osuser,substr(a.username,1,10) usr,substr(a.program,1,20) prog,TO_CHAR(LOGON_TIME,'dd/mm hh24:mm:ss') logon,a.sql_id,prev_sql_id,substr(event,1,45) evnt, substr(vs.SQL_FULLTEXT,1,40) sql
from gv$session a,gv$process b , v$sql vs
where a.paddr=b.addr
and vs.SQL_ID=a.sql_id
order by 2,5,1;

-- --------------------------------------------------------------------
-- Decode SQL (ssql)
-- --------------------------------------------------------------------
select SQL_FULLTEXT from v$sql where SQL_ID='&sql_id';

select * from table (dbms_xplan.display_cursor('&sql_id'));

-- --------------------------------------------------------------------
-- Similar for 9i (swaits)
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
-- Wait history per session
-- --------------------------------------------------------------------
col event for a35
col program for a35
SELECT se.sid, PROGRAM, se.event, time_waited,
round(time_waited*100/ SUM (time_waited) OVER(),2) wait_pct
FROM  v$session_event se, v$session s
where s.sid = se.sid
-- and program like '%BG%'
and s.sid=&SID
ORDER BY 1, 4 DESC;

-- --------------------------------------------------------------------
-- current  waits per session
-- --------------------------------------------------------------------
col event for a35
col program for a35
select s.SID, sw.SEQ#, sw.EVENT, sw.STATE, sw.SECONDS_IN_WAIT, PROGRAM
from v$session_wait sw, v$session s
where s.sid = sw.sid
and s.sid=393
-- and program like '%DUM%'
;

-- --------------------------------------------------------------------
-- Open cursors for session
-- --------------------------------------------------------------------
select SID, USER_NAME, SQL_TEXT from v$open_cursor where sid=194;

-- --------------------------------------------------------------------
-- I/O for session
-- --------------------------------------------------------------------
select * from v$sess_io where sid in (8,21);
select * from v$sess_io where sid in (select sid from v$session where program like '%ppro%');

-- --------------------------------------------------------------------
-- Stuck system
-- --------------------------------------------------------------------
col event for a65
break on report
compute sum of sessions
select event, count(*) sessions from v$session_wait
where state='WAITING'
group by event
order by 2 desc;

-- --------------------------------------------------------------------
-- Session time model
-- --------------------------------------------------------------------
COLUMN dbuser      HEADING "User"                         FORMAT A40;
COLUMN dbtim       HEADING "DB Elapsed|Time(sec)"         FORMAT 999,990.99;
COLUMN dbcpu       HEADING "DB CPU|Time(sec)"             FORMAT 999,990.99;
COLUMN jvtim       HEADING "Java|Time(sec)"               FORMAT 999,990.99;
COLUMN pltim       HEADING "PL/SQL|Time(sec)"             FORMAT 999,990.99;
COLUMN sqtim       HEADING "SQL|Time(sec)"                FORMAT 999,990.99;
COLUMN bktim       HEADING "Background|Time(sec)"         FORMAT 999,990.99;
--
SELECT DECODE(se.type,'BACKGROUND',se.program,se.username) dbuser,
       st.sid "SID",
       MAX(DECODE(stat_name,'DB time',st.value,null))/1000000 dbtim,
       MAX(DECODE(stat_name,'DB CPU',st.value,null))/1000000 dbcpu,
       MAX(DECODE(stat_name,'Java execution elapsed time',st.value,null))/1000000 jvtim,
       MAX(DECODE(stat_name,'PL/SQL execution elapsed time',st.value,null))/1000000 pltim,
       MAX(DECODE(stat_name,'sql execute elapsed time',st.value,null))/1000000 sqtim,
       MAX(DECODE(stat_name,'background elapsed time',st.value,null))/1000000 bktim
  FROM (
    SELECT sid,
           stat_name,
           value, 
           row_number() 
           OVER (PARTITION BY sid
                 ORDER BY stat_id) rn
      FROM v$sess_time_model
     WHERE stat_name IN
       ('DB time',
        'DB CPU',
        'Java execution elapsed time',
        'PL/SQL execution elapsed time',
        'sql execute elapsed time',
        'background elapsed time')
    ) st,
    v$session se
 WHERE se.sid = st.sid
 GROUP BY DECODE(se.type,'BACKGROUND',se.program,se.username),
       st.sid
 ORDER BY 4 DESC 
/

-- --------------------------------------------------------------------
-- Segment contribution to a given wait
-- --------------------------------------------------------------------
select segment_name,object_type,wait_type
from ( select owner||'.'||object_name as segment_name,object_type, value as wait_type
    from   v$segment_statistics
    where  statistic_name in ('enq: TX - index contention')
    order by wait_type desc)
where rownum <=10;

-- --------------------------------------------------------------------
-- who is querying via dblink?
-- --------------------------------------------------------------------
-- Courtesy of Tom Kyte, via Mark Bobak
-- this script can be used at both ends of the database link
-- to match up which session on the remote database started
-- the local transaction
-- the GTXID will match for those sessions
-- just run the script on both databases

Select /*+ ORDERED */
substr(s.ksusemnm,1,10)||'-'|| substr(s.ksusepid,1,10)      "ORIGIN",
substr(g.K2GTITID_ORA,1,35) "GTXID",
substr(s.indx,1,4)||'.'|| substr(s.ksuseser,1,5) "LSESSION" ,
s2.username,
substr(
   decode(bitand(ksuseidl,11),
      1,'ACTIVE',
      0, decode( bitand(ksuseflg,4096) , 0,'INACTIVE','CACHED'),
      2,'SNIPED',
      3,'SNIPED',
      'KILLED'
   ),1,1
) "S",
substr(w.event,1,10) "WAITING"
from  x$k2gte g, x$ktcxb t, x$ksuse s, v$session_wait w, v$session s2
where  g.K2GTDXCB =t.ktcxbxba
and g.K2GTDSES=t.ktcxbses
and s.addr=g.K2GTDSES
and w.sid=s.indx
and s2.sid = w.sid

-- --------------------------------------------------------------------
-- Current SID
-- --------------------------------------------------------------------
select sid, serial# from v$session where audsid = sys_context('userenv','sessionid');

select distinct sid from v$mystat;


select a.sid||','||a.serial# "SID,serial",substr(a.username,1,10) usr,substr(osuser,1,10) osuser, substr(a.program,1,21) prog,
TO_CHAR(LOGON_TIME,'DDMONYY-HH24:MI') logon,substr(event,1,30) evnt,
WAIT_TIME, SECONDS_IN_WAIT secs_in_wait, decode(state, 'WAITING','WAITING', 'On CPU/LIO'), 
a.sql_id,object_name wait_object
from gv$session a,gv$process b , gv$sql s, dba_objects o
where a.paddr=b.addr
and a.sql_id=s.sql_id (+)
and a.row_wait_obj#=o.object_id (+)
order by 2,3;

-- --------------------------------------------------------------------
-- riyaj shamsudeen query :
-- --------------------------------------------------------------------
-- Author: Riyaj Shamsudeen @OraInternals, LLC
--          www.orainternals.com
-- 
-- Functionality: This script is to print top ten sessions by logical reads, physical reads, parse calls, redo size and cpu used.
-- Uses Rank to find rank of a session and also shows its rank for other metrics.
-- --------------------------------------------------------------------

set lines 180 pages 40
col sid format 99999999
col program for a30
col value format 9,999,999,999,999,999,999
with lreads as (
	select  ses.sid, sum(ses.value) lrvalue from 
	v$sesstat ses , v$statname stat
	where stat.statistic#=ses.statistic# and
	stat.name in ('db block gets','consistent gets')
	--statistics# in  (40,41)
	group by ses.sid
	) ,
      preads as (
	select  ses.sid, sum(ses.value) prvalue from 
	v$sesstat ses , v$statname stat
	where stat.statistic#=ses.statistic# and
	stat.name in ('physical reads','physical reads direct')
	--statistics# in  (40,41)
	group by ses.sid),
      prsreads as (
	select  ses.sid, sum(ses.value) prsvalue from 
	v$sesstat ses , v$statname stat
	where stat.statistic#=ses.statistic# and	
	stat.name in ('parse count (total)','parse count (total)')
	--statistics# in  (40,41)
	group by ses.sid), 
      redosize as (
	select  ses.sid, sum(ses.value) redovalue from
	v$sesstat ses , v$statname stat
	where stat.statistic#=ses.statistic# and
	stat.name in ('redo size')
	--statistics# in  (40,41)
	group by ses.sid
     	), 
      cpuused as (
	select  ses.sid, ses.value cpuvalue from
	v$sesstat ses , v$statname stat
	where stat.statistic#=ses.statistic# and
	stat.name in ('CPU used by this session')
	--statistics# in  (40,41)
	)
select * from (
	select lreads.sid, vs.program, 
		lreads.lrvalue,rank () over (order by lrvalue desc) lrrank,
		preads.prvalue,rank () over (order by prvalue desc) prrank,
		prsreads.prsvalue,rank () over (order by prsvalue desc) prsrank,
		redosize.redovalue,rank () over (order by redovalue desc) redorank,
		cpuused.cpuvalue,rank () over (order by cpuvalue desc) cpurank
	from 
	   lreads, preads, prsreads, redosize, cpuused, v$session vs
	where lreads.sid=preads.sid and
	      preads.sid = prsreads.sid and
  	     lreads.sid =prsreads.sid and
	     lreads.sid =redosize.sid and
	     lreads.sid=cpuused.sid and
	     lreads.sid=vs.sid
 ) 
where lrrank < 11 or prrank <11 or prsrank <11 or redorank <11 or cpurank <11
order by lrrank
/