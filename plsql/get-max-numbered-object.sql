declare
    v_first_queue number;
begin
    -- Check user_queues to see if re-running
    select nvl(max(substr(NAME, 17) + 1), 1)
    into   v_first_queue
    from   USER_QUEUES
    where  NAME like 'BILLINGWORKQUEUE%'
    and    ENQUEUE_ENABLED = '  YES  ';

    for i in v_first_queue..60
    loop
        dbms_aqadm.start_queue(queue_name => 'BILLINGWORKQUEUE'||i);
    end loop;
end;
/