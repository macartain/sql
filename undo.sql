-- --------------------------------------------------------------------
-- undo history
-- --------------------------------------------------------------------
col mxtim for 999,999.99 heading "longest txn|time (mins)"
select TO_CHAR(BEGIN_TIME, 'YYYYMONDD-HH24:MI') begin_tm, undotsn, undoblks, txncount, 
maxquerylen/60 as mxtim, maxconcurrency as maxcon, nospaceerrcnt, TUNED_UNDORETENTION 
from v$undostat
-- for last hour
-- where begin_time > sysdate-(1/24)
order by BEGIN_TIME;

-- --------------------------------------------------------------------
-- undo segment status
-- --------------------------------------------------------------------
-- summary - system-wide
select status,
  round(sum_bytes / (1024*1024), 0) as MB,
  round((sum_bytes / undo_size) * 100, 0) as PERC
from
( select status, sum(bytes) sum_bytes
  from dba_undo_extents
  group by status),
(select sum(a.bytes) undo_size
  from dba_tablespaces c
    join v$tablespace b on b.name = c.tablespace_name
    join v$datafile a on a.ts# = b.ts#
  where c.contents = 'UNDO'
    and c.status = 'ONLINE'
);

-- by tablespace
SELECT tablespace_name, STATUS, SUM(BYTES)/(1024*1024) as mb, COUNT(*)   
   FROM DBA_UNDO_EXTENTS 
   GROUP BY tablespace_name, STATUS;  

-- detail
select tablespace_name, segment_name, blocks, bytes/1024, status
from dba_undo_extents
where upper(tablespace_name) like '%UNDO%'
--and rownum <30
;

-- old skool?
col usn for 999
col shrinks for 999,999
col extends for 999,999 	
select usn, extents, rssize, hwmsize, shrinks, extends, status 
from v$rollstat;

-- --------------------------------------------------------------------
-- estimate recovery timne
-- --------------------------------------------------------------------
select usn, state, undoblockstotal "Total", undoblocksdone "Done"
,	undoblockstotal-undoblocksdone "ToDo"
,	decode(cputime,0,'unknown',sysdate+(((undoblockstotal-undoblocksdone) /(undoblocksdone / cputime)) / 86400))  "Estimated time to complete"
from v$fast_start_transactions;

--Find the active transactions using undo extents
SELECT s.username, t.xidusn, t.ubafil, t.ubablk, t.used_ublk
FROM v$session s, v$transaction t
WHERE s.saddr = t.ses_addr;

-- more detail?
col sid_serial for a15
col ORAUSER for a12
col UNDOSEG for a18
col Undo for 999,999,999
SELECT TO_CHAR (s.SID) || ',' || TO_CHAR (s.serial#) sid_serial,
NVL (s.username, 'None') orauser, s.program, r.NAME undoseg,
t.used_ublk * TO_NUMBER (x.VALUE) / 1024 || 'K' "Undo",
t1.tablespace_name
FROM SYS.v_$rollname r,
SYS.v_$session s,
SYS.v_$transaction t,
SYS.v_$parameter x,
dba_rollback_segs t1
WHERE s.taddr = t.addr
AND r.usn = t.xidusn(+)
AND x.NAME = 'db_block_size'
AND t1.segment_id = r.usn
AND t1.tablespace_name like 'UNDO%';
