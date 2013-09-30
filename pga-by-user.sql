-- --------------------------------------------------------------------
-- Set up
-- --------------------------------------------------------------------o
col name for a55
col MB as 999,999.99
select name,round(value/1024/1024,1) as MB from v$pgastat where unit = 'bytes';

-- --------------------------------------------------------------------
-- Live sorts/hash joins
-- --------------------------------------------------------------------o
set lines 200
select operation_type as type, policy, sid, round(active_time/1000000,2) as activesecs,
round(work_area_size/1024/1024,2) as wsize_MB, round(expected_size/1024/1024,2) as exp_MB,
round(actual_mem_used/1024/1024,2) as actualmem_MB,round(max_mem_used/1024/1024,2) as maxmem_MB, 
number_passes as passes, round(tempseg_size/1024/1024,2) as temp_MB 
from v$sql_workarea_active;

-- --------------------------------------------------------------------
-- History sorts/hash joins
-- --------------------------------------------------------------------o
set lines 200
col total for 999,999
col opt for 999,999
col onepass for 999,999
col mult for 999,999
col activesecs for 999.99
col op for a16 trunc
col id for 999
col policy for a8 trunc

select substr(sql_text,0,50) as sql, operation_type as op, operation_id as id, policy,
round(estimated_optimal_size/1024/1024,2) as est_opt_sz_MB, 
round(estimated_onepass_size/1024/1024,2) as est_one_sz_MB,
round(last_memory_used/1024/1024,2) as lastmem_MB, 
last_execution as last,
total_executions as total, 
optimal_executions as opt, 
onepass_executions as onepass, 
multipasses_executions as mult,
round(active_time/1000000,2) as activesecs, 
round(max_tempseg_size/1024/1024,2) as max_tmp_MB, 
round(last_tempseg_size/1024/1024,2) as last_tmp_MB
from v$sql_workarea swa, v$sql sq
where swa.address = sq.address 
and swa.hash_value = sq.hash_value
--and sql_text like 'select count(*) from ( select * from TBLSESSION%‘ 
-- find bad ones that spill over:
-- and max_tempseg_size is not null
order by sql;

-- --------------------------------------------------------------------
-- PGA by user
-- --------------------------------------------------------------------o
set pages 200
set lines 180
col name for a24
col module for a36 trunc
col sid for 9999
col "SID,PID" FOR A10
col process for a12
col 999,999,999 for value
col username for a12 trunc

select a.name, to_char(b.value, '999,999,999') value, c.sid||','||c.serial# "SID,PID", username, module, process, logon_time 
from v$statname a , v$sesstat b, v$session c
where a.statistic# = b.statistic#
and a.name like '%ga memory%'
and b.sid=c.sid
order by 3;

col pid     for 999999
col spid    for a10
col serial# for 999
col traceid for a12
select round(pga_alloc_mem/1024/1024,1) as alloc_mb, round(pga_used_mem/1024/1024,1) as used_mb, 
round(pga_max_mem/1024/1024,1) as max_mb, pid, spid, serial#, program, traceid, background, pga_freeable_mem
from v$process 
order by alloc_mb desc;

-- --------------------------------------------------------------------
-- Link with explain plan
-- --------------------------------------------------------------------o
select rpad(' ', depth*3)||operation||' '||options||nvl2(object_name, ' -> ','')||object_name||decode(search_columns,0,NULL,' ('||search_columns||')') as OP,
cost, cardinality as CARD, bytes, id as "id", access_predicates as "ACCESS", 
filter_predicates as filter,round(temp_space/1024/1024) as TMP_MB,
partition_start ||nvl2(partition_start, ' - ', '')||partition_stop as P, 
partition_id, other, other_tag, cpu_cost, io_cost, distribution, object_owner, parent_id,optimizer 
from ( select * 
        from V$SQL_PLAN 
        where address = hextoraw('0000000381E23CF0') 
        and hash_value = '1505362365' 
        and child_number = 0) t 
connect by prior id = parent_id start with id = 0 
order by id, position;

-- --------------------------------------------------------------------
-- Histogram of different types
-- --------------------------------------------------------------------o
SELECT LOW_OPTIMAL_SIZE/1024/1024 low_mb,(HIGH_OPTIMAL_SIZE+1)/1024/1024 high_mb,  optimal_executions,onepass_executions,multipasses_executions
FROM v$sql_workarea_histogram
WHERE total_executions != 0
and (low_optimal_size/1024/1024 >= 8 or total_executions > optimal_executions);

-- --------------------------------------------------------------------
-- Check PGA advisory
-- --------------------------------------------------------------------o
select round(pga_target_for_estimate/1024/1024) as est_mb,pga_target_factor as factor,
round(bytes_processed/1024/1024) as p_mb,round(estd_extra_bytes_rw/1024/1024) as extra_mb,
estd_pga_cache_hit_percentage as hit_ratio,estd_overalloc_count as est_over from v$pga_target_advice;


-- --------------------------------------------------------------------
-- From Pythian presentation
-- --------------------------------------------------------------------
-- The maximum PGA workarea is hard limited to 5% of pga_aggregate_target or a max of 100Mb
-- Can be controlled with _smm_max_size
-- Value is in KB !
-- 
-- One process can have many workareas 
-- Max total size can be controlled with _pga_max_size
-- Value is in bytes, default 200Mb
