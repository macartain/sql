set lines 180
col parameters for a55 trunc
col process_plan_name for a30 trunc
col FAIL_MESSAGE_NAME for a5 trunc
col phase for a8 trunc
col copy for 9999
col process_status for a20 trunc
col proc_inst_id for 9999999
break on process_id report
compute sum of accs_del on process_id report

select process_plan_name, COPY_NUM as copy,
to_char(pil.START_DTM, 'DDMONYY-HH24:MI') start_tm, to_char(pil.END_DTM, 'DDMONYY-HH24:MI') end_tm,
PHASE, decode(nvl(PROCESS_STATUS, 0),
                 0, 'NULL - initial value',
                 1, '1-Running',
                 2, '2-Paused',
                 3, '3-Stopped-request ',
                 4, '4-Stopped-timeout',
                 5, '5-Hard stop-request',
                 6, '6-Hard stop-timeout',
                 7, '7-Success',
                 8, '8-Finished-controlled',
                 9, '9-Failed',
                 10,'10-Unfinished (crash?)',
                 11,'11-Did not start'
                 ) process_status,
pil.process_id, pil.PROCESS_INSTANCE_ID proc_inst_id,
-- pil.log_attr_1 total_ev, pil.log_attr_2 success_ev, pil.log_attr_7 rejects, pil.log_attr_10 filters, pil.log_attr_11 RO_bills
pil.log_attr_1 icos, pil.log_attr_4 eligible_accs, pil.log_attr_6 elig_custs, pil.log_attr_7 accs_del, pil.log_attr_8 custs_del
from processinstancelog pil, processdefinition pd, processlog pl, processplan pp
where pil.PROCESS_def_ID=pd.PROCESS_def_ID
and pil.process_id=pl.process_id
and pp.process_def_id = pil.PROCESS_def_ID
and pl.plan_number=pp.plan_number
and pil.START_DTM > to_date('14-MAR-2010', 'DD-MON-YYYY')
and lower(process_plan_name) like '%&lower_vpa%'
order by pil.START_DTM asc, process_id, process_plan_name, copy_num asc;
