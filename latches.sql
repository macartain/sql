-- --------------------------------------------------------------------
-- open latches
-- --------------------------------------------------------------------
SELECT W.SID,   L.NAME
FROM V$SESSION_WAIT W,   V$LATCHNAME L
WHERE
   W.EVENT LIKE 'latch%' AND
   W.P2 = L.LATCH# AND
   W.STATE = 'WAITING';

-- --------------------------------------------------------------------
-- latches most waited on
-- --------------------------------------------------------------------
SELECT * FROM (SELECT NAME, WAIT_TIME FROM V$LATCH
ORDER BY WAIT_TIME DESC) WHERE ROWNUM <= 10;

-- --------------------------------------------------------------------
-- concurrency-related objects
-- --------------------------------------------------------------------
SELECT * FROM
(SELECT
     ROUND(CONCURRENCY_WAIT_TIME / 1000000)
       "CONCURRENCY WAIT TIME (S)",
     EXECUTIONS
     SQL_ID,
     SQL_TEXT
   FROM
     V$SQLSTATS
   ORDER BY CONCURRENCY_WAIT_TIME DESC )
WHERE ROWNUM <=10;

-- --------------------------------------------------------------------
-- other
-- --------------------------------------------------------------------
set pages 200
set lines 180
col name for a60
SELECT x.file#, name, dbablk, class, state, tch 
FROM x$bh x, v$datafile v
WHERE v.file# = x.file#
and hladdr in (
	SELECT addr
	FROM v$latch_children
	WHERE sleeps>10000
	and latch# in (
		SELECT latch#
	    FROM v$latch
	   	WHERE sleeps>100000
	   	)
)
and tch > 0
order by tch desc, x.file#;

SELECT latch#
    FROM v$latch
   WHERE sleeps>100000
   
   
SELECT addr, latch#, gets, misses, sleeps
FROM v$latch_children
WHERE sleeps>10000
and latch# in (
SELECT latch#
    FROM v$latch
   WHERE sleeps>100000
) order by sleeps desc;

select n.name,s.value from v$statname n, v$sysstat s
where n.STATISTIC#=s.STATISTIC#
and n.name like '%sort%'; 

select count(*) from v$latch_children
where name = 'cache buffers chains';

-- --------------------------------------------------------------------
-- Latch info - see http://www.saptechies.com/faq-oracle-latches/
-- --------------------------------------------------------------------
-- 
-- V$LATCH: Provides an overview of the latch waits since the system was started.
-- 
--     NAME: The name of the latch.
--     GETS: The number of "Willing to Wait" requests.
--     MISSES: The number of "Willing to Wait" requests that could not allocate the latch in the first attempt.
--     SPIN_GETS: The number of "Willing to Wait" requests that could allocate the latch in the first spinning without sleep periods.
--     SLEEPS: The number of "Willing to Wait" requests where the process has entered a sleep period at least once.
--     SLEEP1: The number of "Willing to Wait" requests with exactly one sleep.
--     SLEEP2: The number of "Willing to Wait" requests with exactly two sleeps.
--     SLEEP3: The number of "Willing to Wait" requests with exactly three sleeps.
--     SLEEP4: The number of "Willing to Wait" requests with four or more sleeps.
--     IMMEDIATE_GETS: The number of "Immediate" requests.
--     IMMEDIATE_MISSES: The number of "Immediate" requests where the latch could not be allocated on the first attempt.
--     WAIT_TIME: The combined sleep times of the latch (as of Oracle 9i).
-- 
-- V$LATCHHOLDER: Provides an overview over the currently held latches.
-- 
--     PID     : Oracle PID <opid> of the process that holds the latch.
--     SID: Oracle SID of the session that holds the latch.
--     NAME: The name of the held latch.
-- 
-- V$LATCHNAME: Provides an overview of the names of all latches.
-- 
--     LATCH#: The number of the latch.
--     NAME: The name of the latch.
-- 
-- V$LATCH_MISSES: The number of sleeps and immediate misses, including the Oracle kernel area.
-- 
--     NWFAIL_COUNT: The number of immediate misses.
--     SLEEP_COUNT: The number of sleeps.
--     LOCATION: The Oracle kernel area that holds the requested latch.
-- 
-- V$LATCH_PARENT: Provides an overview of parent latch waits since the system was started.
-- 
--     This contains the same fields as V$LATCH.
-- 
-- V$LATCH_CHILDREN: Provides an overview of child latch waits since the system was started.
-- 
--     CHILD#: The number of the child latch.
--     All other fields are the same as in V$LATCH.
