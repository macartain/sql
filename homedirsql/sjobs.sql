col job_status for a25 trunc;
select JOB_ID, job_type_name, job_priority, to_char(j.CREATED_DTM, 'DDMONYY HH24:MI:SS') created, to_char(j.LAST_UPDATE_DTM, 'DDMONYY HH24:MI:SS') job_update,
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
AND j.LAST_UPDATE_DTM > '14-OCT-10'
order by j.LAST_UPDATE_DTM asc;
