col job_status for a28
col job_type_name for a15
col jfn for 999
col pri for 999
break on job_type_name 
break on job_priority 
select job_type_name, 
job_priority pri, to_char(CREATED_DTM, 'YYYYMONDD-HH24:MM') created,
jhf.JOB_ID, jhf.MANAGED_FILE_ID, jhf.JOB_FILE_NUMBER jfn,
decode(nvl(j.JOB_STATUS, 0),
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
                 10,'10-In doubt completed.') job_status,
                 decode(nvl(jhf.JOB_FILE_STATUS, 0),
                 0,      '---------------',
                 1,      'Awaiting processing',
                 2,      'Being processed',
                 3,      'Processing complete',
                 4,      'Cancelled',
                 5,      'Being edited',
                 6,      'Superseded') job_file_status,               
                 to_char(jhf.LAST_UPDATE_DTM, 'YYYYMONDD-HH24:MM') updated, PROCESSED_TIDEMARK processed, VALID_TIDEMARK valid
from jobhasfile jhf, job j, jobtype jt
where j.job_id=jhf.job_id
and j.job_type_id=jt.job_type_id
and j.job_id in
    (select job_id from job where job_type_id in (1,23)
    and job_status in (3)
    )
and CREATED_DTM> sysdate-1
order by pri, created, updated;