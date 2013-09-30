-- --------------------------------------------------------------------
-- Job status detail
-- --------------------------------------------------------------------
col job_status for a25 trunc;
select JOB_ID, job_type_name, to_char(j.CREATED_DTM, 'DD-MM-YYYY HH24:MI:SS') created, to_char(j.LAST_UPDATE_DTM, 'DD-MM-YYYY HH24:MI:SS') job_update,
decode(nvl(JOB_STATUS, 0),
                 0, '---------------',
                 1, '1-Being created.',
                 2, '2-Waiting to be processed.',
                 3, '3-Being processed ',
                 4, '4-Completed.',
                 5, '5-Failed unrecoverable. Manual intervention required.',
                 6, '6-Partial complete - Ready to be run again.',
                 7, '7-Canceled',
                 8, '8-Rejects to be processed',
                 9, '9-Processed manually.',
                 10,'10-In doubt completed.'
                 ) job_status
from jobtype jt, job j
where j.job_type_id=jt.job_type_id
AND j.LAST_UPDATE_DTM > '01-JUL-08'
order by j.LAST_UPDATE_DTM asc;

-- --------------------------------------------------------------------
-- Counts by job status
-- --------------------------------------------------------------------
select job_priority, count(JOB_ID), decode(nvl(JOB_STATUS, 0),
                 0, '---------------',
                 1, '1-Being created.',
                 2, '2-Waiting to be processed.',
                 3, '3-Being processed ',
                 4, '4-Completed.',
                 5, '5-Failed unrecoverable. Manual intervention required.',
                 6, '6-Partial complete - Ready to be run again.',
                 7, '7-Canceled',
                 8, '8-Rejects to be processed',
                 9, '9-Processed manually.',
                 10,'10-In doubt completed.'
                 ) job_status
from job
where LAST_UPDATE_DTM > (SYSDATE -1)
group by job_priority, job_status
order by job_priority, job_status;

select count(managed_file_id), decode(nvl(JOB_FILE_STATUS, 0),
                 0,      '---------------',
                 1,      'Awaiting procesing',
                 2,      'Being processed',
                 3,      'Processing complete',
                 4,      'Cancelled',
                 5,      'Being edited',
                 6,      'Superseded') job_file_status
from jobhasfile
where LAST_UPDATE_DTM > '19-JUL-09'
group by JOB_FILE_STATUS;

-- --------------------------------------------------------------------
-- Job status with file info
-- --------------------------------------------------------------------
set pages 25
col mfid for 999999999
col job_type_name for a20 trunc
col FILE_SUBTYPE_NAME for a20 trunc
col proc_tidemark for 999,999,999 trunc
col VALID_TIDEMARK for 999,999,999 trunc
select jhf.MANAGED_FILE_ID mfid, job_type_name, FILE_SUBTYPE_NAME, to_char(j.CREATED_DTM, 'DDMONYY HH24:MI:SS') created, to_char(j.LAST_UPDATE_DTM, 'DDMONYY HH24:MI:SS') job_update, 
PROCESSED_TIDEMARK proc_tidemark,
decode(nvl(FILE_STATUS, 0),
                1,'1-Live.',
                2,'2-Being deleted.',
                3,'3-Deleted.',
                4,'4-Superseded.') mf_filestatus,
decode(nvl(JOB_FILE_STATUS, 0),
                 0,      '---------------',
                 1,      'Awaiting processing',
                 2,      'Being processed',
                 3,      'Processing complete',
                 4,      'Cancelled',
                 5,      'Being edited',
                 6,      'Superseded') job_file_status,
decode(nvl(JOB_STATUS, 0),
                 0, '---------------',
                 1, '1-Being created.',
                 2, '2-Waiting to be processed.',
                 3, '3-Being processed ',
                 4, '4-Completed.',
                 5, '5-Failed unrecoverable. Manual intervention required.',
                 6, '6-Partial complete - Ready to be run again.',
                 7, '7-Canceled',
                 8, '8-Rejects to be processed',
                 9, '9-Processed manually.',
                 10,'10-In doubt completed.'
                 ) job_status
from JOBHASFILE jhf, managedfile m, filesubtype f, jobtype jt, job j
where jhf.MANAGED_FILE_ID=m.MANAGED_FILE_ID
and j.job_id=jhf.job_id
and j.job_type_id=jt.job_type_id
and m.FILE_SUBTYPE=f.FILE_SUBTYPE
and m.FILE_TYPE_ID=f.FILE_TYPE_ID
AND j.CREATED_DTM > '01-APR-11'
-- AND j.LAST_UPDATE_DTM > '01-SEP-08'
--and JOB_STATUS!=4
order by j.LAST_UPDATE_DTM asc
;

-- --------------------------------------------------------------------
-- Process  history
-- --------------------------------------------------------------------
col parameters for a80 trunc
col process_plan_name for a20 trunc
col FAIL_MESSAGE_NAME for a5 trunc
col phase for a8 trunc
col copy for 9999
col process_status for a15 trunc
select process_plan_name, pp.parameters, COPY_NUM as copy, to_char(pil.START_DTM, 'DDMONYY-HH24:MI') start_tm, to_char(pil.END_DTM, 'DDMONYY-HH24:MI') end_tm, PHASE, 
decode(nvl(PROCESS_STATUS, 0),
                 0, 'NULL - initial value',
                 1, '1-Running',
                 2, '2-Paused',
                 3, '3-Stopped - request ',
                 4, '4-Stopped - timeout',
                 5, '5-Hard stop - request',
                 6, '6-Hard stop - timeout',
                 7, '7-Success',
                 8, '8-Finished - controlled',
                 9, '9-Failed',
                 10,'10-Unfinished (crash?)',
                 11,'11-Did not start'
                 ) process_status, pil.PROCESS_INSTANCE_ID
from processinstancelog pil, processdefinition pd, processlog pl, processplan pp
where pil.PROCESS_def_ID=pd.PROCESS_def_ID
and pil.process_id=pl.process_id
and pp.process_def_id = pil.PROCESS_def_ID
and pl.plan_number=pp.plan_number
and pil.START_DTM > '18-JUL-09'
and lower(process_plan_name) like '%rate%'
order by pil.START_DTM asc, process_plan_name, process_status, copy_num asc;

-- --------------------------------------------------------------------
-- File info
-- --------------------------------------------------------------------

col mfid for 999999999
col job_type_name for a20 trunc
col FILE_SUBTYPE_NAME for a20 trunc
col FILE_TYPE_NAME for a14
col pathname for a55
select mf.MANAGED_FILE_ID mfid, ft.file_type_name, FILE_SUBTYPE_NAME, mf.pathname,
to_char(mf.CREATED_DTM, 'DDMONYY HH24:MI:SS') created, 
decode(nvl(FILE_STATUS, 0),
                1,'1-Live.',
                2,'2-Being deleted.',
                3,'3-Deleted.',
                4,'4-Superseded.') mf_filestatus
from managedfile mf 
	join filesubtype f on mf.FILE_TYPE_ID=f.FILE_TYPE_ID
		and  mf.FILE_SUBTYPE=f.FILE_SUBTYPE
	join filetype ft on mf.FILE_TYPE_ID=ft.FILE_TYPE_ID
where mf.CREATED_DTM > '01-APR-11'
and mf.MANAGED_FILE_ID in (18130453, 18131111);

-- --------------------------------------------------------------------
-- Small usage sets
-- --------------------------------------------------------------------
col discount_data for a32 trunc
col EVENT_SOURCE for a16
SELECT ACCOUNT_NUM, EVENT_SEQ, EVENT_SOURCE, EVENT_TYPE_ID, EVENT_REF, CREATED_DTM, EVENT_DTM, EVENT_COST_MNY, MANAGED_FILE_ID, discount_data
FROM COSTEDEVENT WHERE ACCOUNT_NUM IN 
	(SELECT ACCOUNT_NUM FROM ACCOUNT WHERE CUSTOMER_REF = 'C0001347131')
	and created_dtm>=to_date('26FEB11','DDMONYY');

-- --------------------------------------------------------------------
-- Event file types & RTDP retention
-- --------------------------------------------------------------------
select et.event_type_name, ft.file_type_name, fst.file_subtype_name, efe.keep_for_days_num, fst.file_subtype_desc
from eventfileevents efe
    join eventtype et on et.event_type_id = efe.event_type_id
    join filetype ft on ft.file_type_id = efe.file_type_id
    join filesubtype fst on fst.file_subtype = efe.file_subtype and fst.file_type_id=efe.file_type_id;
    
-- --------------------------------------------------------------------
-- Common tasks
-- --------------------------------------------------------------------

select count(*) from job where job_status=2;
select count(*) from managedfile where JOB_FILE_STATUS=1;
select count(*) from jobhasfile where JOB_FILE_STATUS=1;

-- cancel jobs - make sure to catch associated jobhasfile records
update job set JOB_STATUS=7 where job_status=6 AND LAST_UPDATE_DTM > '01-JUL-08';
update jobhasfile set JOB_FILE_STATUS=4 where JOB_FILE_STATUS=2;

-- -----------------------------------------
-- For all rows of the SCHEDULELOG, TASKLOG, PROCESSLOG, and PROCESSINSTANCELOG tables that do not have an END_DTM set, the END_DTM must be set.
-- This ensures that System Monitor shows the process as being finished.

-- Orphaned scedulelogs
select to_char(start_dtm, 'DD-MM-YYYY HH24:MI:SS') startdtm, to_char(end_dtm, 'DD-MM-YYYY HH24:MI:SS') endt
from SCHEDULELOG
where END_DTM is null;

-- Orphaned tasklogs
select task_name, to_char(start_dtm, 'DD-MM-YYYY HH24:MI:SS') startdtm, to_char(end_dtm, 'DD-MM-YYYY HH24:MI:SS') endt
from TASKLOG tl, task t
where tl.task_id=t.task_id
and END_DTM is null;

-- Orphaned processlogs
select image_name, to_char(start_dtm, 'DD-MM-YYYY HH24:MI:SS') startdtm, to_char(end_dtm, 'DD-MM-YYYY HH24:MI:SS') endt
from PROCESSLOG pl, processdefinition pd
where pd.PROCESS_DEF_ID=pl.PROCESS_DEF_ID and END_DTM is null;

-- Orphaned processinstancelogs
select image_name, to_char(pil.start_dtm, 'DD-MM-YYYY HH24:MI:SS') startdtm, to_char(pil.end_dtm, 'DD-MM-YYYY HH24:MI:SS') endt
from PROCESSINSTANCELOG pil,  PROCESSLOG pl, processdefinition pd
where pil.process_id=pl.process_id
and pd.PROCESS_DEF_ID=pl.PROCESS_DEF_ID
and pil.END_DTM is null;
-- -----------------------------------------

select TASK_INSTANCE_ID, to_char(start_dtm, 'DD-MM-YYYY HH24:MI:SS') startdtm, to_char(end_dtm, 'DD-MM-YYYY HH24:MI:SS') endt
from PROCESSLOG where END_DTM <start_dtm;
select to_char(start_dtm, 'DD-MM-YYYY HH24:MI:SS') startdtm, to_char(end_dtm, 'DD-MM-YYYY HH24:MI:SS') endt from TASKLOG where END_DTM is null;
select count(*) from PROCESSINSTANCELOG where END_DTM is null;

update TASKLOG set end_dtm=to_date('2008/08/16 12:00:00', 'YYYY/MM/DD HH24:MI:SS') where END_DTM is null;
update PROCESSLOG set end_dtm=to_date('2008/08/16 12:00:00', 'YYYY/MM/DD HH24:MI:SS') where END_DTM is null;
update PROCESSINSTANCELOG set end_dtm=to_date('2008/08/15 22:00:00', 'YYYY/MM/DD HH24:MI:SS') where END_DTM is null;

update PROCESSLOG set end_dtm=to_date('2008/07/07 23:30:00', 'YYYY/MM/DD HH24:MI:SS')
where END_DTM<start_dtm
and start_dtm>'01-jul-08';

update PROCESSLOG set end_dtm=to_date('2008/08/15 22:30:00', 'YYYY/MM/DD HH24:MI:SS')
where TASK_INSTANCE_ID=1070324;

-- auto-update any
update PROCESSLOG set end_dtm=start_dtm+0.1
where END_DTM is null;
update PROCESSINSTANCELOG set end_dtm=start_dtm+0.1
where END_DTM is null;
update TASKLOG set end_dtm=start_dtm+0.1
where END_DTM is null;

-- -----------------------------------------
-- Clear down outstanding usage
-- -----------------------------------------
update job set job_status=7 
--where job_status in (1,2,3,6)
where job_status in (2)
and job_type_id=1
AND LAST_UPDATE_DTM > '25-FEB-11' 
; 

-- Also you would need to make sure that, in synch with this, you update 
-- the JOB.job_status to 7 (cancelled) of any associated JOBs (RERATEREQUEST.job_id), 
-- and the JOBHASFILE.job_file_status to 4 (cancelled) for any associated JOBHASFILE records.

update job j join JOBHASFILE jhf on jhf.job_id=j.job_id
--where job_status in (1,2,3,6)
set j.job_status= 7, 
	jhf.job_file_status=4
where job_status in (2)
AND j.LAST_UPDATE_DTM > '25-FEB-11' 
; 

-- 1, '1-Being created.',
-- 2, '2-Waiting to be processed.',
-- 3, '3-Being processed ',
-- 4, '4-Completed.',
-- 5, '5-Failed unrecoverable. Manual intervention required.',
-- 6, '6-Partial complete - Ready to be run again.',
-- 7, '7-Canceled',
-- 8, '8-Rejects to be processed',
-- 9, '9-Processed manually.',
-- 10,'10-In doubt completed.'

-- -----------------------------------------
-- capture usage_type breakdown
-- -----------------------------------------
select j.job_priority, to_char(j.last_update_dtm, 'DD-MON-HH24') as hour, count(*) as completed_jobs
from job j
where j.last_update_dtm >to_date('18-04-2011', 'dd-mm-yy')
and j.job_type_id=1
group by j.job_priority, j.job_type_id, to_char(j.last_update_dtm, 'DD-MON-HH24')
order by j.job_priority, j.job_type_id, to_char(j.last_update_dtm, 'DD-MON-HH24'); 