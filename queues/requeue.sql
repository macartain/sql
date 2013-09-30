DECLARE
  enqueue_options    dbms_aq.enqueue_options_t;
  message_properties dbms_aq.message_properties_t;
  dequeue_options    dbms_aq.dequeue_options_t;
  message_handle     RAW(16);
  mes                RAW(3000);
  no_messages EXCEPTION;
  pragma EXCEPTION_INIT(no_messages, -25228);

  cursor messages is
    select msg_id, user_data
      from Aq$costedeventqueuetail
     where queue = 'AQ$_COSTEDEVENTQUEUETAIL_E';

BEGIN
  dequeue_options.wait       := DBMS_AQ.NO_WAIT;
  dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;
  dbms_output.put_line('Started..');
  for v_msg_id in messages loop
    dequeue_options.msgid := v_msg_id.msg_id;
    mes                   := v_msg_id.user_data;
    
    dbms_aq.dequeue(queue_name         => 'AQ$_COSTEDEVENTQUEUETAIL_E',
                    dequeue_options    => dequeue_options,
                    message_properties => message_properties,
                    payload            => mes,
                    msgid              => message_handle);
  
    dbms_output.put_line('The message id is: ' || message_handle);
  
    DBMS_AQ.ENQUEUE(queue_name         => 'COSTEDEVENTQUEUETAIL',
                    enqueue_options    => enqueue_options,
                    message_properties => message_properties,
                    payload            => mes,
                    msgid              => message_handle);
    commit;
  
    dequeue_options.navigation := DBMS_AQ.NEXT_MESSAGE;  
  end loop;
  
EXCEPTION
  WHEN no_messages THEN
    DBMS_OUTPUT.PUT_LINE('No more messages');
  WHEN OTHERS THEN
    dbms_output.put_line('ERROR:');
    dbms_output.put_line(to_char(SQLCODE) || ': ' || SQLERRM);
END;

