-- ----------------------------------------------------
-- show all schedules
-- ----------------------------------------------------
col START_DATE for a20
col REPEAT_INTERVAL for a55
select schedule_name, schedule_type, TO_CHAR(start_date, 'DD-MM-YYYY HH24:MI:SS') startdtm, repeat_interval
from dba_scheduler_schedules;

-- ----------------------------------------------------
-- show all program-objects and their attributes
-- ----------------------------------------------------
col owner for a12
col PROGRAM_NAME for a25
col PROGRAM_TYPE for a20
col PROGRAM_ACTION for a45
col comments for a55
select owner, PROGRAM_NAME, PROGRAM_TYPE, PROGRAM_ACTION, ENABLED, COMMENTS from dba_scheduler_programs;

-- ----------------------------------------------------
-- schedule history
-- ----------------------------------------------------
col job_name for a30
col status for a10
col RUN_DURATION for a15
col cpu_used for a20
break on log_date
select TO_CHAR(log_date, 'DDMONYY-HH24:MI:SS') log_date, job_name, status, 
	TO_CHAR(req_start_date, 'DDMONYY-HH24:MI:SS') startdtm, 
	TO_CHAR(actual_start_date, 'DDMONYY-HH24:MI:SS') actualdtm, 
	run_duration, cpu_used
from dba_scheduler_job_run_details;

-- running jobs:
select job_name, session_id, running_instance, elapsed_time, cpu_used
from dba_scheduler_running_jobs;

-- job history:
select log_date  ,      job_name  ,      status
from dba_scheduler_job_log
where rownum <100
and job_name not like 'RLM%'
order by log_date asc;

-- all jobs and their attributes:
select * from dba_scheduler_jobs;

-- show all program-arguments:
select * from   dba_scheduler_program_args;

-- ----------------------------------------------------
-- JOBS
-- ----------------------------------------------------

-- scheduled jobs
col owner for a12
col PROGRAM_OWNER for a12
col PROGRAM_NAME for a25
col JOB_NAME for a30
col JOB_TYPE for a20
col JOB_ACTION for a35 wrap
col SCHEDULE_NAME for a25
col REPEAT_INTERVAL for a30 wrap
select OWNER, JOB_NAME, PROGRAM_NAME, SCHEDULE_NAME, REPEAT_INTERVAL, STATE, TO_CHAR(START_DATE, 'DDMONYY-HH24:MI') startdtm, TO_CHAR(NEXT_RUN_DATE, 'DDMONYY-HH24:MI') nextrun 
from dba_scheduler_jobs;


BEGIN
DBMS_JOB.CHANGE(2, NULL, next_date =>trunc(sysdate,'HH')+1/48, interval=>'SYSDATE + 1/48');
END;
/

SELECT JOB, NEXT_DATE, NEXT_SEC, FAILURES, BROKEN, substr(what,1,40) description
FROM DBA_JOBS;
/

BEGIN
DBMS_JOB.REMOVE(262464);
END;
/

-- running jobs
col sid for 9999
col what for a50 trunc
col LOG_USER for a12 trunc
SELECT SID, r.JOB, LOG_USER, r.THIS_DATE, r.THIS_SEC, j.what, broken, TOTAL_TIME
FROM DBA_JOBS_RUNNING r 
full outer join DBA_JOBS j on r.JOB = j.JOB;

--
--  Schedule a snapshot to be run on this instance every hour, on the hour

variable jobno number;
variable instno number;
begin
  select instance_number into :instno from v$instance;
  dbms_job.submit(:jobno, 'statspack.snap;', trunc(sysdate+1/24,'HH'), 'trunc(SYSDATE+1/24,''HH'')', TRUE, :instno);
  commit;
end;
/

select SNAP_ID,  TO_CHAR(SNAP_TIME, 'DD/MM/YYYY HH24:MI:SS') time, SNAP_LEVEL from STATS$SNAPSHOT
order by time;
