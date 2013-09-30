-- --------------------------------------------------------------------
-- Decode enqueue type - from Shee et al.
-- --------------------------------------------------------------------
select sid, event, p1, p1raw,
    chr(bitand(P1,-16777216)/16777215)||chr(bitand(P1,16711680)/65535) type,
       mod(P1, 16) "MODE"
from   v$session_wait
where  event = 'enqueue';

-- --------------------------------------------------------------------
-- Who is locking who?
-- --------------------------------------------------------------------
select s1.username || '@' || s1.machine || ' ( SID=' || s1.sid || ' )  is blocking ' || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
from v$lock l1, v$session s1, v$lock l2, v$session s2
where s1.sid=l1.sid and s2.sid=l2.sid
and l1.BLOCK=1 and l2.request > 0
and l1.id1 = l2.id1
and l2.id2 = l2.id2 ;

-- --------------------------------------------------------------------
-- Session details
-- --------------------------------------------------------------------
select /*+ ordered */
       a.sid         blocker_sid,
       a.username    blocker_username,
       a.serial#,
       a.logon_time,
       b.type,
       b.lmode       mode_held,
       b.ctime       time_held,
       c.sid         waiter_sid,
       c.request     request_mode,
       c.ctime       time_waited
from   v$lock b, v$enqueue_lock c, v$session a
where  a.sid     = b.sid
and    b.id1     = c.id1(+)
and    b.id2     = c.id2(+)
and    c.type(+) = 'TX'
and    b.type    = 'TX'
and    b.block   = 1
order by time_held, time_waited;

-- --------------------------------------------------------------------
-- Blocked resource - if its a TX type 6
-- --------------------------------------------------------------------
select c.sid waiter_sid, a.object_name, a.object_type
from   dba_objects a, v$session b, v$session_wait c
where  (a.object_id = b.row_wait_obj# or
        a.data_object_id = b.row_wait_obj#)
and    b.sid       = c.sid
and    chr(bitand(c.P1,-16777216)/16777215) ||
       chr(bitand(c.P1,16711680)/65535) = 'TX'
and    c.event     = 'enqueue';

-- --------------------------------------------------------------------
-- Sys-wide ITL - if its a TX type 4 - ITL Shortage
-- --------------------------------------------------------------------
select owner,
       object_name,
       subobject_name,
       object_type,
       tablespace_name,
       value,
       statistic_name
from   v$segment_statistics
where  statistic_name = 'ITL waits'
and    value > 0
order by value;

-- --------------------------------------------------------------------
-- Lib cache pins
-- --------------------------------------------------------------------

SELECT sid, event, p1raw
  FROM sys.v_$session_wait
 WHERE event = 'library cache pin'
   AND state = 'WAITING';

-- execute the following query to find the library cache object being waited for.
-- doesn't seem to work - 9i only?
SELECT kglnaown AS owner, kglnaobj as Object
  FROM sys.x$kglob
 WHERE kglhdadr='&P1RAW';

-- or this from Shee - doesn't seem to work?
select s.sid, kglpnmod "Mode", kglpnreq "Req"
from   sys.x$kglpn p, v$session s
where  p.kglpnuse=s.saddr
and    kglpnhdl='&P1RAW';

-- --------------------------------------------------------------------
-- Lib cache lock - http://forums.oracle.com/forums/thread.jspa?threadID=516528
-- --------------------------------------------------------------------

select saddr from v$session where sid in (select sid from v$session_wait where event like 'library cache lock');

-- blocker session

SELECT SID,USERNAME,TERMINAL,PROGRAM FROM V$SESSION
WHERE SADDR in
(SELECT KGLLKSES FROM X$KGLLK LOCK_A
WHERE KGLLKREQ = 0
AND EXISTS (SELECT LOCK_B.KGLLKHDL FROM X$KGLLK LOCK_B
WHERE KGLLKSES = 'saddr_from_v$session above' /* BLOCKED SESSION */
AND LOCK_A.KGLLKHDL = LOCK_B.KGLLKHDL
AND KGLLKREQ > 0)
);

-- blocked session

SELECT SID,USERNAME,TERMINAL,PROGRAM FROM V$SESSION
WHERE SADDR in
(SELECT KGLLKSES FROM X$KGLLK LOCK_A
WHERE KGLLKREQ > 0
AND EXISTS (SELECT LOCK_B.KGLLKHDL FROM X$KGLLK LOCK_B
WHERE KGLLKSES = 'saddr_from_v$session above' /* BLOCKING SESSION */
AND LOCK_A.KGLLKHDL = LOCK_B.KGLLKHDL
AND KGLLKREQ = 0)
);

-- --------------------------------------------------------------------
-- Generic object access info? From Ian Baugaard.
-- --------------------------------------------------------------------
SELECT
   s.sid,
   s.serial#,
   s.username,
   s.machine,
   s.program,
   s.logon_time,
   a.name "COMMAND"
FROM v$session s, audit_actions a
-- WHERE s.sid in ( select sid from v$access where owner = 'GENEVA_ADMIN' and object = 'GNVPRDSECURITY' )
WHERE s.sid in ( select sid from v$access where owner = 'GENEVA_ADMIN')
AND username IS NOT NULL;

-- similar from https://netfiles.uiuc.edu/jstrode/www/oraview/V$ACCESS.html
select a.sid "Session Number",substr(s.username,1,10) "User",substr(a.owner,1,10) "Owner",
substr(a.object,1,30) "Object Being Accessed" from V$ACCESS a, V$SESSION s where a.sid = s.sid;

col program for a20
col osuser for a10
col object for a50
select to_char(LOGON_TIME,'DDMonYY HH24:MM') log_time,substr(a.program,1,15) program, a.terminal, substr(a.osuser,1,15) osuser,
rpad(substr(b.object,1,20), 20, ' ') || lpad(substr(b.type, 1, 12), 15, ' ') object
from V$SESSION a, V$ACCESS b where a.sid = b.sid order by LOGON_TIME;

-- --------------------------------------------------------------------
-- More Lib cache lock stuff - http://orainternals.wordpress.com/2009/06/02/library-cache-lock-and-library-cache-pin-waits/
-- -------------------------------------------------------------------

-- sessions in wait:
col username for a15
col machine for a15
col event for a15
col obj_owner for a15
col obj_name for a15
col sidser for a15
col PIN_CNT for 999
col PIN_mode for 999
col PIN_req for 999

select
 distinct
   ses.ksusenum||', '||ses.ksuseser sidser, ses.ksuudlna username,ses.ksuseunm machine,
   ob.kglnaown obj_owner, ob.kglnaobj obj_name
   ,pn.kglpncnt pin_cnt, pn.kglpnmod pin_mode, pn.kglpnreq pin_req
   , w.state, w.event, w.wait_Time, w.seconds_in_Wait
   -- lk.kglnaobj, lk.user_name, lk.kgllksnm,
   --,lk.kgllkhdl,lk.kglhdpar
   --,trim(lk.kgllkcnt) lock_cnt, lk.kgllkmod lock_mode, lk.kgllkreq lock_req,
   --,lk.kgllkpns, lk.kgllkpnc,pn.kglpnhdl
 from
  x$kglpn pn,  x$kglob ob,x$ksuse ses
   , v$session_wait w
where pn.kglpnhdl in
(select kglpnhdl from x$kglpn where kglpnreq >0 )
and ob.kglhdadr = pn.kglpnhdl
and pn.kglpnuse = ses.addr
and w.sid = ses.indx
order by seconds_in_wait desc
/

-- lib cache lock details
select
 distinct
   ses.ksusenum sid, ses.ksuseser serial#, ses.ksuudlna username,KSUSEMNM module,
   ob.kglnaown obj_owner, ob.kglnaobj obj_name
   ,lk.kgllkcnt lck_cnt, lk.kgllkmod lock_mode, lk.kgllkreq lock_req
   , w.state, w.event, w.wait_Time, w.seconds_in_Wait
 from
  x$kgllk lk,  x$kglob ob,x$ksuse ses
  , v$session_wait w
where lk.kgllkhdl in
(select kgllkhdl from x$kgllk where kgllkreq >0 )
and ob.kglhdadr = lk.kgllkhdl
and lk.kgllkuse = ses.addr
and w.sid = ses.indx
order by seconds_in_wait desc
/


