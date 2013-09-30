set lines 160
set pages 200
col owner for a15
col name for a32
col destination for a10
col USER_COMMENT for a32
col RETENTION for a3
col QUEUE_TABLE for a25
col EQ for a8
col DQ for a8

select  OWNER, NAME, QUEUE_TABLE, QUEUE_TYPE, RETENTION, USER_COMMENT, ENQUEUE_ENABLED EQ, DEQUEUE_ENABLED DQ
from ALL_QUEUES
where queue_table not like 'BILL%'
order by owner, queue_type, name;
/