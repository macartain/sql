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
