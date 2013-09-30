set lines 180
col image_name for a8 trunc
col parameters for a45 trunc
col process_plan_name for a30 trunc
col FAIL_MESSAGE_NAME for a5 trunc
col phase for a8 trunc
col copy for 9999
col process_status for a12 trunc
col proc_inst_id for 9999999
col hours for 99.99

select pd.image_name,
	pp.process_plan_name, 
	pp.parameters, COPY_NUM as copy, pl.PROCESS_ID,
to_char(pil.START_DTM, 'DDMONYY-HH24:MI') start_tm, to_char(pil.END_DTM, 'DDMONYY-HH24:MI') end_tm, (pil.END_DTM-pil.START_DTM)*24 hours,
PHASE, decode(nvl(PROCESS_STATUS, 0),
                 0, 'NULL - initial value',
                 1, '1-Running',
                 2, '2-Paused',
                 3, '3-Stopped-request ',
                 4, '4-Max runtime',
                 5, '5-IMMstop-request',
                 6, '6-IMMstop-timeout',
                 7, '7-FIN-Success',
                 8, '8-FIN-Run errors',
                 9, '9-Ctrl Fail',
                 10,'10-Crash-no status',
                 11,'11-Did not start'
                 ) process_status, pil.PROCESS_INSTANCE_ID proc_inst_id
  from processinstancelog pil
       left join processlog pl
              on pl.process_id = pil.process_id
                 left join processplan pp
                        on pp.process_def_id = pl.process_def_id
                       and pp.plan_number = pl.plan_number
       join processdefinition pd
         on pd.process_def_id = pil.process_def_id
and pil.START_DTM > (sysdate - &NUM_DAYS_HISTORY)
and lower(image_name) like '%&lower_VPA%'
order by pil.START_DTM asc, process_plan_name, copy_num asc;

