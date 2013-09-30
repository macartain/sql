
-- --------------------------------------------------------------------
-- Log switches
-- --------------------------------------------------------------------
col recid for 99999
col stamp for 999999999999
col thread# for 999
col sequence# for 9999999
col first_change# for 9999999999999
col next_change# for 9999999999999
col first_time for a13

select FIRST_CHANGE#, to_char(FIRST_TIME, 'DD-MM-YYYY HH24:MI:SS') as switch_ts from v$log_history
order by first_time
/

-- --------------------------------------------------------------------
-- Log switches - table
-- --------------------------------------------------------------------
set pages 24
col day for a10
select to_char(first_time,'YYYY-MM-DD') day,
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'00',1,0)),'999') "00",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'01',1,0)),'999') "01",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'02',1,0)),'999') "02",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'03',1,0)),'999') "03",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'04',1,0)),'999') "04",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'05',1,0)),'999') "05",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'06',1,0)),'999') "06",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'07',1,0)),'999') "07",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'08',1,0)),'999') "08",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'09',1,0)),'999') "09",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'10',1,0)),'999') "10",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'11',1,0)),'999') "11",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'12',1,0)),'999') "12",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'13',1,0)),'999') "13",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'14',1,0)),'999') "14",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'15',1,0)),'999') "15",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'16',1,0)),'999') "16",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'17',1,0)),'999') "17",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'18',1,0)),'999') "18",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'19',1,0)),'999') "19",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'20',1,0)),'999') "20",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'21',1,0)),'999') "21",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'22',1,0)),'999') "22",
to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'23',1,0)),'999') "23"
from v$log_history
group by to_char(first_time,'YYYY-MM-DD')
order by to_char(first_time,'YYYY-MM-DD');

-- --------------------------------------------------------------------
-- Archive logs - NB - VALID status does not mean directory exists!!
-- --------------------------------------------------------------------
col DESTINATION for a55
col error for a10
col DEST_NAME for a25
select DEST_NAME, STATUS, ERROR, DESTINATION 
from  V$ARCHIVE_DEST;

col  member for a45
select * from v$logfile;

col  member for a45
select * from v$log;

-- --------------------------------------------------------------------
-- Hourly thruput
-- --------------------------------------------------------------------

REM --------------------------------------------------------------------------------------------------
REM Author: Riyaj Shamsudeen @OraInternals, LLC
REM         www.orainternals.com
REM
REM Functionality: This script is to print redo size rates in a RAC claster
REM **************
REM
REM Source  : AWR tables
REM
REM Exectution type: Execute from sqlplus or any other tool.
REM
REM Parameters: No parameters. Uses Last snapshot and the one prior snap
REM No implied or explicit warranty
REM
REM Please send me an email to rshamsud@orainternals.com, if you enhance this script :-)
REM  This is a open Source code and it is free to use and modify.
REM Version 1.20
REM --------------------------------------------------------------------------------------------------
set colsep '|'
set lines 220
alter session set nls_date_format='DD-MON-YYYY HH24:MI';
set pagesize 10000
with redo_data as (
SELECT instance_number,
       to_date(to_char(redo_date,'DD-MON-YY-HH24:MI'), 'DD-MON-YY-HH24:MI') redo_dt,
       trunc(redo_size/(1024 * 1024),2) redo_size_mb
 FROM  (
  SELECT dbid, instance_number, redo_date, redo_size , startup_time  FROM  (
    SELECT  sysst.dbid,sysst.instance_number, begin_interval_time redo_date, startup_time,
  VALUE -
    lag (VALUE) OVER
    ( PARTITION BY  sysst.dbid, sysst.instance_number, startup_time
      ORDER BY begin_interval_time ,sysst.instance_number
     ) redo_size
  FROM sys.wrh$_sysstat sysst , DBA_HIST_SNAPSHOT snaps
WHERE sysst.stat_id =
       ( SELECT stat_id FROM sys.wrh$_stat_name WHERE  stat_name='redo size' )
  AND snaps.snap_id = sysst.snap_id
  AND snaps.dbid =sysst.dbid
  AND sysst.instance_number  = snaps.instance_number
  AND snaps.begin_interval_time> sysdate-30
   ORDER BY snaps.snap_id )
  )
)
select  instance_number,  redo_dt, redo_size_mb,
    sum (redo_size_mb) over (partition by  trunc(redo_dt)) total_daily,
    trunc(sum (redo_size_mb) over (partition by  trunc(redo_dt))/24,2) hourly_rate
   from redo_Data
order by redo_dt, instance_number
/

-- --------------------------------------------------------------------
-- Common tasks
-- --------------------------------------------------------------------

-- force a log rollover
ALTER SYSTEM SWITCH LOGFILE;

-- see how long a logfile switch is taking
select * from v$system_event
where event in ('log file sync','log file parallel write');

ALTER DATABASE ADD LOGFILE GROUP 4 ('/data0/oradata/GNVPRD1/redo04a.log', '/data1/oradata/GNVPRD1/redo04b.log') SIZE 100M;

select LOG_MODE from v$database;
select * from v$log;
select * from V$ARCHIVE_DEST;
-- or for summary of above:
ARCHIVE LOG LIST

-- if not set by init/spfile, this will start auto-archiving
ALTER SYSTEM ARCHIVE LOG START;
ALTER SYSTEM ARCHIVE LOG STOP;

alter system set log_archive_dest='/data0/oradata/GNVPRD1/arch' scope=both;

-- change archivelog mode
SYS@BTRETSI2> shutdown immediate
SYS@BTRETSI2> startup mount
SYS@BTRETSI2> alter database (no)archivelog;
SYS@BTRETSI2> archive log list
SYS@BTRETSI2> alter database open;

-- change force logging mode
SQL> ALTER DATABASE force logging;
SQL> ALTER TABLESPACE users FORCE LOGGING;
To disable:
SQL> ALTER DATABASE no force logging;
SQL> ALTER TABLESPACE users NO FORCE LOGGING;
