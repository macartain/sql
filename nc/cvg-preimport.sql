set head off
set feedback off
spool temp_pre_install_1.sql
select 'truncate table ' || table_name || ';' from user_tables;
select 'alter trigger ' || trigger_name || ' disable;' from user_triggers;
select 'drop sequence ' || sequence_name || ';' from user_sequences;
spool off
set head on
set feedback on

@ temp_pre_install_1.sql

prompt Dropping Type CUSTOMERSYNCOBJECT
drop type CUSTOMERSYNCOBJECT

prompt Dropping COSTEDEVENTQUEUEHEAD queue...
execute dbms_aqadm.unschedule_propagation(USER||'.COSTEDEVENTQUEUEHEAD', NULL);
execute dbms_aqadm.stop_queue(queue_name => 'COSTEDEVENTQUEUEHEAD');
execute dbms_aqadm.drop_queue(queue_name => 'COSTEDEVENTQUEUEHEAD');
execute dbms_aqadm.drop_queue_table(queue_table => 'COSTEDEVENTQUEUEHEAD', force => TRUE);
 
prompt Dropping RATINGCACHEQUEUE queue...
execute dbms_aqadm.unschedule_propagation(USER||'.RATINGCACHEQUEUE', NULL);
execute dbms_aqadm.stop_queue(queue_name => 'RATINGCACHEQUEUE');
execute dbms_aqadm.drop_queue(queue_name => 'RATINGCACHEQUEUE');
execute dbms_aqadm.drop_queue_table(queue_table => 'RATINGCACHEQUEUE', force => TRUE);
 
prompt Dropping REJECTEVENTQUEUEHEAD queue...
execute dbms_aqadm.unschedule_propagation(USER||'.REJECTEVENTQUEUEHEAD', NULL);
execute dbms_aqadm.stop_queue(queue_name => 'REJECTEVENTQUEUEHEAD');
execute dbms_aqadm.drop_queue(queue_name => 'REJECTEVENTQUEUEHEAD');
execute dbms_aqadm.drop_queue_table(queue_table => 'REJECTEVENTQUEUEHEAD', force => TRUE);

prompt Dropping COSTEDEVENTQUEUETAIL queue...
execute dbms_aqadm.unschedule_propagation(USER||'.COSTEDEVENTQUEUETAIL', NULL);
execute dbms_aqadm.stop_queue(queue_name => 'COSTEDEVENTQUEUETAIL');
execute dbms_aqadm.drop_queue(queue_name => 'COSTEDEVENTQUEUETAIL');
execute dbms_aqadm.drop_queue_table(queue_table => 'COSTEDEVENTQUEUETAIL', force => TRUE);
 
prompt Dropping REJECTEVENTQUEUETAIL queue...
execute dbms_aqadm.unschedule_propagation(USER||'.REJECTEVENTQUEUETAIL', NULL);
execute dbms_aqadm.stop_queue(queue_name => 'REJECTEVENTQUEUETAIL');
execute dbms_aqadm.drop_queue(queue_name => 'REJECTEVENTQUEUETAIL');
execute dbms_aqadm.drop_queue_table(queue_table => 'REJECTEVENTQUEUETAIL', force => TRUE);

prompt Dropping HYBRIDCUSTDATASYNCQUEUE queue...
execute dbms_aqadm.unschedule_propagation(USER||'.HYBRIDCUSTDATASYNCQUEUE', NULL);
execute dbms_aqadm.stop_queue(queue_name => 'HYBRIDCUSTDATASYNCQUEUE');
execute dbms_aqadm.drop_queue(queue_name => 'HYBRIDCUSTDATASYNCQUEUE');
execute dbms_aqadm.drop_queue_table(queue_table => 'HYBRIDCUSTDATASYNCQUEUE', force => TRUE);
