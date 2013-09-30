-- --------------------------------------------------------------------
-- Basics
-- --------------------------------------------------------------------
col meg for 999,999.99
select pool, name, bytes/(1024*1024) as meg from v$sgastat where pool is null;
select POOL, sum(bytes)/(1024*1024) as meg from v$sgastat group by pool;

-- from 11g
select * from v$sgainfo;

-- --------------------------------------------------------------------
-- Dynamic Mem target components - 11g+
-- --------------------------------------------------------------------
col COMPONENT for a35
col curr for 999,999
col minsz for 999,999
col maxsz for 999,999
col usersz for 999,999
col OPER_COUNT for 999,999,999
col GRANULE  for a8

select COMPONENT, 
	CURRENT_SIZE/(1024*1024) curr, 
	MIN_SIZE/(1024*1024) minsz, 
	MAX_SIZE/(1024*1024) maxsz, 
	USER_SPECIFIED_SIZE/(1024*1024) usersz, 
	OPER_COUNT, 
	LAST_OPER_TYPE type, 
	LAST_OPER_mode as opmode, 
	TO_CHAR(LAST_OPER_TIME,'DDMONYYYY-HH24:MI:SS') last_op, 
	GRANULE_SIZE/(1024*1024)||'K' granule
from v$memory_dynamic_components;
-- --------------------------------------------------------------------
-- Dynamic SGA components - 10g+
-- --------------------------------------------------------------------
col COMPONENT for a35
col curr for 999,999
col minsz for 999,999
col maxsz for 999,999
col usersz for 999,999
col OPER_COUNT for 999,999,999
col GRANULE  for a8

select COMPONENT, CURRENT_SIZE/(1024*1024) curr, MIN_SIZE/(1024*1024) minsz, MAX_SIZE/(1024*1024) maxsz, USER_SPECIFIED_SIZE/(1024*1024) usersz, OPER_COUNT, LAST_OPER_TYPE type, LAST_OPER_mode as opmode, TO_CHAR(LAST_OPER_TIME,'DDMONYYYY-HH24:MI:SS') last_op, GRANULE_SIZE/(1024*1024)||'K' granule
from v$sga_dynamic_components;

-- --------------------------------------------------------------------
-- Dynamic SGA components history - 10g+
-- --------------------------------------------------------------------
col COMPONENT for a30
col parameter for a22
col init for 999,999
col target for 999,999
col final for 999,999

select COMPONENT, OPER_TYPE, OPER_MODE, PARAMETER, INITIAL_SIZE/(1024*1024) init, TARGET_SIZE/(1024*1024) target, FINAL_SIZE/(1024*1024) final, STATUS, TO_CHAR(START_TIME,'DDMONYYYY-HH24:MI:SS') start_dtm,  TO_CHAR(END_TIME,'DDMONYYYY-HH24:MI:SS') finish
from V$SGA_RESIZE_OPS
--where COMPONENT='java pool'
;

select * from V$SGA_DYNAMIC_FREE_MEMORY;

-- --------------------------------------------------------------------
-- Failure history - shared pool
-- --------------------------------------------------------------------
COL REQUEST_FAILURES  FOR 999,999     HEA "request|failures"
COL LAST_FAILURE_SIZE FOR 999,999,999 HEA "last   |failure  |size   "
col "free(M)" for 999,999.99
col "used(M)" for 999,999.99
col avg_free_size for 999,999.99
col avg_used_size for 999,999.99
col last_failure_size for 999,999,999.99
select free_space/(1024*1024) as "free(M)"
      ,avg_free_size
      ,used_space/(1024*1024) as "used(M)"
      ,avg_used_size
      ,request_failures
      ,last_failure_size
      ,TO_CHAR(SYSDATE,'DDMONYYYY-HH24:MI:SS') tstamp
  from v$shared_pool_reserved;

-- --------------------------------------------------------------------
-- contents of SP
-- --------------------------------------------------------------------
select * from (
    select POOL, NAME, BYTES, BYTES/1048576 as MBytes
    from v$sgastat
    where pool='shared pool'
    order by BYTES desc )
where rownum <= 25;

select * from V$LIBRARY_CACHE_MEMORY;

-- --------------------------------------------------------------------
-- Dynamic components - 9i
-- --------------------------------------------------------------------
col COMPONENT for a35
col curr for 999,999
col minsz for 999,999
col maxsz for 999,999
col OPER_COUNT for 999,999,999
col GRANULE  for a8

select COMPONENT, CURRENT_SIZE/(1024*1024) curr, MIN_SIZE/(1024*1024) minsz, MAX_SIZE/(1024*1024) maxsz, OPER_COUNT, LAST_OPER_TYPE type, LAST_OPER_mode as opmode, TO_CHAR(LAST_OPER_TIME,'DDMONYYYY-HH24:MI:SS') last_op, GRANULE_SIZE/(1024*1024)||'K' granule
from v$sga_dynamic_components;

-- --------------------------------------------------------------------
-- PGA stats
-- --------------------------------------------------------------------
select * from v$pgastat;

-- --------------------------------------------------------------------
-- Common tasks
-- --------------------------------------------------------------------
-- 396940.1 - Troubleshooting and Diagnosing ORA-4031 Error
-- 430473.1 - ORA-4031 Common Analysis/Diagnostic Scripts

alter system flush shared_pool; -- quick fix

-- --------------------------------------------------------------------
-- 9i Mem mgmt
-- --------------------------------------------------------------------
-- DB_CACHE_SIZE initialization parameter replaces the DB_BLOCK_BUFFERS (latter will still work but not dynamic).
-- SHARED_POOL_SIZE
-- LARGE_POOL_SIZE
--
-- You can dynamically alter the initialization parameters affecting the size of the buffer caches, shared pool, and large pool, but only
-- to the extent that the sum of these sizes and the sizes of the other components of the SGA (fixed SGA, variable SGA, and redo log buffers)
-- does not exceed the value specified by SGA_MAX_SIZE.
--
-- IF YOU DO NOT SPECIFY SGA_MAX_SIZE, THEN ORACLE SELECTS A DEFAULT VALUE THAT IS THE SUM OF ALL COMPONENTS SPECIFIED OR DEFAULTED AT INITIALIZATION TIME.
--
-- http://download.oracle.com/docs/cd/B10501_01/server.920/a96533/memory.htm#PFGRF014

-- --------------------------------------------------------------------
-- 11g Mem mgmt
-- --------------------------------------------------------------------
-- 11.1 docs: http://download.oracle.com/docs/cd/B28359_01/server.111/b28274/memory.htm
-- 
-- AMM - MEMORY_TARGET and MEMORY_MAX_TARGET - balances memory between SGA and instance PGAs
-- 
-- ASMM - SGA_TARGET has to be non-zero and STATISTICS_LEVEL= TYPICAL/ALL. Must be less than SGA_MAX_SIZE
-- sets:
-- 		buffer cache (default)	DB_CACHE_SIZE
-- 		Shared pool				SHARED_POOL_SIZE & SHARED_POOL_RESERVED_SIZE
-- 		Large pool				LARGE_POOL_SIZE
-- 		Java pool				JAVA_POOL_SIZE
-- 		Streams pool			STREAMS_POOL_SIZE
-- Non-zero values for above will set minimums.
-- NOT set:
-- 		Log buffer				LOG_BUFFER
-- 		Other buffer caches 	DB_KEEP_CACHE_SIZE, DB_RECYCLE_CACHE_SIZE, DB_nK_CACHE_SIZE
-- 		Fixed SGA and other internal allocations
-- These are set manually and The memory allocated to these pools is deducted from the total available for SGA_TARGET when Automatic Shared Memory 
-- Management computes the values of the automatically tuned memory pools. 
-- 
-- ASMM is disabled by setting sga_target=0 at startup. SGA_MAX_SIZE defaults to the aggregate setting of all the components.
-- 
