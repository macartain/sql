-- --------------------------------------------------------------------
-- basics
-- --------------------------------------------------------------------
break on begin_interval_time skip 2
col phyrds              for 999,999,999
col begin_interval_time for a25
col filename            for a45

-- file stuff
select
   begin_interval_time,
   filename,
   phyrds, PHYWRTS, READTIM, WRITETIM, WAIT_COUNT
from  dba_hist_filestatxs
natural join
   dba_hist_snapshot;

-- time model
col value for 999,999,999,999.99
col snap for a35
col STAT_NAME for a18
select
   begin_interval_time snap,
   dhstm.STAT_NAME,
   dhstm.value
from  DBA_HIST_SYS_TIME_MODEL dhstm
natural join
   dba_hist_snapshot
where dhstm.STAT_NAME in ('DB CPU', 'DB time');
   
-- os stats
col value for 999,999,999,999.99
col snap for a35
col STAT_NAME for a25
select
   to_char(begin_interval_time, 'DDMONYY-HH24:MI:SS') snap,
   dhos.STAT_NAME,
   dhos.value
from  DBA_HIST_OSSTAT dhos
natural join
   dba_hist_snapshot
where dhos.STAT_NAME in ('LOAD', 'BUSY_TIME', 'IOWAIT_TIME', 'PHYSICAL_MEMORY_BYTES', 'SYS_TIME', 'USER_TIME', 'IDLE_TIME')
order by snap asc;

-- --------------------------------------------------------------------
-- Burleson - busy CPU
-- --------------------------------------------------------------------

select to_char(snaptime, 'DDMONYY-HH24:MI') snap_time, 'CPU busy', round(busydelta / (busydelta + idledelta) * 100, 2) "CPU Use (%)"
from (
    select s.begin_interval_time snaptime,
    os1.value - lag(os1.value) over (order by s.snap_id) busydelta,
    os2.value - lag(os2.value) over (order by s.snap_id) idledelta
    from dba_hist_snapshot s, dba_hist_osstat os1, dba_hist_osstat os2
    where
    s.snap_id = os1.snap_id and s.snap_id = os2.snap_id
    and s.instance_number = os1.instance_number and s.instance_number = os2.instance_number
    and s.dbid = os1.dbid and s.dbid = os2.dbid
        and s.instance_number = (select instance_number from v$instance)
        and s.dbid = (select dbid from v$database)
    and os1.stat_name = 'BUSY_TIME'
    and os2.stat_name = 'IDLE_TIME'
    and end_interval_time   between sysdate - 30 and sysdate
);

-- --------------------------------------------------------------------
-- Lewis - trend stats
-- --------------------------------------------------------------------

column        value      format        999,999,999,999
column        curr_value format        999,999,999,999
column        prev_value format        999,999,999,999
 
with base_line as (
        select  /*+ materialize */
                snp.snap_id,
                snp.begin_interval_time,
                snp.end_interval_time,
                ost.stat_name,
                ost.value
        from    dba_hist_snapshot       snp,
                dba_hist_osstat         ost
        where   snp.dbid            = (select dbid from v$database)
        and     snp.instance_number = (select instance_number from v$instance)
        and     end_interval_time   between sysdate - 30 and sysdate
        and     ost.dbid            = snp.dbid
        and     ost.instance_number = snp.instance_number
        and     ost.snap_id         = snp.snap_id
        and     ost.stat_name       = 'IDLE_TIME'
--      in ('LOAD', 'BUSY_TIME', 'IOWAIT_TIME', 'PHYSICAL_MEMORY_BYTES', 'SYS_TIME', 'USER_TIME', 'IDLE_TIME')
        /*                                                        */
)
select
        to_char(b1.end_interval_time,'DDMONYY-HH24:MI:SS')     start_of_delta,
        b1.stat_name          stat,
        b1.value              prev_value,
        b2.value              curr_value,
        b2.value - b1.value   delta,
        (b2.value - b1.value)/(b1.end_interval_time-b1.begin_interval_time) percent
from    base_line b1, base_line b2
where       b2.snap_id = b1.snap_id + 1
order by    b1.snap_id
;

-- --------------------------------------------------------------------
-- Available views at 10g
-- --------------------------------------------------------------------

SYS@BTSI1W30> select VIEW_NAME from dba_views where VIEW_NAME like 'DBA_HIST%';

VIEW_NAME
------------------------------
DBA_HIST_DATABASE_INSTANCE
DBA_HIST_SNAPSHOT
DBA_HIST_SNAP_ERROR
DBA_HIST_BASELINE
DBA_HIST_WR_CONTROL
DBA_HIST_DATAFILE
DBA_HIST_FILESTATXS
DBA_HIST_TEMPFILE
DBA_HIST_TEMPSTATXS
DBA_HIST_COMP_IOSTAT
DBA_HIST_SQLSTAT
DBA_HIST_SQLTEXT
DBA_HIST_SQL_SUMMARY
DBA_HIST_SQL_PLAN
DBA_HIST_SQL_BIND_METADATA
DBA_HIST_SQLBIND
DBA_HIST_OPTIMIZER_ENV
DBA_HIST_EVENT_NAME
DBA_HIST_SYSTEM_EVENT
DBA_HIST_BG_EVENT_SUMMARY
DBA_HIST_WAITSTAT
DBA_HIST_ENQUEUE_STAT
DBA_HIST_LATCH_NAME
DBA_HIST_LATCH
DBA_HIST_LATCH_CHILDREN
DBA_HIST_LATCH_PARENT
DBA_HIST_LATCH_MISSES_SUMMARY
DBA_HIST_LIBRARYCACHE
DBA_HIST_DB_CACHE_ADVICE
DBA_HIST_BUFFER_POOL_STAT
DBA_HIST_ROWCACHE_SUMMARY
DBA_HIST_SGA
DBA_HIST_SGASTAT
DBA_HIST_PGASTAT
DBA_HIST_PROCESS_MEM_SUMMARY
DBA_HIST_RESOURCE_LIMIT
DBA_HIST_SHARED_POOL_ADVICE
DBA_HIST_STREAMS_POOL_ADVICE
DBA_HIST_SQL_WORKAREA_HSTGRM
DBA_HIST_PGA_TARGET_ADVICE
DBA_HIST_SGA_TARGET_ADVICE
DBA_HIST_INSTANCE_RECOVERY
DBA_HIST_JAVA_POOL_ADVICE
DBA_HIST_THREAD
DBA_HIST_STAT_NAME
DBA_HIST_SYSSTAT
DBA_HIST_SYS_TIME_MODEL
DBA_HIST_OSSTAT_NAME
DBA_HIST_OSSTAT
DBA_HIST_PARAMETER_NAME
DBA_HIST_PARAMETER
DBA_HIST_UNDOSTAT
DBA_HIST_SEG_STAT
DBA_HIST_SEG_STAT_OBJ
DBA_HIST_METRIC_NAME
DBA_HIST_SYSMETRIC_HISTORY
DBA_HIST_SYSMETRIC_SUMMARY
DBA_HIST_SESSMETRIC_HISTORY
DBA_HIST_FILEMETRIC_HISTORY
DBA_HIST_WAITCLASSMET_HISTORY
DBA_HIST_DLM_MISC
DBA_HIST_CR_BLOCK_SERVER
DBA_HIST_CURRENT_BLOCK_SERVER
DBA_HIST_INST_CACHE_TRANSFER
DBA_HIST_ACTIVE_SESS_HISTORY
DBA_HIST_TABLESPACE_STAT
DBA_HIST_LOG
DBA_HIST_MTTR_TARGET_ADVICE
DBA_HIST_TBSPC_SPACE_USAGE
DBA_HIST_SERVICE_NAME
DBA_HIST_SERVICE_STAT
DBA_HIST_SERVICE_WAIT_CLASS
DBA_HIST_SESS_TIME_STATS
DBA_HIST_STREAMS_CAPTURE
DBA_HIST_STREAMS_APPLY_SUM
DBA_HIST_BUFFERED_QUEUES
DBA_HIST_BUFFERED_SUBSCRIBERS
DBA_HIST_RULE_SET
