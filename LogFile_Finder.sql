-- Andy LogFile Finder - Super Duper Version (any day & any database) 
SELECT 'ls -lrt '||(select string_value from gparams where name = 'SYSlogFileRootDir')||'/'||to_char(start_dtm,'yyyymmdd')||
'/'||PROCESS_INSTANCE_ID||'*.LOG' FIND_THE_LOGFILE,
(select string_value from gparams where name = 'SYSlogFileRootDir')||'/'||to_char(start_dtm,'yyyymmdd')||
'/'||PROCESS_INSTANCE_ID||'.'||to_char(start_dtm+1/(24*60*60),'hh24miss')||'.LOG' WHERE_IS_THE_LOGFILE_IRB,
unix_pid, WORK_DONE,total_errors, START_DTM, END_DTM 
FROM PROCESSINSTANCELOG 
-- WHERE PROCESS_ID IN(  SELECT PROCESS_ID FROM PROCESSLOG  WHERE PROCESS_DEF_ID IN
--                        (
--                        SELECT PROCESS_DEF_ID FROM PROCESSPLAN
--                        WHERE PROCESS_PLAN_NAME LIKE '%Dup%'
                     -- Or use Image Name if known
                       -- SELECT pd.process_def_id FROM processdefinition pd
                       -- WHERE pd.image_name = 'RATE'
                       -- )
                      -- AND trunc(START_DTM) > trunc(gnvgen.systemDate-5) 
                      --AND unix_pid = 6379 
--                   )
ORDER BY START_DTM DESC;
