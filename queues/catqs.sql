DECLARE
  enqueue_options    dbms_aq.enqueue_options_t;
  message_properties dbms_aq.message_properties_t;
  dequeue_options    dbms_aq.dequeue_options_t;
  message_handle     RAW(16);
  mes                blob;
  no_messages EXCEPTION;
  pragma EXCEPTION_INIT(no_messages, -25228);

  cursor messages is
    select msg_id, user_data
      from Aq$costedeventqueuetail
     where queue = 'COSTEDEVENTQUEUETAIL';

BEGIN
  dequeue_options.consumer_name	:= 'CEW';
  dequeue_options.wait       := DBMS_AQ.NO_WAIT;
  dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;
  dequeue_options.dequeue_mode := DBMS_AQ.BROWSE;
  
  dbms_output.put_line('Started queue browse..');
  for v_msg_id in messages loop
    dequeue_options.msgid := v_msg_id.msg_id;
    mes                   := v_msg_id.user_data;
    
    dbms_aq.dequeue(queue_name         => 'COSTEDEVENTQUEUETAIL',
                    dequeue_options    => dequeue_options,
                    message_properties => message_properties,
                    payload            => mes,
                    msgid              => message_handle);
  
    dbms_output.put_line('The message id is: ' || message_handle);
    dbms_output.put_line('UserData: ' || utl_raw.cast_to_varchar2(mes));
    commit;
	  
    dequeue_options.navigation := DBMS_AQ.NEXT_MESSAGE;  
  end loop;
dbms_output.put_line('All msgs displayed.');
  
EXCEPTION
  WHEN no_messages THEN
    DBMS_OUTPUT.PUT_LINE('No more messages');
  WHEN OTHERS THEN
    dbms_output.put_line('ERROR:');
    dbms_output.put_line(to_char(SQLCODE) || ': ' || SQLERRM);
END;
/
