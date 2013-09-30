set serveroutput on

prompt ============================================================
prompt Rebuild Hybrid Queue
prompt ============================================================

declare
    e_no_prop_schedule exception; pragma EXCEPTION_INIT(e_no_prop_schedule, -24042);
    e_no_sys_prop exception; pragma EXCEPTION_INIT(e_no_sys_prop, -24002);
    e_q_already_dropped exception; pragma EXCEPTION_INIT(e_q_already_dropped, -24010);

define gHYBRIDCUSTDATASYNCQUEUE_TS = USERS;

begin
    dbms_output.enable(1000000);

	dbms_output.put_line('Dropping type..');
	drop type CUSTOMERSYNCOBJECT force;
	drop public synonym CUSTOMERSYNCOBJECT;

	begin
			dbms_output.put_line('Unscheduling HYBRIDCUSTDATASYNCQUEUE...');
			dbms_aqadm.unschedule_propagation('GENEVA_ADMIN.HYBRIDCUSTDATASYNCQUEUE');
	exception
			when e_q_already_dropped then dbms_output.put_line('Queue already deleted: ' || sqlerrm);
			when e_no_prop_schedule then dbms_output.put_line('No prop schedule for queue: ' || sqlerrm);
			when others then
					dbms_output.put_line('Ooops ' || sqlerrm);
	end;

	begin
			dbms_output.put_line('Stopping HYBRIDCUSTDATASYNCQUEUE...');
			dbms_aqadm.stop_queue(queue_name => 'GENEVA_ADMIN.HYBRIDCUSTDATASYNCQUEUE');
	exception
			when e_no_sys_prop then dbms_output.put_line('No sys_props tab: ' || sqlerrm);
			when e_q_already_dropped then dbms_output.put_line('Queue already deleted: ' || sqlerrm);
			when others then
					dbms_output.put_line('Ooops ' || sqlerrm);
	end;

	begin
			dbms_output.put_line('Dropping queue HYBRIDCUSTDATASYNCQUEUE...');
			dbms_aqadm.drop_queue(queue_name => 'GENEVA_ADMIN.HYBRIDCUSTDATASYNCQUEUE');
	exception
			when e_no_sys_prop then dbms_output.put_line('No sys_props tab: ' || sqlerrm);
			when e_q_already_dropped then dbms_output.put_line('Queue already deleted: ' || sqlerrm);
			when others then
					dbms_output.put_line('Ooops ' || sqlerrm);
	end;

	begin
			dbms_output.put_line('Dropping queue table HYBRIDCUSTDATASYNCQUEUE...');
			dbms_aqadm.drop_queue_table(queue_table => 'GENEVA_ADMIN.HYBRIDCUSTDATASYNCQUEUE', force => TRUE);
	exception
			when e_no_sys_prop then dbms_output.put_line('No sys_props tab: ' || sqlerrm);
			when e_q_already_dropped then dbms_output.put_line('Queue already deleted: ' || sqlerrm);
			when others then
					dbms_output.put_line('Ooops ' || sqlerrm);
	end;

	dbms_output.put_line('Recreating type');
	execute immediate 'create type customerSyncObject as object (
		customer_data_sync_ticket blob
	)';

	dbms_output.put_line('Recreating queue table');
	dbms_aqadm.create_queue_table(queue_table  => 'HYBRIDCUSTDATASYNCQUEUE',
					queue_payload_type => 'customerSyncObject',
					multiple_consumers => FALSE,
					compatible         => '8.1.3',
					storage_clause     => 'tablespace &&gHYBRIDCUSTDATASYNCQUEUE_TS');

	dbms_output.put_line('Recreating queue');
	dbms_aqadm.create_queue(queue_name => 'HYBRIDCUSTDATASYNCQUEUE',
					queue_table    => 'HYBRIDCUSTDATASYNCQUEUE',
					retention_time => 0);

	dbms_output.put_line('Starting queue');
	dbms_aqadm.start_queue(queue_name => 'HYBRIDCUSTDATASYNCQUEUE');

	dbms_output.put_line('Done.');

end;
/