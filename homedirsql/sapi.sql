select it.transaction_type,
       it.proc_result,
       to_char(it.exec_start_dtm,'DD/MM/YYYY HH24'),
       count(*)
from subadminapi.subadmin_icap_transactions it
where it.exec_start_dtm >= to_date('13/02/2010 11:00:00','DD/MM/YYYY HH24:MI:SS')
group by it.transaction_type,
       it.proc_result,
       to_char(it.exec_start_dtm,'DD/MM/YYYY HH24')
order by to_char(it.exec_start_dtm,'DD/MM/YYYY HH24'), it.transaction_type;
