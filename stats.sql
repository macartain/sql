-- -------------------------------------------
-- Schema gather
-- -------------------------------------------

exec dbms_stats.gather_schema_stats( ownname=>'GENEVA_ADMIN',
method_opt=>'FOR ALL COLUMNS SIZE 1', -- will suppress histograms
degree=>8,
cascade=>TRUE,
estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE);

exec dbms_stats.gather_schema_stats( ownname=>'GENEVA_ADMIN', method_opt=>'FOR ALL COLUMNS SIZE 1', degree=>8, cascade=>TRUE, estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE);

-- -------------------------------------------
-- Stats level
-- -------------------------------------------
col table_name for a50
col statistics_name for a40
col STATISTICS_VIEW_NAME for a28
select STATISTICS_NAME, SESSION_STATUS, SYSTEM_STATUS, ACTIVATION_LEVEL, STATISTICS_VIEW_NAME 
from  v$statistics_level;

-- -------------------------------------------
-- Histogram totals & by table
-- -------------------------------------------

col owner for a25
col table_name for a35
col column_name for a45
select  owner, table_name, column_name, count(*)
from    dba_tab_histograms
group by owner, table_name, column_name
having count(*) > 2
order by owner, table_name, column_name;

-- or
select table_name, column_name, num_distinct, num_nulls, sample_size, density, histogram 
from user_tab_col_statistics 
where HISTOGRAM !='NONE'  
order by 1,2;

-- totals
select  sum(case when max_cnt > 2 then 1 else 0 end) histograms,
        sum(case when max_cnt <= 2 then 1 else 0 end) no_histograms
from (
    select table_name, max(cnt) max_cnt
        from (
            select table_name, column_name, count(*) cnt
                from dba_tab_histograms
                group by table_name, column_name
        ) group by table_name
);

-- -------------------------------------------
-- Delete histogram for table
-- -------------------------------------------

exec dbms_stats.gather_table_stats (ownname => 'GENEVA_ADMIN',
tabname => 'CUSTPRODUCTSTATUS',
estimate_percent => NULL,
method_opt => 'for all columns size 1',
cascade => true,
degree => 12);

-- 11g generate batch histogram delete
select 'exec dbms_stats.delete_column_stats(ownname=>''GENEVA_ADMIN'',tabname=>'''||table_name|| 
''', colname=>''' ||column_name|| ''',cascade_parts=>TRUE, col_stat_type=>''HISTOGRAM'');'
from user_tab_col_statistics
where HISTOGRAM !='NONE'  
order by 1;

-- -------------------------------------------
-- Status
-- -------------------------------------------

select table_name, NUM_ROWS, blocks, AVG_ROW_LEN, to_char(LAST_ANALYZED, 'DDMONYY HH24:MI:SS'), SAMPLE_SIZE, degree
from dba_tables
where owner='GENEVA_ADMIN'
order by LAST_ANALYZED asc;

where table_name in ('CUSTPRODUCTTARIFFDETAILS',
'CUSTHASPRODUCT',
'CUSTPRODUCTDISCOUNTUSAGE',
'CUSTPRODUCTSTATUS',
'CUSTPRODUCTTARIFFDETAILS',
'EVENTDISCOUNTSTEP',
'EVENTDISCOUNT',
'IPGRECLAIMTYPES',
'IPGRECLAIMEXCLUDEDPRODUCTS');

-- -------------------------------------------
-- Common tasks
-- -------------------------------------------

select value from v$parameter
where name='_optim_peek_user_binds';

alter system flush shared_pool;

-- lock a table
exec dbms_stats.lock_table_stats('GENEVA_ADMIN', 'COSTEDEVENT');
exec dbms_stats.lock_table_stats('GENEVA_ADMIN', 'REJECTEVENT');

-- Script
#!/bin/ksh
CONNECT=${DATABASE}@vod2204
echo `date +"%Y%m%d-%H:%M:%S"` - Starting stats collection...
sqlplus -s ${CONNECT}<<EOF
set serveroutput on
set timing on
-- schema
exec dbms_stats.lock_table_stats('GENEVA_ADMIN', 'COSTEDEVENT');
exec dbms_stats.lock_table_stats('GENEVA_ADMIN', 'REJECTEVENT');
exec dbms_stats.lock_table_stats('GENEVA_ADMIN', 'CPDUMANAGEREQUEST');
exec dbms_stats.gather_schema_stats( ownname=>'GENEVA_ADMIN', method_opt=>'FOR ALL COLUMNS SIZE 1', degree=>16, cascade=>TRUE, estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE);
exec dbms_stats.unlock_table_stats('GENEVA_ADMIN', 'COSTEDEVENT');
exec dbms_stats.unlock_table_stats('GENEVA_ADMIN', 'REJECTEVENT');
-- table
exec dbms_stats.gather_table_stats (ownname=>'GENEVA_ADMIN', tabname=>'TARIFFELEMENT', estimate_percent=>NULL,  method_opt => 'for all columns size 1',  cascade => true, degree => 2);
exec dbms_stats.gather_table_stats (ownname=>'GENEVA_ADMIN', tabname=>'TARIFFELEMENTBAND', estimate_percent=>NULL,  method_opt => 'for all columns size 1',  cascade => true, degree => 2);

EOF
echo `date +"%Y%m%d-%H:%M:%S"` - Done

-- get/set defaults for DBMS_STATS - 10g
select dbms_stats.get_param('METHOD_OPT') from dual;
select dbms_stats.get_param('ESTIMATE_PERCENT') from dual;
select dbms_stats.get_param('DEGREE') from dual;
select dbms_stats.get_param('GRANULARITY') from dual;
select dbms_stats.get_param('CASCADE') from dual;
select dbms_stats.get_param('NO_INVALIDATE') from dual;

exec dbms_stats.set_param(pname=>'METHOD_OPT',pval=>'FOR ALL COLUMNS SIZE 1');

-- check & disable default job
select owner, job_name, enabled FROM dba_scheduler_jobs;      -- show default jobs

SELECT JOB_NAME, SCHEDULE_NAME, SCHEDULE_TYPE, ENABLED
FROM DBA_SCHEDULER_JOBS
WHERE PROGRAM_NAME = 'GATHER_STATS_PROG';

EXECUTE DBMS_SCHEDULER.DISABLE('GATHER_STATS_JOB');

-- see how various advisories are set

SELECT STATISTICS_NAME, ACTIVATION_LEVEL, SYSTEM_STATUS, STATISTICS_VIEW_NAME, SESSION_SETTABLE
FROM v$statistics_level;

-- see http://www.psoug.org/reference/dbms_stats.html
-- for 11g R1

-- -------------------------------------------
-- System stats - one-off
-- -------------------------------------------

-- In Oracle Database 10g the use of systems statistics is enabled by default and
-- system statistics are automatically initialized with heuristic default values; these
-- values do not represent your actual system. When you gather system statistics in
-- Oracle Database 10g they will override these initial values. To gather system
-- statistics you can use DBMS_STATS.GATHER_SYSTEM_STATS during your peak
-- workload time window.
-- At the beginning of the peak workload window execute the following command:

BEGIN
DBMS_STATS.GATHER_SYSTEM_STATS(‘START’);
END;
/

-- At the end of the peak workload window execute the following command:

BEGIN
DBMS_STATS.GATHER_SYSTEM_STATS(‘END’);
END;
/

-- Oracle recommends gathering system statistics during a representative workload,
-- ideally at peak workload time. You will only have to gather system statistics once.
-- System statistics are not automatically collected as part of new statistics gather job
-- (see the automatic statistics gathering job section below for more details).

-- Likewise for the fixed object views:
BEGIN
DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;
END;
/

-- --------------------------------------------------------------------
-- Variant explain plans
-- --------------------------------------------------------------------

select hash_value, sql_id, count(*) from  (
	select hash_value, sql_id, plan_hash_value
	from v$sql
	group by hash_value, sql_id, plan_hash_value
) group by hash_value, sql_id
having count(*) > 1
--and hash_value = 2008808730
order by 2 desc;

-- --------------------------------------------------------------------
-- All explain plans for an object
-- --------------------------------------------------------------------

select
        t.plan_table_output
from    (
        select
                sql_id, child_number
        from
                v$sql
        where
                hash_value in (
                        select  from_hash
                        from    v$object_dependency
                        where   to_name = 'LOCKEDACCOUNT'
                )
        ) v,
        table(dbms_xplan.display_cursor(v.sql_id, v.child_number)) t
;

select * from table(dbms_xplan.display_cursor('33wqw5qvawa92', null)); -- null the child num else assumes 0

-- after explain plan for...
select * from table(dbms_xplan.display)

select * from table (dbms_xplan.display(null, null, 'advanced'))
-- table_name, stmt_id, format, filter_preds

-- from script
alter session force parallel DDL;
alter session force parallel DML;
alter session force parallel query;

explain plan for
INSERT /*+ append parallel(thrf) */ INTO tariffhasratingtariff thrf
   (SELECT /*+ parallel (bck,8) */ tariff_id, rating_tariff_id, catalogue_change_id
      FROM tariffhasratingtariff_bck bck
     WHERE bck.catalogue_change_id = gnvgen.liveBillingCatalogueID ('ZAR'));

select * from table(dbms_xplan.display);
