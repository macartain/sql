prompt ============================================================
prompt AQ status
prompt ============================================================

set lines 180
set pages 200
col owner for a12
col name for a30
col destination for a25
col USER_COMMENT for a35
col RETENTION for a3
col QUEUE_TABLE for a25
col EQ for a8
col DQ for a8

select  OWNER, NAME, QUEUE_TABLE, QUEUE_TYPE, RETENTION, USER_COMMENT, ENQUEUE_ENABLED EQ, DEQUEUE_ENABLED DQ
from ALL_QUEUES
order by owner, queue_type, name;

