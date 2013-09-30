col mxtim for 999,999.99 heading "longest txn|time (mins)"
col maxcon heading "max|concurrent|txns"
select TO_CHAR(BEGIN_TIME, 'ddmonyy-HH24:MI') begin_tm, TO_CHAR(end_time, 'ddmonyy-HH24:MI') end_tm
, undotsn, undoblks, txncount, maxquerylen/60 as mxtim, maxconcurrency as maxcon, nospaceerrcnt 
from v$undostat
-- for last hour
-- where begin_time > sysdate-(1/24)
order by BEGIN_TIME;

