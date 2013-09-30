-- ********************************************************
-- File: I4_queue.sql
--
-- Drop and recreate CEQUEUEHEAD and TAIL
-- 
-- ********************************************************

declare
    v_subscriber sys.aq$_agent;
    v_eventdb varchar2(255)         := null;
    v_eventdb_username varchar2(30) := null;
    v_dblink  varchar2(255)         := null;
begin

	prompt Dropping COSTEDEVENTQUEUEHEAD queue...
	execute dbms_aqadm.unschedule_propagation(USER||'.COSTEDEVENTQUEUEHEAD', NULL);
	execute dbms_aqadm.stop_queue(queue_name => 'COSTEDEVENTQUEUEHEAD');
	execute dbms_aqadm.drop_queue(queue_name => 'COSTEDEVENTQUEUEHEAD');
	execute dbms_aqadm.drop_queue_table(queue_table => 'COSTEDEVENTQUEUEHEAD', force => TRUE);
	
	prompt Dropping COSTEDEVENTQUEUETAIL queue...
	execute dbms_aqadm.unschedule_propagation(USER||'.COSTEDEVENTQUEUETAIL', NULL);
	execute dbms_aqadm.stop_queue(queue_name => 'COSTEDEVENTQUEUETAIL');
	execute dbms_aqadm.drop_queue(queue_name => 'COSTEDEVENTQUEUETAIL');
	execute dbms_aqadm.drop_queue_table(queue_table => 'COSTEDEVENTQUEUETAIL', force => TRUE);

    
	-- CREATE & START CEQTAIL

	prompt Recreating COSTEDEVENTQUEUETAIL queue...
	dbms_aqadm.create_queue_table(queue_table        => 'COSTEDEVENTQUEUETAIL',
                                  queue_payload_type => 'RAW',
                                  multiple_consumers => TRUE,
                                  compatible         => '8.1.3',
                                  storage_clause     => 'tablespace &&gCOSTEDEVENTQUEUETAIL_TS');

    dbms_aqadm.create_queue(queue_name     => 'COSTEDEVENTQUEUETAIL',
                            queue_table    => 'COSTEDEVENTQUEUETAIL',
                            retention_time => 0);
    dbms_aqadm.start_queue(queue_name => 'COSTEDEVENTQUEUETAIL');

    v_subscriber := sys.aq$_agent('CEW', 'COSTEDEVENTQUEUETAIL', 0);

    dbms_aqadm.add_subscriber(queue_name => 'COSTEDEVENTQUEUETAIL',
                              subscriber => v_subscriber);

	-- CREATE & START CEQHEAD

	prompt Recreating COSTEDEVENTQUEUEHEAD queue...
    dbms_aqadm.create_queue_table(queue_table        => 'COSTEDEVENTQUEUEHEAD',
                                  queue_payload_type => 'RAW',
                                  multiple_consumers => TRUE,
                                  compatible         => '8.1.3',
                                  storage_clause     => 'tablespace &&gCOSTEDEVENTQUEUEHEAD_TS');

    dbms_aqadm.create_queue(queue_name     => 'COSTEDEVENTQUEUEHEAD',
                            queue_table    => 'COSTEDEVENTQUEUEHEAD',
                            retention_time => 0);
    dbms_aqadm.start_queue(queue_name => 'COSTEDEVENTQUEUEHEAD');

	-- SUBSCRIBE CEQTAIL to CEQHEAD

	prompt Setting up subscription...
    if v_eventdb is not null then
        v_dblink := '@' || v_eventdb;

        select username
        into   v_eventdb_username
        from   user_db_links
        where  UPPER(db_link) = UPPER('&&gSYSeventDBserviceName');

        dbms_output.enable(10000);
        dbms_output.put_line('Event database user: ' || v_eventdb_username);

    else
        v_eventdb_username := USER;
    end if;

    v_subscriber := sys.aq$_agent(NULL,
                                  v_eventdb_username||'.COSTEDEVENTQUEUETAIL'||v_dblink,
                                  NULL);

    dbms_aqadm.add_subscriber(queue_name => USER||'.COSTEDEVENTQUEUEHEAD',
                              subscriber => v_subscriber);

	-- RESTART PROPAGATION

	prompt Restarting propagation...
    dbms_aqadm.schedule_propagation(queue_name  => USER||'.COSTEDEVENTQUEUEHEAD',
                                    destination => v_eventdb,
                                    latency     => 0);

    dbms_aqadm.schedule_propagation(queue_name  => USER||'.REJECTEVENTQUEUEHEAD',
                                    destination => v_eventdb,
                                    latency     => 0);

end;
/