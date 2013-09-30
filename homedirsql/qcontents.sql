col name for a34
col TOTAL_WAIT for 999,999,999,999
set pages 200
set lines 160
select owner, NAME, WAITING, READY,EXPIRED, TOTAL_WAIT, AVERAGE_WAIT
from GV$AQ q, dba_queues u
where q.QID = u.QID
and name not like '%BILL%'
and name not like '%COLLECTION%'
and name in ('SUMMARYQUEUE', 'REDEVENTQUEUE', 'COSTEDEVENTQUEUETAIL')
and QUEUE_TYPE='NORMAL_QUEUE'
-- and owner = 'GENEVA_ADMIN'
order by owner, name
;

