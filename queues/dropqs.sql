set serveroutput on
declare
    e_no_prop_schedule exception; pragma EXCEPTION_INIT(e_no_prop_schedule, -24042);
    e_no_sys_prop exception; pragma EXCEPTION_INIT(e_no_sys_prop, -24002);
    e_q_already_dropped exception; pragma EXCEPTION_INIT(e_q_already_dropped, -24010);
    e_syn_already_dropped exception; pragma EXCEPTION_INIT(e_syn_already_dropped, -01432);

begin
    dbms_output.enable(1000000);

    FOR rec IN (
        select name
        from user_queues
        where QUEUE_TYPE='NORMAL_QUEUE')
    loop
        begin
            dbms_output.put_line('Unscheduling ' || rec.name);
            dbms_aqadm.unschedule_propagation('GENEVA_ADMIN.' || rec.name, NULL);
        exception
            when e_q_already_dropped then dbms_output.put_line('Queue already deleted: ' || rec.name);
            when e_no_sys_prop then dbms_output.put_line('No sys_props tab: ' || rec.name);
            when e_no_prop_schedule then dbms_output.put_line('No prop schedule for queue: ' || rec.name);
        when others then dbms_output.put_line('Ooops ' || sqlerrm);

        end;
        begin
            dbms_output.put_line('Dropping ' || rec.name);
            dbms_aqadm.stop_queue(queue_name => 'GENEVA_ADMIN.' || rec.name);
            dbms_aqadm.drop_queue(queue_name => 'GENEVA_ADMIN.' || rec.name);
            dbms_aqadm.drop_queue_table(queue_table => 'GENEVA_ADMIN.' || rec.name, force => TRUE);
        exception
                when e_no_sys_prop then dbms_output.put_line('No sys_props tab: ' || rec.name);
                when e_q_already_dropped then dbms_output.put_line('Queue already deleted: ' || rec.name);
            when others then dbms_output.put_line('Ooops ' || sqlerrm);
        end;
    end loop;
    
    dbms_output.put_line('Dropping CUSTOMERSYNCOBJECT type for HYBRDIQUEUE');
    begin 
        EXECUTE IMMEDIATE 'drop type CUSTOMERSYNCOBJECT force';
        EXECUTE IMMEDIATE 'drop public synonym CUSTOMERSYNCOBJECT';
    exception
        when e_syn_already_dropped then dbms_output.put_line('Syn already gone: ' || sqlerrm);
        when others then dbms_output.put_line('Ooops ' || sqlerrm);
    end;       

end;
/
exit;
