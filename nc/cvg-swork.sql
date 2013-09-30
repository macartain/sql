col image_name for a10
col PROCESS_PLAN_NAME for a15
col parameters for a30 trunc
col pa for 999
col seconds for 999,999.99
col total_errors for 999,999,999
col work_done for 999,999,999
select process_id,image_name,process_plan_name,parallelism pa,parameters,start_dtm,end_dtm,seconds,total_errors,work_done, 
((work_done/seconds)/parallelism) swdppsec,(((work_done+total_errors)/seconds)/parallelism) twdppsec
from ( 
	  select a.process_id, b.image_name, c.process_plan_name, a.start_count parallelism, c.parameters,
	  dense_rank() over (partition by process_id order by start_dat desc) dr 
  		,to_char(a.start_dtm,'DDMONYY hh24:mi:ss') start_dtm 
  		,to_char(a.end_dtm,'DDMONYY-hh24:mi:ss') end_dtm 
  		,((a.end_dtm - a.start_dtm)*24*60*60) seconds 
  		,a.total_errors 
  		,a.work_done 
  		from processlog a, processdefinition b, processplan c 
  		where a.process_def_id=b.process_def_id 
  		and a.plan_number=c.plan_number 
  		and a.process_def_id=c.process_def_id 
  		and a.PROCESS_ID=&proc_id
) where dr=1 
order by start_dtm desc;


-- basic proc_ids tester
select pl.PROCESS_ID, to_char(pl.START_DTM, 'DDMONYY-HH24:MI') start_tm, to_char(pl.END_DTM, 'DDMONYY-HH24:MI') end_tm
  from processinstancelog pil
       left join processlog pl
              on pl.process_id = pil.process_id
       join processdefinition pd
         on pd.process_def_id = pil.process_def_id
and pil.START_DTM > (sysdate - 900)
and lower(image_name) like '%bdd%'
;


col image_name for a10
col PROCESS_PLAN_NAME for a15
col parameters for a30 trunc
col pa for 999
col seconds for 999,999.99
col total_errors for 999,999,999
col work_done for 999,999,999
select process_id,image_name,process_plan_name,parallelism pa,parameters,start_dtm,end_dtm,seconds,total_errors,work_done, 
((work_done/seconds)/parallelism) swdppsec,(((work_done+total_errors)/seconds)/parallelism) twdppsec
from ( 
	  select a.process_id, b.image_name, c.process_plan_name, a.start_count parallelism, c.parameters,
	  dense_rank() over (partition by process_id order by start_dat desc) dr 
  		,to_char(a.start_dtm,'DDMONYY hh24:mi:ss') start_dtm 
  		,to_char(a.end_dtm,'DDMONYY-hh24:mi:ss') end_dtm 
  		,((a.end_dtm - a.start_dtm)*24*60*60) seconds 
  		,a.total_errors 
  		,a.work_done 
  		from processlog a, processdefinition b, processplan c 
  		where a.process_def_id=b.process_def_id 
  		and a.plan_number=c.plan_number 
  		and a.process_def_id=c.process_def_id 
  		and a.PROCESS_ID in 
  			(select pl.PROCESS_ID
			  from processinstancelog pil
			       left join processlog pl
			              on pl.process_id = pil.process_id
			       join processdefinition pd
			         on pd.process_def_id = pil.process_def_id
			and pil.START_DTM > (sysdate - 900)
			and lower(image_name) like '%bg%')
) where dr=1 
order by start_dtm desc;