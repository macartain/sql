-- ----------------------------------------------------------------------------
-- Check highest latches
-- ----------------------------------------------------------------------------
select name, gets, sleeps,
sleeps*100/sum(sleeps) over() sleep_pct, sleeps*100/gets sleep_rate
from v$latch where gets>0
order by sleeps desc;

-- ----------------------------------------------------------------------------
-- Get address of highest sleeps
-- ----------------------------------------------------------------------------
select * from (
	select CHILD#  "cCHILD"
	,      ADDR    "sADDR"
	,      GETS    "sGETS"
	,      MISSES  "sMISSES"
	,      SLEEPS  "sSLEEPS" 
	from v$latch_children 
	where name in ('cache buffers chains','resmgr:resource group CPU method')
	order by 5 desc, 1, 2, 3)
where rownum <11;

-- ----------------------------------------------------------------------------
-- Get segments -- needs DBA
-- ----------------------------------------------------------------------------
column segment_name format a35
select /*+ RULE */
  e.owner ||'.'|| e.segment_name  segment_name,
  e.extent_id  extent#,
  x.dbablk - e.block_id + 1  block#,
  x.tch,
  l.child#
from
  v$latch_children  l,
  x$bh  x,
  dba_extents  e
where
  x.hladdr  = 'C00000000E1FCEC0' and
  e.file_id = x.file# and
  x.hladdr = l.addr and
  x.dbablk between e.block_id and e.block_id + e.blocks -1
  order by x.tch desc ;