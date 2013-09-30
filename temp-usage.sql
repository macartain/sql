-- --------------------------------------------------------------------
-- Total temp consumption.
-- --------------------------------------------------------------------
SELECT   A.tablespace_name tablespace, D.mb_total,
         SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
         D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM     v$sort_segment A,
         (
         SELECT   B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
         FROM     v$tablespace B, v$tempfile C
         WHERE    B.ts#= C.ts#
         GROUP BY B.name, C.block_size
         ) D
WHERE    A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total;

-- --------------------------------------------------------------------
-- Temp segment usage per session.
-- --------------------------------------------------------------------
col osuser for a12 trunc
col sid_serial for a10 trunc
col sid_serial for a10 trunc
col program for a22 trunc
col module for a12 trunc
SELECT   S.sid || ',' || S.serial# sid_serial, S.username, S.osuser, P.spid, S.module,
         P.program, SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
         COUNT(*) statements
FROM     v$sort_usage T, v$session S, dba_tablespaces TBS, v$process P
WHERE    T.session_addr = S.saddr
AND      S.paddr = P.addr
AND      T.tablespace = TBS.tablespace_name
GROUP BY S.sid, S.serial#, S.username, S.osuser, P.spid, S.module,
         P.program, TBS.block_size, T.tablespace
ORDER BY program, osuser;

-- --------------------------------------------------------------------
-- Detail Temp segment usage per session.
-- --------------------------------------------------------------------
col SID for 9999
col User for a20 trunc
col Program for a20 trunc
col Tablespace for a25 trunc
col Object for a15 trunc
SELECT s.sid "SID",s.username "User",s.program "Program", u.tablespace "Tablespace",
u.contents "Contents", u.extents "Extents", u.blocks*8/1024 "Used Space in MB", 
a.object "Object", k.bytes/1024/1024 "Temp File Size"
FROM v$session s, v$sort_usage u, v$access a, dba_temp_files k, v$sql q
WHERE s.saddr=u.session_addr
and s.sql_address=q.address
and s.sid=a.sid
and u.tablespace=k.tablespace_name;

-- --------------------------------------------------------------------
-- Temp segment usage per session - shows SQL - 10g only!!
-- --------------------------------------------------------------------
col sql_text for a65 trunc
col SID for a10
col USERNAME for a12 trunc
col OSUSER for a12 trunc
col TABLESPACE for a15 trunc
col SIZE_MB for 999,999,999
select s.sid || ',' || s.serial# sid,
s.username,osuser, u.tablespace,
round(((u.blocks*p.value)/1024/1024),2) size_mb,
a.sql_id, a.sql_text
from v$sort_usage u,
v$session s,
v$sqlarea a,
v$parameter p
where s.saddr = u.session_addr
and a.address (+) = s.sql_address
and a.hash_value (+) = s.sql_hash_value
and p.name = 'db_block_size'
and s.username != 'SYSTEM'
group by
s.sid || ',' || s.serial#,
s.username,osuser,
a.sql_id, a.sql_text,
u.tablespace,
round(((u.blocks*p.value)/1024/1024),2)
order by 5 desc;

-- --------------------------------------------------------------------
-- Sort usage?!?
-- --------------------------------------------------------------------

SELECT (SELECT   nvl(SUM (v$sort_usage.blocks * dba_tablespaces.block_size), 0)/1024/1024
          FROM v$sort_usage, dba_tablespaces
         WHERE dba_tablespaces.tablespace_name = v$sort_usage.TABLESPACE
           AND v$sort_usage.session_addr = s.saddr) sort_space_mb,
       s.USERNAME, s.command
  FROM v$session s;