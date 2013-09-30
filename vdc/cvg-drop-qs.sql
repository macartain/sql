begin

    dbms_output.enable(1000000);

    dbms_output.put_line('Stopping queue propagation...');
    begin
        dbms_aqadm.unschedule_propagation(USER || '.COSTEDEVENTQUEUEHEAD', NULL);
	    dbms_aqadm.unschedule_propagation(USER || '.COSTEDEVENTQUEUETAIL', NULL);
    exception
        when ORA-24010 then
            dbms_output.put_line('Queue already deleted: ' || sqlerrm);
    end;

    dbms_output.put_line('Dropping COSTEDEVENTQUEUEHEAD queue...');
    dbms_aqadm.stop_queue(queue_name => 'COSTEDEVENTQUEUEHEAD');
    dbms_aqadm.drop_queue(queue_name => 'COSTEDEVENTQUEUEHEAD');
    dbms_aqadm.drop_queue_table(queue_table => 'COSTEDEVENTQUEUEHEAD', force => TRUE);

    dbms_output.put_line('Dropping COSTEDEVENTQUEUETAIL queue...');
    dbms_aqadm.stop_queue(queue_name => 'COSTEDEVENTQUEUETAIL');
    dbms_aqadm.drop_queue(queue_name => 'COSTEDEVENTQUEUETAIL');
    dbms_aqadm.drop_queue_table(queue_table => 'COSTEDEVENTQUEUETAIL', force => TRUE);

    dbms_output.put_line('Dropping REJECTEVENTQUEUETAIL queue...');
    dbms_aqadm.stop_queue(queue_name => 'REJECTEVENTQUEUETAIL');
    dbms_aqadm.drop_queue(queue_name => 'REJECTEVENTQUEUETAIL');
    dbms_aqadm.drop_queue_table(queue_table => 'REJECTEVENTQUEUETAIL', force => TRUE);

    dbms_output.put_line('Dropping REJECTEVENTQUEUEHEAD queue...');
    dbms_aqadm.stop_queue(queue_name => 'REJECTEVENTQUEUEHEAD');
    dbms_aqadm.drop_queue(queue_name => 'REJECTEVENTQUEUEHEAD');
    dbms_aqadm.drop_queue_table(queue_table => 'REJECTEVENTQUEUEHEAD', force => TRUE);

    dbms_output.put_line('Dropping RATINGCACHEQUEUE queue...');
    dbms_aqadm.stop_queue(queue_name => 'RATINGCACHEQUEUE');
    dbms_aqadm.drop_queue(queue_name => 'RATINGCACHEQUEUE');
    dbms_aqadm.drop_queue_table(queue_table => 'RATINGCACHEQUEUE', force => TRUE);

    dbms_output.put_line('Dropping HYBRIDCUSTDATASYNCQUEUE queue...');
    dbms_aqadm.stop_queue(queue_name => 'HYBRIDCUSTDATASYNCQUEUE');
    dbms_aqadm.drop_queue(queue_name => 'HYBRIDCUSTDATASYNCQUEUE');
    dbms_aqadm.drop_queue_table(queue_table => 'HYBRIDCUSTDATASYNCQUEUE', force => TRUE);

    dbms_output.put_line('Dropping REDEVENTQUEUE queue...');
    dbms_aqadm.stop_queue(queue_name => 'REDEVENTQUEUE');
    dbms_aqadm.drop_queue(queue_name => 'REDEVENTQUEUE');
    dbms_aqadm.drop_queue_table(queue_table => 'REDEVENTQUEUE', force => TRUE);

    dbms_output.put_line('Dropping REDREJECTQUEUE queue...');
    dbms_aqadm.stop_queue(queue_name => 'REDREJECTQUEUE');
    dbms_aqadm.drop_queue(queue_name => 'REDREJECTQUEUE');
    dbms_aqadm.drop_queue_table(queue_table => 'REDREJECTQUEUE', force => TRUE);

exception
    when others then
        dbms_output.put_line('Ooops ' || sqlerrm);
    
end;
