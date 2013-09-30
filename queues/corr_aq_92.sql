declare
    v_subscriber sys.aq$_agent;
    v_eventdb varchar2(255)         := null;
    v_eventdb_username varchar2(30) := null;
    v_dblink  varchar2(255)         := null;
begin

/*   Destroy costed event queues   */

exec corr_aq_92.drop_corrupted_q92(  q_schema =>'GENEVA_ADMIN',qt_name => 'COSTEDEVENTQUEUEHEAD',q_name =>'COSTEDEVENTQUEUEHEAD');
exec corr_aq_92.drop_corrupted_qt92(qt_schema =>'GENEVA_ADMIN',qt_name => 'COSTEDEVENTQUEUEHEAD');

exec corr_aq_92.drop_corrupted_q92(  q_schema =>'GENEVA_ADMIN',qt_name => 'REJECTEVENTQUEUEHEAD',q_name =>'REJECTEVENTQUEUEHEAD');
exec corr_aq_92.drop_corrupted_qt92(qt_schema =>'GENEVA_ADMIN',qt_name => 'REJECTEVENTQUEUEHEAD');

exec corr_aq_92.drop_corrupted_q92(  q_schema =>'GENEVA_ADMIN',qt_name => 'COSTEDEVENTQUEUETAIL',q_name =>'COSTEDEVENTQUEUETAIL');
exec corr_aq_92.drop_corrupted_qt92(qt_schema =>'GENEVA_ADMIN',qt_name => 'COSTEDEVENTQUEUETAIL');

exec corr_aq_92.drop_corrupted_q92(  q_schema =>'GENEVA_ADMIN',qt_name => 'REJECTEVENTQUEUETAIL',q_name =>'REJECTEVENTQUEUETAIL');
exec corr_aq_92.drop_corrupted_qt92(qt_schema =>'GENEVA_ADMIN',qt_name => 'REJECTEVENTQUEUETAIL');

exec corr_aq_92.drop_corrupted_q92(  q_schema =>'GENEVA_ADMIN',qt_name => 'RATINGCACHEQUEUE',q_name =>'RATINGCACHEQUEUE');
exec corr_aq_92.drop_corrupted_qt92(qt_schema =>'GENEVA_ADMIN',qt_name => 'RATINGCACHEQUEUE');

/*   set up costed event queue tail   */

   dbms_aqadm.create_queue_table(queue_table        => 'COSTEDEVENTQUEUETAIL',
                                  queue_payload_type => 'RAW',
                                  multiple_consumers => TRUE,
                                  compatible         => '8.1.3',
                                  storage_clause     => 'tablespace DATA');

   dbms_aqadm.create_queue(queue_name     => 'COSTEDEVENTQUEUETAIL',
                            queue_table    => 'COSTEDEVENTQUEUETAIL',
                            retention_time => 0);

   dbms_aqadm.start_queue(queue_name => 'COSTEDEVENTQUEUETAIL');

    v_subscriber := sys.aq$_agent('CEW', 'COSTEDEVENTQUEUETAIL', 0);

    dbms_aqadm.add_subscriber(queue_name => 'COSTEDEVENTQUEUETAIL',
                              subscriber => v_subscriber);

/*   set up rejected event queue tail   */

    dbms_aqadm.create_queue_table(queue_table        => 'REJECTEVENTQUEUETAIL',
                                  queue_payload_type => 'RAW',
                                  multiple_consumers => TRUE,
                                  compatible         => '8.1.3',
                                  storage_clause     => 'tablespace DATA');

    dbms_aqadm.create_queue(queue_name     => 'REJECTEVENTQUEUETAIL',
                            queue_table    => 'REJECTEVENTQUEUETAIL',
                            retention_time => 0);

    dbms_aqadm.start_queue(queue_name => 'REJECTEVENTQUEUETAIL');

    v_subscriber := sys.aq$_agent('CEW', 'REJECTEVENTQUEUETAIL', 0);

    dbms_aqadm.add_subscriber(queue_name => 'REJECTEVENTQUEUETAIL',
                              subscriber => v_subscriber);

 /*   set up costed event queue head   */

   dbms_aqadm.create_queue_table(queue_table        => 'COSTEDEVENTQUEUEHEAD',
                                  queue_payload_type => 'RAW',
                                  multiple_consumers => TRUE,
                                  compatible         => '8.1.3',
                                  storage_clause     => 'tablespace DATA');

    dbms_aqadm.create_queue(queue_name     => 'COSTEDEVENTQUEUEHEAD',
                            queue_table    => 'COSTEDEVENTQUEUEHEAD',
                            retention_time => 0);
    dbms_aqadm.start_queue(queue_name => 'COSTEDEVENTQUEUEHEAD');

    v_eventdb_username := USER;

    v_subscriber := sys.aq$_agent(NULL,
                                  v_eventdb_username||'.COSTEDEVENTQUEUETAIL',
                                  NULL);

    dbms_aqadm.add_subscriber(queue_name => USER||'.COSTEDEVENTQUEUEHEAD',
                              subscriber => v_subscriber);

    dbms_aqadm.schedule_propagation(queue_name  => USER||'.COSTEDEVENTQUEUEHEAD',
                                    destination => null,
                                    latency     => 0);

/*   set up rejected event queue head   */

    dbms_aqadm.create_queue_table(queue_table        => 'REJECTEVENTQUEUEHEAD',
                                  queue_payload_type => 'RAW',
                                  multiple_consumers => TRUE,
                                  compatible         => '8.1.3',
                                  storage_clause     => 'tablespace DATA');


    dbms_aqadm.create_queue(queue_name     => 'REJECTEVENTQUEUEHEAD',
                            queue_table    => 'REJECTEVENTQUEUEHEAD',
                            retention_time => 0);

    dbms_aqadm.start_queue(queue_name => 'REJECTEVENTQUEUEHEAD');

    v_eventdb_username := USER;

    v_subscriber := sys.aq$_agent(NULL,
                                  v_eventdb_username||'.REJECTEVENTQUEUETAIL',
                                  NULL);

    dbms_aqadm.add_subscriber(queue_name => USER||'.REJECTEVENTQUEUEHEAD',
                              subscriber => v_subscriber);

    dbms_aqadm.schedule_propagation(queue_name  => USER||'.REJECTEVENTQUEUEHEAD',
                                    destination => null,
                                    latency     => 0);
end;
/

