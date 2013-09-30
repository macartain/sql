-- -------------------------------------------
-- all process plans - <=2.2
-- -------------------------------------------
col PROCESS_PLAN_NAME for a45 trunc
col PROCESS_PLAN_DESC for a45 trunc
col PARAMETERS for a35 word_wrap
col "pa/ct" for a8 trunc
col "def/plan" for a8 trunc
select pp.PROCESS_DEF_ID || '/' || pp.PLAN_NUMBER as "def/plan", DAEMON_BOO, PROCESS_PLAN_NAME, PROCESS_PLAN_DESC, 
    PARALLELISM || '/' || PROCESS_COUNT as "pa/ct", PARAMETERS, POLLING_DELAY, MAX_RUN_TIME  
from processplan pp
-- where pp.PROCESS_DEF_ID in (36)
where lower(PROCESS_PLAN_NAME) like '%bg%'
-- order by PROCESS_PLAN_NAME
order by pp.PROCESS_DEF_ID, pp.PLAN_NUMBER asc
;

col image_name for a12 trunc
col PROCESS_PLAN_NAME for a45 word_wrap
col PROCESS_PLAN_DESC for a45 word_wrap
col PARAMETERS for a35 word_wrap
col "pa/ct" for a8 trunc
col "def/plan" for a8 trunc
select image_name, pp.PROCESS_DEF_ID || '/' || pp.PLAN_NUMBER as "def/plan", DAEMON_BOO, PROCESS_PLAN_NAME, PROCESS_PLAN_DESC, 
PARALLELISM || '/' || PROCESS_COUNT as "pa/ct", PARAMETERS, MAX_RUN_TIME  
from processplan pp,  processdefinition pd
where  pp.process_def_id = pd.process_def_id
and (lower(pd.image_name) like '%bg%'
or lower(PROCESS_PLAN_NAME) like '%bg%')
-- and pp.PROCESS_DEF_ID in (8)
-- order by PROCESS_PLAN_NAME
order by pp.PROCESS_DEF_ID, pp.PLAN_NUMBER asc
;

-- -------------------------------------------
-- all process plans
-- -------------------------------------------
col PROCESS_PLAN_NAME for a45 trunc
col PROCESS_PLAN_DESC for a45 trunc
col PARAMETERS for a35 word_wrap
col "pa/ct" for a8 trunc
col "def/plan" for a8 trunc
select pp.PROCESS_DEF_ID || '/' || pp.PLAN_NUMBER as "def/plan", DAEMON_BOO, PROCESS_PLAN_NAME, PROCESS_PLAN_DESC, 
    PARALLELISM || '/' || PROCESS_COUNT as "pa/ct", PARAMETERS, POLLING_DELAY, MAX_RUN_TIME  
from processplan pp, processplandistribution ppd
where  pp.process_def_id = ppd.process_def_id
and pp.PLAN_NUMBER=ppd.PLAN_NUMBER
-- and lower(PROCESS_PLAN_NAME) like '%event%'
-- and pp.PROCESS_DEF_ID in (8)
-- order by PROCESS_PLAN_NAME
order by pp.PROCESS_DEF_ID, pp.PLAN_NUMBER asc
;

-- -------------------------------------------
-- all process plans for given processdef >2.2
-- -------------------------------------------
col PROCESS_PLAN_NAME for a45 trunc
col PROCESS_PLAN_DESC for a45 trunc
col PARAMETERS for a35 word_wrap
col "pa/ct" for a8 trunc
col "def/plan" for a8 trunc
select pp.PROCESS_DEF_ID || '/' || pp.PLAN_NUMBER as "def/plan", DAEMON_BOO, PROCESS_PLAN_NAME, 
    PROCESS_PLAN_DESC, PARALLELISM || '/' || PROCESS_COUNT as "pa/ct", PARAMETERS, POLLING_DELAY, MAX_RUN_TIME  
from processplan pp, processplandistribution ppd,  processdefinition pd
where  pp.process_def_id = ppd.process_def_id
and pp.process_def_id = pd.process_def_id
and pp.PLAN_NUMBER=ppd.PLAN_NUMBER
and pd.image_name = 'BG'
-- and pp.PROCESS_DEF_ID in (8)
-- order by PROCESS_PLAN_NAME
order by pp.PROCESS_DEF_ID, pp.PLAN_NUMBER asc
;

-- -------------------------------------------
-- process plan by task
-- -------------------------------------------
break on task_name
col TASK_NAME for a25 word_wrap
col taskdesc for a25 word_wrap
col PROCESS_PLAN_DESC for a40 word_wrap
col PROCESS_PLAN_NAME for a40 word_wrap
col EXECUTION_ORDER for 99 trunc
col MAX_RUN_TIME for 9,999 trunc
col EO for 99
select t.TASK_NAME, nvl(t.TASK_DESC, '-') as taskdesc,  EXECUTION_ORDER eo, pp.MAX_RUN_TIME, PROCESS_PLAN_NAME, PROCESS_PLAN_DESC  
from processplan pp, processplandistribution ppd, task t, taskhasprocessplan thpp
where  pp.process_def_id = ppd.process_def_id
and pp.PLAN_NUMBER=ppd.PLAN_NUMBER
and thpp.PLAN_NUMBER=pp.PLAN_NUMBER
and thpp.PROCESS_DEF_ID=pp.PROCESS_DEF_ID
(+) and t.task_id=thpp.task_id
--nd lower(PROCESS_PLAN_NAME) like '%event%'
order by t.task_id, EXECUTION_ORDER
;

-- -------------------------------------------
-- log fields
-- -------------------------------------------
select image_name, LOG_ATTR_1_NAME, LOG_ATTR_2_NAME, LOG_ATTR_3_NAME, LOG_ATTR_4_NAME, LOG_ATTR_5_NAME, 
        LOG_ATTR_6_NAME, LOG_ATTR_7_NAME, LOG_ATTR_8_NAME, LOG_ATTR_9_NAME, LOG_ATTR_10_NAME, LOG_ATTR_11_NAME, 
        LOG_ATTR_12_NAME, LOG_ATTR_13_NAME, LOG_ATTR_14_NAME, LOG_ATTR_15_NAME, LOG_ATTR_16_NAME, LOG_ATTR_17_NAME, 
        LOG_ATTR_18_NAME, LOG_ATTR_19_NAME, LOG_ATTR_20_NAME, LOG_ATTR_21_NAME, LOG_ATTR_22_NAME, LOG_ATTR_23_NAME, LOG_ATTR_24_NAME 
select image_name, LOG_ATTR_1_NAME, LOG_ATTR_2_NAME, LOG_ATTR_3_NAME, LOG_ATTR_4_NAME, LOG_ATTR_5_NAME, 
        LOG_ATTR_6_NAME, LOG_ATTR_7_NAME, LOG_ATTR_8_NAME, LOG_ATTR_9_NAME, LOG_ATTR_10_NAME, LOG_ATTR_11_NAME, 
        LOG_ATTR_12_NAME, LOG_ATTR_13_NAME, LOG_ATTR_14_NAME, LOG_ATTR_15_NAME, LOG_ATTR_16_NAME, LOG_ATTR_17_NAME, 
        LOG_ATTR_18_NAME, LOG_ATTR_19_NAME, LOG_ATTR_20_NAME, LOG_ATTR_21_NAME, LOG_ATTR_22_NAME, LOG_ATTR_23_NAME, LOG_ATTR_24_NAME 
from processdefinition
order by image_name;

-- -------------------------------------------
-- Andy LogFile Finder - Super Duper Version 
-- -------------------------------------------
SELECT 'ls -lrt '||(select string_value from gparams where name = 'SYSlogFileRootDir')||'/'||to_char(start_dtm,'yyyymmdd')||
'/'||PROCESS_INSTANCE_ID||'*.LOG' FIND_THE_LOGFILE,
(select string_value from gparams where name = 'SYSlogFileRootDir')||'/'||to_char(start_dtm,'yyyymmdd')||
'/'||PROCESS_INSTANCE_ID||'.'||to_char(start_dtm+1/(24*60*60),'hh24miss')||'.LOG' WHERE_IS_THE_LOGFILE_IRB,
unix_pid, WORK_DONE,total_errors, START_DTM, END_DTM 
FROM PROCESSINSTANCELOG 
WHERE PROCESS_ID IN 
        (SELECT PROCESS_ID FROM PROCESSLOG  WHERE PROCESS_DEF_ID IN
            ( -- SELECT PROCESS_DEF_ID FROM PROCESSPLAN
            -- WHERE PROCESS_PLAN_NAME LIKE '%Dup%'
            -- Or use Image Name if known
            SELECT pd.process_def_id FROM processdefinition pd
            WHERE pd.image_name = 'RATE')
        AND trunc(START_DTM) > trunc(gnvgen.systemDate-5) 
        --AND unix_pid = 6379)
ORDER BY START_DTM DESC;

-- -------------------------------------------
-- DRP-related
-- -------------------------------------------
col LOGICAL_HOST_NAME for a18
col PROCESS_DEF_ID for 9999
select pp.PROCESS_PLAN_NAME, ppd.* 
from processplandistribution ppd
    join processdefinition pd on pd.process_def_id = ppd.process_def_id
    join processplan pp on (pp.PLAN_NUMBER=ppd.PLAN_NUMBER and pp.process_def_id = ppd.process_def_id)
where pd.image_name = 'RATE'
order by ppd.start_dat, pp.plan_number;

col cache_dir for a20
select * from ratinghost;

-- -------------------------------------------
-- Common tasks
-- -------------------------------------------
update processplan set MAX_RUN_TIME=4420 where PROCESS_DEF_ID=53 and PLAN_NUMBER=5;
update processplan set POLLING_DELAY=10000 where PROCESS_DEF_ID=53 and PLAN_NUMBER=5;
update processplan set POLLING_DELAY=10000 where PROCESS_DEF_ID=53 and POLLING_DELAY=50;

update processplandistribution set PROCESS_COUNT=1, PARALLELISM=1 
where PROCESS_DEF_ID=17 and PLAN_NUMBER=2;

-- diable auto-start tasks
update task t 
set t.task_desc='Was auto-run at TM startup - disabled CAM - 20JUN2013'
where t.run_at_startup_boo='T';

update task t 
set t.run_at_startup_boo='F'
where t.run_at_startup_boo='T';

select * from task t
where t.run_at_startup_boo='T';