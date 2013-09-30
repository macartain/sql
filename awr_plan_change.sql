set lines 180
col execs for 999,999,999
col avg_etime for 999,999.999
col rows_per_exec for 999,999,999.9
col pio_per_exec for 999,999,999.9
col lio_per_exec for 999,999,999.9
col start_snap for a12 trunc
col END_INTERVAL_TIME for a12 trunc
col node for 9999
break on plan_hash_value on startup_time skip 1
select ss.snap_id, ss.instance_number node, to_char(begin_interval_time,'DDMONYY-HH24Mi') start_snap, to_char(END_INTERVAL_TIME,'DDMONYY-HH24Mi') end_snap, 
sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
(ROWS_PROCESSED_DELTA/decode(nvl(ROWS_PROCESSED_DELTA,0),0,1,executions_delta)) rows_per_exec,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) lio_per_exec,
(DISK_READS_DELTA/decode(nvl(DISK_READS_DELTA,0),0,1,executions_delta)) pio_per_exec
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = nvl('&sql_id','4dqs2k5tynk61')
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
order by 1, 2, 3
/


-- http://oraganism.wordpress.com/2011/12/14/a-dba_hist_sqlstat-query-that-i-am-very-fond-of/
col exe for 9999
col eftch for 9999
col phv for 999999999
col snap_id for 9999999
col SAMPLE_END for a14
col rows_per_exec for 999,999,999.9
col pio_per_exec for 999,999,999.9
col lio_per_exec for 999,999,999.9
col iowait_per_exec for 999,999,999.9
col cputime_exec for 999,999,999.9
col msec_exec for 999,999,999.9
col module for a12 trunc
column sample_end format a21

select s.snap_id, to_char(min(s.end_interval_time),'DYDDMONYY HH24:MI') sample_end
, q.sql_id
, q.plan_hash_value phv
, sum(q.EXECUTIONS_DELTA) exe
, round(sum(END_OF_FETCH_COUNT_DELTA)/greatest(sum(executions_delta),1),1) eftch
, round(sum(ROWS_PROCESSED_DELTA)/greatest(sum(executions_delta),1),1) rows_per_exec
, round(sum(DISK_READS_delta)/greatest(sum(executions_delta),1),1) pio_per_exec
, round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec
, round((sum(IOWAIT_DELTA)/greatest(sum(executions_delta),1)/1000),1) iowait_per_exec
, round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_exec
, round((sum(CPU_TIME_DELTA)/greatest(sum(executions_delta),1)/1000),1) cputime_exec
from dba_hist_sqlstat q, dba_hist_snapshot s
where q.SQL_ID=trim('&sqlid.')
and s.snap_id = q.snap_id
and s.dbid = q.dbid
and s.instance_number = q.instance_number
group by s.snap_id
, q.sql_id
, q.module
, q.plan_hash_value
order by s.snap_id, q.sql_id, q.plan_hash_value
/
