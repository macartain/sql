-- --------------------------------------------------------------------
-- QID--the identity of the queue. This is the same as the qid in user_queues and dba_queues.
-- WAITING--the number of messages in the state 'WAITING'.
-- READY--the number of messages in state 'READY'.
-- EXPIRED -the number of messages in state 'EXPIRED'.
-- TOTAL_WAIT -the number of seconds for which messages in the queue have been waiting in state 'READY'
-- AVERAGE_WAIT -the average number of seconds a message in state 'READY' has been waiting to be dequeued.

-- Events will sit in READY until they have six reattempts, after which they will go to EXPIRED - they can still
-- be resubmitted using the requeue script if they are in EXPIRED state.
-- --------------------------------------------------------------------

col name for a34
col TOTAL_WAIT for 999,999,999,999
set pages 200
set lines 160
break on owner
select owner, NAME, QUEUE_TYPE, WAITING, READY,EXPIRED, TOTAL_WAIT, AVERAGE_WAIT
from GV$AQ q, dba_queues u
where q.QID = u.QID
and (name like '%COSTEDEVENTQUEUE%'
or name like 'RED%'
or name like '%SUMMARYQUEUE%')
--and name not like '%BILL%'
-- and name not like '%COLLECTION%'
--and name in ('SUMMARYQUEUE', 'REDEVENTQUEUE', 'COSTEDEVENTQUEUETAIL')
and name in ('COSTEDEVENTQUEUEHEAD', 'COSTEDEVENTQUEUETAIL', 'REJECTEVENTQUEUEHEAD', 'REJECTEVENTQUEUETAIL')
-- and QUEUE_TYPE='NORMAL_QUEUE'
-- and owner = 'GENEVA_ADMIN'
order by owner, queue_table, name
;

-- --------------------------------------------------------------------
-- Queue counts
-- --------------------------------------------------------------------
select 'CEQ Head', count(*)  from aq$costedeventqueuehead
union all
select 'CEQ Tail', count(*)  from aq$costedeventqueuetail
union all
select 'Reject Head', count(*) from aq$rejecteventqueuehead
union all
select 'Reject Tail', count(*) from aq$rejecteventqueuetail;
-- union all
-- select 'Custom', count(*) cceq from aq$customcostedeventqueue;

-- --------------------------------------------------------------------
-- Check propagation is in place - should show CEQHEAD and REQHEAD
-- if not, W7_queue_propagation should be recalled...
-- --------------------------------------------------------------------
col schema for a12
col qname for a25
col destination for a10
col LAST_ERROR_MSG for a35 word_wrap
select schema, QNAME, DESTINATION, SCHEDULE_DISABLED, 
to_char(START_DATE,'MM-DD-YYYY HH24:MI:SS') as Started, 
to_char(LAST_RUN_DATE,'MM-DD-YYYY HH24:MI:SS') as Last_Run, 
PROCESS_NAME, TOTAL_NUMBER, FAILURES, LAST_ERROR_MSG
from DBA_QUEUE_SCHEDULES
--from USER_QUEUE_SCHEDULES
;

-- --------------------------------------------------------------------
-- Basic showqs - should show CEQHEAD and REQHEAD as YES for DQ & EQ
-- --------------------------------------------------------------------
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

-- --------------------------------------------------------------------
-- Queue subs
-- --------------------------------------------------------------------
col ID for 99
col protocol for 99
col rule_name for a5
col TRANS_NAME for a10
col RULESET_NAME for a10
col sub for a10
col queuename for a24
col address for a50
col TYPE for 99999
select QUEUE_NAME,  subscriber_id as ID, NAME as sub, ADDRESS, SUBSCRIBER_TYPE as TYPE
from aq$_costedeventqueuehead_s
where SUBSCRIBER_TYPE != 4
union
select QUEUE_NAME, subscriber_id as ID,  NAME as sub, ADDRESS, SUBSCRIBER_TYPE as TYPE
from aq$_costedeventqueuetail_s
where SUBSCRIBER_TYPE != 4
union
select QUEUE_NAME,  subscriber_id as ID, NAME as sub, ADDRESS, SUBSCRIBER_TYPE as TYPE
from aq$_rejecteventqueuehead_s
where SUBSCRIBER_TYPE != 4
union
select QUEUE_NAME, subscriber_id as ID,  NAME as sub, ADDRESS, SUBSCRIBER_TYPE as TYPE
from aq$_rejecteventqueuetail_s
where SUBSCRIBER_TYPE != 4
;

-- --------------------------------------------------------------------
-- Queue contents
-- --------------------------------------------------------------------
col qname for a34
SELECT COUNT(*), queue, msg_state, consumer_name||address as qname
FROM aq$COSTEDEVENTQUEUETAIL
GROUP BY queue, msg_state, consumer_name, address
;

-- --------------------------------------------------------------------
-- Queue contents - a la Julian
-- --------------------------------------------------------------------
select case rownum when 1 then 'Queue Head' end "Queue",
       case rownum when 1 then ilv1.tot_count end "Total Count",
       ilv2.msg_state "Message State",
       ilv2.state_count "State Count"
  from ( select count(*) tot_count
           from aq$costedeventqueuehead
        ) ilv1
       left join ( select msg_state,
                          count(*) state_count
                     from aq$costedeventqueuehead
                    group by msg_state
                    order by msg_state desc
                  ) ilv2
              on 1 = 1
 union all
select case rownum when 1 then 'Queue Tail' end "Queue",
       case rownum when 1 then ilv1.tot_count end "Count",
       ilv2.msg_state,
       ilv2.state_count
  from ( select count(*) tot_count
           from aq$costedeventqueuetail
        ) ilv1
       left join ( select msg_state,
                          count(*) state_count
                     from aq$costedeventqueuetail
                    group by msg_state
                    order by msg_state desc
                  ) ilv2
              on 1 = 1
 union all
select case rownum when 1 then 'Reject Head' end "Queue",
       case rownum when 1 then ilv1.tot_count end "Count",
       ilv2.msg_state,
       ilv2.state_count
  from ( select count(*) tot_count
           from aq$rejecteventqueuehead
        ) ilv1
       left join ( select msg_state,
                          count(*) state_count
                     from aq$rejecteventqueuehead
                    group by msg_state
                    order by msg_state desc
                  ) ilv2
              on 1 = 1
 union all
select case rownum when 1 then 'Reject Tail' end "Queue",
       case rownum when 1 then ilv1.tot_count end "Count",
       ilv2.msg_state,
       ilv2.state_count
  from ( select count(*) tot_count
           from aq$rejecteventqueuetail
        ) ilv1
       left join ( select msg_state,
                          count(*) state_count
                     from aq$rejecteventqueuetail
                    group by msg_state
                    order by msg_state desc
                  ) ilv2
              on 1 = 1;

-- --------------------------------------------------------------------
-- Collection queue info -- see 6785087 / 5263-IN 
-- --------------------------------------------------------------------
col GPARAM_NAME for a35 trunc
col string_value for a8 trunc
col TRIGGER_NAME_ORA for a35 trunc
select GPARAM_NAME, string_value, trigger_name, status
from dba_triggers dt
	join FEATUREUSESTRIGGER fut on TRIGGER_NAME_ORA=TRIGGER_NAME
	join GPARAMS g on NAME=GPARAM_NAME;

-- $IR/RB/schema/source/fixcollectiontriggers.sql

-- --------------------------------------------------------------------
-- Common tasks
-- --------------------------------------------------------------------

-- restart
exec dbms_aqadm.start_queue(queue_name => 'COSTEDEVENTQUEUEHEAD');
exec dbms_aqadm.start_queue(queue_name => 'COSTEDEVENTQUEUETAIL');
exec dbms_aqadm.start_queue(queue_name => 'REJECTEVENTQUEUEHEAD');
exec dbms_aqadm.start_queue(queue_name => 'REJECTEVENTQUEUETAIL');

-- stop prop schedule
exec dbms_aqadm.unschedule_propagation(queue_name  => 'COSTEDEVENTQUEUEHEAD');
exec dbms_aqadm.unschedule_propagation(queue_name  => 'COSTEDEVENTQUEUETAIL');

-- restart propagation (W7_queue_propagation.sql)
exec dbms_aqadm.schedule_propagation(queue_name => 'GENEVA_ADMIN.COSTEDEVENTQUEUEHEAD', latency => 0);
exec dbms_aqadm.schedule_propagation(queue_name => 'GENEVA_ADMIN.REJECTEVENTQUEUEHEAD', latency => 0);

-- purge
DECLARE
  popts dbms_aqadm.aq$_purge_options_t;

BEGIN
  dbms_output.put_line('Started queue purge..');

  DBMS_AQADM.PURGE_QUEUE_TABLE(
     queue_table 	=>'COSTEDEVENTQUEUETAIL',
     purge_condition 	=>'',
     purge_options      => popts);
     
  dbms_output.put_line('Purge completed.');
END;
   
-- force drop
exec dbms_aqadm.unschedule_propagation('GENEVA_ADMIN.HYBRIDCUSTDATASYNCQUEUE');
exec dbms_aqadm.stop_queue(queue_name => 'GENEVA_ADMIN.HYBRIDCUSTDATASYNCQUEUE');
exec dbms_aqadm.drop_queue(queue_name => 'GENEVA_ADMIN.HYBRIDCUSTDATASYNCQUEUE');
exec dbms_aqadm.drop_queue_table(queue_table => 'GENEVA_ADMIN.HYBRIDCUSTDATASYNCQUEUE', force => TRUE);