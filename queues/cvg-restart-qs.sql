-- ********************************************************
--
-- Restart queues after import
-- 
-- ********************************************************

declare
    v_subscriber           sys.aq$_agent;
    v_eventdb              varchar2(255) 	:= null;

begin
    dbms_output.enable(1000000);

    dbms_output.put_line('Starting queues...');
    dbms_aqadm.start_queue(queue_name => 'COSTEDEVENTQUEUETAIL');
    dbms_aqadm.start_queue(queue_name => 'REJECTEVENTQUEUETAIL');
    dbms_aqadm.start_queue(queue_name => 'COSTEDEVENTQUEUEHEAD');
    dbms_aqadm.start_queue(queue_name => 'REJECTEVENTQUEUEHEAD');


    dbms_output.put_line('Restarting propagation...');
    dbms_aqadm.schedule_propagation(queue_name  => 'COSTEDEVENTQUEUEHEAD',latency     => 0);
    dbms_aqadm.schedule_propagation(queue_name  => 'COSTEDEVENTQUEUETAIL',latency     => 0);
exception
    when others then
        dbms_output.put_line('Ooops ' || sqlerrm);
    

end;
