-- --------------------------------------------------------------------
-- TABLESPACE - basics
-- --------------------------------------------------------------------
col TABLESPACE_NAME for a24
col BLK for a4
COL EXT_SIZE FORMAT A24 HEADING "Ext Size I/N/Min"
COL EXT_LIMITS FORMAT A18 HEADING "Limits Min/Max/%"
select TABLESPACE_NAME, (BLOCK_SIZE/1024) ||'K' BLK,
(INITIAL_EXTENT/1024 ||'K/' || NEXT_EXTENT/1024|| 'K/' || MIN_EXTLEN/1024||'K') EXT_SIZE,
(MIN_EXTENTS || '/' || DECODE(MAX_EXTENTS,2147483645,'UNL',MAX_EXTENTS)|| '/' || PCT_INCREASE) EXT_LIMITS,
 MIN_EXTLEN/1024  "MinExtLen", extent_management,
segment_space_management ASSM, SUBSTR(allocation_type,1,7) ALLOC, STATUS
from dba_tablespaces;


col block_size for a5
col EXT_SIZE_MB for a20
col SEGMENT_SPACE_MANAGEMENT for a7 heading "SEGMENT|SPACE|MGMT"
col EXTENT_MANAGEMENT for a7 heading "EXTENT|MGMT"
col ALLOCATION_TYPE for a10 heading "ALLOCATION|TYPE"
 select TABLESPACE_NAME, BLOCK_SIZE/1024||'K' as BLOCK_SIZE, EXTENT_MANAGEMENT,
 SEGMENT_SPACE_MANAGEMENT, ALLOCATION_TYPE, 
 nvl2(to_char(NEXT_EXTENT), to_char(NEXT_EXTENT/(1024*1024)), 'AUTO') as EXT_SIZE_MB 
 from dba_tablespaces
 order by TABLESPACE_NAME;

-- --------------------------------------------------------------------
-- TABLE - Basic storage info
-- --------------------------------------------------------------------
col table_name for a27 trunc
col TS for a20 trunc
col IOT_NAME for a5 trunc
col IOT for a20 trunc
col IniT for 999
col MaxT for 999
col FL for 999
col FLG for 999
col PCF for 999
col PCU for 999
col "InExt(K)" for 9,999,999
col NxExt for 9,999,999
col MnE for 999
col MB for 999,999.99
col deg for 999 trunc
col pool for a7 trunc
col TS for a15 trunc

select table_name, TABLESPACE_NAME TS, IOT_NAME, pct_free PCF, pct_used PCU,
INI_TRANS IniT, MAX_TRANS MaxT, 
(INITIAL_EXTENT/1024/1024) "InExt(K)", NEXT_EXTENT NxExt, min_extents, max_extents,
freelists FL, freelist_groups FLG, (num_rows*avg_row_len)/1024/1024 as MB
from dba_tables
where 
owner='GENEVA_ADMIN'
-- and table_name not like 'AQ$%'
-- and iot_name is null
and TABLESPACE_NAME='USERS'
-- and table_name like 'CUSTPRODRAT%'
-- table_name in (
-- 'COSTEDEVENT',
-- added CAM at ST 'CUSTFILTERELEMENT',
--'ACCOUNT',
-- 'ACCOUNTRATING',
--'CUSTEVENTSOURCE',
--'CUSTHASPRODUCT',
--'CUSTPRODUCTDETAILS',
--'CUSTPRODUCTSTATUS',
--'EVENTRESERVATION',
--'CUSTEVENTSOURCE',
--'ACCOUNTDETAILS',
--'RATINGREVENUESUMMARY',
-- 'ACCOUNTRATING',
-- 'ACCOUNTRATINGSUMMARY',
-- 'CUSTPRODINVOICEDISCUSAGE',
-- 'CUSTPRODUCTDISCOUNTUSAGE',
-- 'CUSTPRODRATINGDISCOUNT')
-- )
-- and buffer_pool in ('KEEP', 'RECYCLE')
--and buffer_pool in ('KEEP')
order by table_name
-- order by LAST_ANALYZED
;

-- --------------------------------------------------------------------
-- TABLE - Stats and size-related
-- --------------------------------------------------------------------
set pages 40
col owner for a12 trunc
col TBSP_NAME for a20 trunc
col pool for a7 trunc
col MB for 999,999.99
col blocks for 999,999,999
col NUM_ROWS for 999,999,999
col SAMPLE_SIZE for 999,999,999
col eblks for 999
col deg for 999

select * from (
    select  owner, table_name, TABLESPACE_NAME TBSP_NAME, blocks, empty_blocks eblks, to_char(LAST_ANALYZED, 'DDMONYY HH24:MI:SS') analysed, 
            AVG_ROW_LEN, NUM_ROWS, SAMPLE_SIZE, degree deg, (num_rows*avg_row_len)/1024/1024 as MB, buffer_pool pool
    from dba_tables
    where owner='GENEVA_ADMIN'
    --and TABLESPACE_NAME='USERS'
    -- and lower(table_name) like 'custprod%'
    -- and buffer_pool in ('KEEP', 'RECYCLE')
    --and buffer_pool in ('KEEP')
    -- and table_name in ('CUSTPRODUCTTARIFFDETAILS',
    -- 'IPGRECLAIMTYPES',
    -- 'IPGRECLAIMEXCLUDEDPRODUCTS')
    -- and table_name like 'ACCOUNTRAT%'
    -- order by table_name
    -- and num_rows is not null
    order by MB desc)
where rownum<300
;

-- buffered objects
select 'Table: ' || dt.table_name buffer_object, dt.buffer_pool
from dba_tables dt
where dt.buffer_pool in ('KEEP', 'RECYCLE')
union
select 'Index: ' || di.index_name buffer_object, di.buffer_pool
from dba_indexes di
where di.buffer_pool in ('KEEP', 'RECYCLE')
;

-- --------------------------------------------------------------------
-- Table/segment size
-- --------------------------------------------------------------------
SELECT   owner, segment_name, segment_type, tablespace_name,        
         ROUND ((BYTES) /1024/1024, 1) sizemb       
    FROM dba_segments       
   WHERE segment_name LIKE '%IPG%'      
ORDER BY segment_name;      

-- note the above will suppress LOB sizes - use following to breakdown:
select * from 
(SELECT 'TABLE', segment_name table_name, owner, round(bytes/1024/1024, 1) MB 
 FROM dba_segments 
 WHERE segment_type = 'TABLE' 
 UNION ALL 
 SELECT 'INDEX', i.table_name, i.owner, round(s.bytes/1024/1024, 1) MB 
 FROM dba_indexes i, dba_segments s 
 WHERE s.segment_name = i.index_name 
 AND   s.owner = i.owner 
 AND   s.segment_type = 'INDEX' 
 UNION ALL 
 SELECT 'LOBSEGMENT', l.table_name, l.owner, round(s.bytes/1024/1024, 1) MB 
 FROM dba_lobs l, dba_segments s 
 WHERE s.segment_name = l.segment_name 
 AND   s.owner = l.owner 
 AND   s.segment_type = 'LOBSEGMENT' 
 UNION ALL 
 SELECT 'LOBINDEX', l.table_name, l.owner, round(s.bytes/1024/1024, 1) MB 
 FROM dba_lobs l, dba_segments s 
 WHERE s.segment_name = l.index_name 
 AND   s.owner = l.owner 
 AND   s.segment_type = 'LOBINDEX')
where table_name like 'IPG%'
order by owner, table_name;

-- --------------------------------------------------------------------
-- DB - total size - summarise segment types by table name
-- --------------------------------------------------------------------
column table_name format a32 
column object_name format a32 
column owner format a15 
col mb for 999,999,999.99

SELECT /*+ parallel */
   owner, table_name, TRUNC(sum(bytes)/1024/1024) MB 
FROM 
(SELECT segment_name table_name, owner, bytes 
 FROM dba_segments 
 WHERE segment_type = 'TABLE' 
 UNION ALL 
 SELECT i.table_name, i.owner, s.bytes 
 FROM dba_indexes i, dba_segments s 
 WHERE s.segment_name = i.index_name 
 AND   s.owner = i.owner 
 AND   s.segment_type = 'INDEX' 
 UNION ALL 
 SELECT l.table_name, l.owner, s.bytes 
 FROM dba_lobs l, dba_segments s 
 WHERE s.segment_name = l.segment_name 
 AND   s.owner = l.owner 
 AND   s.segment_type = 'LOBSEGMENT' 
 UNION ALL 
 SELECT l.table_name, l.owner, s.bytes 
 FROM dba_lobs l, dba_segments s 
 WHERE s.segment_name = l.index_name 
 AND   s.owner = l.owner 
 AND   s.segment_type = 'LOBINDEX') 
WHERE owner in ('GENEVA_ADMIN') 
GROUP BY table_name, owner 
-- HAVING SUM(bytes)/1024/1024 > 10  /* Ignore really small tables */ 
-- ORDER BY TABLE_NAME
-- ORDER BY owner, SUM(bytes) desc, TABLE_NAME
ORDER BY owner, TABLE_NAME
;

-- --------------------------------------------------------------------
-- INDEX - basics
-- --------------------------------------------------------------------
col index_name for a30
col index_type for a12
col table_name for a26
col tsname for a22
col FL for 999
col FLG for 999
col PCF for 999
select index_name, index_type, table_name, TABLESPACE_NAME TSNAME, pct_free PCF,
freelists FL, freelist_groups FLG, to_char(LAST_ANALYZED, 'DD-MM-YYYY HH24:MI:SS') analysed,  LEAF_BLOCKS, CLUSTERING_FACTOR, buffer_pool
from dba_indexes
where owner='IST'
-- and index_name in (
-- 'ACCOUNT_PK',
-- 'ACCOUNTRATING_PK',
-- 'ACCOUNTRATINGSUMMARY_PK',
-- 'CUSTEVENTSOURCE_AK1',
-- 'CUSTHASPRODUCT_PK',
-- 'CUSTPRODUCTDETAILS_PK',
-- 'CUSTPRODUCTDISCOUNTUSAGE_AK1',
-- 'CUSTPRODUCTSTATUS_PK',
-- 'EVENTRESERVATION_PK',
-- 'ACCOUNTDETAILS_PK',
-- 'RATINGREVENUESUMMARY_UKP',
-- 'CUSTPRODRATINGDISCOUNT_UKP',
-- 'COSTEDEVENT_PK'
-- )
-- and table_name in (
-- 'COSTEDEVENT'
-- )
-- and buffer_pool in ('KEEP', 'RECYCLE')
order by index_name
;

-- --------------------------------------------------------------------
-- INDEX - Stats and size-related
-- --------------------------------------------------------------------
set pages 30
col owner for a12 trunc
col pool for a7 trunc
col MB for 999,999.99
col blocks for 999,999,999
col deg for a3
col cluster_factor for 999,999,999

select owner, INDEX_NAME, table_name, to_char(LAST_ANALYZED, 'DDMONYY HH24:MI') analysed, LEAF_BLOCKS, DISTINCT_KEYS, NUM_ROWS, SAMPLE_SIZE, degree deg, CLUSTERING_FACTOR cluster_factor, buffer_pool pool
from dba_indexes
where owner='GENEVA_ADMIN'
-- where lower(table_name) like 'custprod%'
-- and buffer_pool in ('KEEP', 'RECYCLE')
and buffer_pool in ('KEEP')
-- and table_name in ('PROCESSPLAN'
-- 'IPGRECLAIMTYPES',
-- 'IPGRECLAIMEXCLUDEDPRODUCTS',
-- )
-- and table_name like 'CUSTEVENT%'
-- order by table_name
order by table_name desc
;

-- --------------------------------------------------------------------
-- PARTITION - Basics
-- --------------------------------------------------------------------
col table_name for a27
col TS for a20
col IOT for a20
col IT for 999
col FL for 999
col FLG for 999
col PCF for 999
col PCU for 999
col PCT for 999
col MT for 999
col "IE(K)" for 9,999,999
col NE for 9,999,999
col MnE for 999
col MxE for 9,999,999,999
col pos for 999
col pool for a7
col HIGH_VALUE for a18
col partname for a12

select table_name, TABLESPACE_NAME TS, PARTITION_NAME partname, PARTITION_POSITION as pos, HIGH_VALUE, pct_free PCF, pct_used PCU,
INI_TRANS IT, MAX_TRANS MT, (INITIAL_EXTENT/1024/1024) "IE(K)", NEXT_EXTENT NE, MIN_EXTENT MnE,
MAX_EXTENT MxE, buffer_pool pool, LAST_ANALYZED, global_stats, user_stats
from dba_tab_partitions
where table_owner='GENEVA_ADMIN'
-- and TABLESPACE_NAME='CUSTOMER_TAB_TS_1'
-- and table_name in (
--'ACCOUNTRATING',
-- 'CUSTFILTERELEMENT',
--'ACCOUNT',
--'ACCOUNTRATING',
--'CUSTEVENTSOURCE',
--'CUSTHASPRODUCT',
--'CUSTPRODUCTDETAILS',
--'CUSTPRODUCTDISCOUNTUSAGE',
--'CUSTPRODUCTSTATUS',
--'EVENTRESERVATION',
--'CUSTEVENTSOURCE',
--'ACCOUNTDETAILS',
--'ACCOUNTRATINGSUMMARY',
--'RATINGREVENUESUMMARY',
--'CUSTPRODRATINGDISCOUNT'
--)
and buffer_pool in ('KEEP', 'RECYCLE')
order by table_name, partname asc
;

select buffer_pool, count(*)
from dba_tables 
group by buffer_pool;

-- --------------------------------------------------------------------
-- PARTITION - Perf-related
-- --------------------------------------------------------------------
col high_value for a15
col "size(MB)" for 999,999,999.99
col pos for 9999
select table_name, PARTITION_POSITION pos, PARTITION_NAME, high_value, tablespace_name, 
num_rows, (num_rows*AVG_ROW_LEN)/1024/1024 as "size(MB)", global_stats gst,
to_char(LAST_ANALYZED, 'DD-MM-YYYY HH24:MI:SS') last_analyzed
from dba_tab_partitions dtp
where dtp.table_owner = 'GENEVA_ADMIN'
and table_name like 'COSTED%'
order by table_name, PARTITION_POSITION;

-- --------------------------------------------------------------------
-- PARTITION - index stuff
-- --------------------------------------------------------------------
col high_value for a15
col "size(MB)" for 999,999,999.99
col "num_rows" for 999,999,999.99
select PARTITION_NAME, high_value, tablespace_name, PARTITION_POSITION,
num_rows,  global_stats gst,
to_char(LAST_ANALYZED, 'DD-MM-YYYY HH24:MI:SS') last_analyzed
from dba_ind_partitions dtp
where dtp.index_name like 'COSTEDEVENT%'
order by PARTITION_POSITION;

-- --------------------------------------------------------------------
-- data files - basics
-- --------------------------------------------------------------------
col FILE_NAME for a60
col mb for 999,999.99
col max for 999,999.99
break on TABLESPACE_NAME 
select TABLESPACE_NAME, FILE_NAME, status, AUTOEXTENSIBLE, BYTES/(1024*1024) as mb, MAXBYTES/(1024*1024) as max  
from DBA_DATA_FILES 
union
select TABLESPACE_NAME, FILE_NAME, status, AUTOEXTENSIBLE, BYTES/(1024*1024) as mb, MAXBYTES/(1024*1024) as max  
from DBA_temp_FILES 
order by TABLESPACE_NAME, FILE_NAME;

-- --------------------------------------------------------------------
-- Segment map
-- --------------------------------------------------------------------o
col "Segment" for a45
col "File Name" for a60
col "Partition" for a12
col blocks for 999,999
col file_id for 999

column timestamp new_value tstamp
select to_char( sysdate, 'mmddhh24mi' ) timestamp from dual;

select tablespace_name from dba_tablespaces order by 1;

accept x_tablespace prompt 'Tablespace :'
accept x_segment    prompt 'Segment :'

select a.file_id, a.block_id, a.bytes, a.blocks, '- - -   free   - - -' "Segment", null  "Partition", b.file_name "File Name"
from dba_free_space a,
     dba_data_files b
where a.tablespace_name = upper( '&x_tablespace' )
  and b.file_id = a.file_id
union
select a.file_id, a.block_id, a.bytes, a.blocks, 
       decode( upper( '&x_segment' ), 
               null, owner || '.' || a.segment_name,
               a.segment_name, a.segment_name,
               'used' ) "Segment",
       a.partition_name "Partition",
       b.file_name
from dba_extents a,
     dba_data_files b
where a.tablespace_name = upper( '&x_tablespace' )
  and b.file_id = a.file_id
order by file_id, block_id
/

-- --------------------------------------------------------------------
-- Common tasks
-- --------------------------------------------------------------------
SELECT * FROM V$DBFILE;

select count(*) from costedevent partition(p25);

-- activity on partition/table:
select partition_name, inserts, updates, deletes, timestamp
from all_tab_modifications
where table_owner = 'GENEVA_ADMIN'
and table_name = 'COSTEDEVENT'
and partition_name is not null
order by partition_name;

-- add tablespace
CREATE SMALLFILE TABLESPACE "API_DATA" LOGGING DATAFILE
'/Disk0/oradata/VOD2201/data01.dbf' SIZE 500M REUSE
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT  AUTO;

-- enable autoextend
alter database datafile '/Disk0/oradata/VOD2201/data01.dbf' autoextend on;
alter database datafile '/Disk0/oradata/BTSI2R22/undotbs01.dbf' autoextend off;

-- add datafile to tspace
ALTER TABLESPACE DATA ADD DATAFILE '/oradata3/O2/O2GP1R51/data02.dbf' SIZE 30000M AUTOEXTEND ON;

-- resize data file
ALTER DATABASE DATAFILE '/Disk0/oradata/VOD2201/users01.dbf' RESIZE 9000M;

-- change def tspace
alter user GENEVA_ADMIN default tablespace users;

-- add logfile
ALTER DATABASE ADD LOGFILE GROUP 5 ('/Disk0/oradata/O2GP1R51/redo05a.log','/Disk0/oradata/O2GP1R51/redo05b.log') SIZE 80M;
ALTER DATABASE ADD LOGFILE GROUP 6 ('/Disk0/oradata/O2GP1R51/redo06a.log','/Disk0/oradata/O2GP1R51/redo06b.log') SIZE 80M;

-- indexes for a table
col COLUMN_NAME for a35
break on INDEX_NAME skip 1
select * from user_ind_columns 
where TABLE_NAME='&table_name'
order by INDEX_NAME, COLUMN_POSITION;

-- constraints for a table
col type format a10
col cons_name format a30
select  decode(constraint_type,
        'C', 'Check',
        'O', 'R/O View',
        'P', 'Primary',
        'R', 'Foreign',
        'U', 'Unique',
        'V', 'Check view') type
,   constraint_name cons_name
,   status
,   last_change
from    dba_constraints
where   table_name like '&table_name'
order by 1;

-- disable a constraint
alter table CUSTPRODRATINGDISCOUNT disable constraint CUSTPRODRATINGDISCOUNT_UK2;
alter table CUSTPRODRATINGDISCOUNT drop constraint CUSTPRODRATINGDISCOUNT_UK2;

-- who participates in a foreign key?
select OWNER, CONSTRAINT_NAME, TABLE_NAME, R_OWNER, R_CONSTRAINT_NAME, SEARCH_CONDITION
from dba_constraints 
where CONSTRAINT_TYPE='R'
and R_CONSTRAINT_NAME='&CON_NAME';

-- disable referring foreign keys
set lines 100 pages 999
col discon format a100 
select 'alter table '||a.owner||'.'||a.table_name||' disable constraint
'||a.constraint_name||';' discon
from    dba_constraints a
,   dba_constraints b
where   a.constraint_type = 'R'
and     a.r_constraint_name = b.constraint_name
and a.r_owner  = b.owner
and     b.owner = '&table_owner'
and b.table_name = '&table_name'
/

-- buffered objects
select 'Table: ' || dt.table_name buffer_object, dt.buffer_pool
from dba_tables dt
where dt.buffer_pool in ('KEEP', 'RECYCLE')
union
select 'Index: ' || di.index_name buffer_object, di.buffer_pool
from dba_indexes di
where di.buffer_pool in ('KEEP', 'RECYCLE')
;

-- Add undo space
ALTER DATABASE DATAFILE '/Disk0/oradata/BTSI2R22/undotbs02.dbf' RESIZE 1000M;
-- 0r add new
create undo tablespace myundo datafile ‘/u02/oracle/test/undo_tbs.dbf’ size 500M autoextend ON next 5M; 

--Reduce tempspace - have to add new, drop old, change defaults for users

CREATE TEMPORARY TABLESPACE temp2 TEMPFILE '/u01/app/oracle/oradata/DB11G/temp02.dbf' SIZE 2G AUTOEXTEND ON NEXT 1M;

ALTER DATABASE DEFAULT TEMPORARY TABLESPACE temp2;

-- Switch all existing users to new temp tablespace.
BEGIN
  FOR cur_user IN (SELECT username FROM dba_users WHERE temporary_tablespace = 'TEMP') LOOP
    EXECUTE IMMEDIATE 'ALTER USER ' || cur_user.username || ' TEMPORARY TABLESPACE temp2';
  END LOOP;
END;
/

DROP TABLESPACE temp INCLUDING CONTENTS AND DATAFILES;

-- --------------------------------------------------------------------
-- report with table segment types only
-- --------------------------------------------------------------------
set lines 180 pages 2000 trimspool on
col table_name for a30
col tablespace_name for a30
col iot_name for a7 trunc
col ITL for 999
col FL for 999
col FLG for 999
col PCF for 999
col PCU for 999
col deg for a4
col pool for a9 trunc
select  dt.table_name, dt.TABLESPACE_NAME, dt.IOT_NAME, 
        dt.pct_free PCF, dt.pct_used PCU, dt.INI_TRANS ITL, 
        dt.freelists FL, dt.freelist_groups FLG,
        to_char(LAST_ANALYZED, 'DDMONYY HH24:MI:SS') analysed, 
        AVG_ROW_LEN, NUM_ROWS, SAMPLE_SIZE, degree, bytes/1024/1024 MB, dt.buffer_pool pool
from dba_tables dt
    left join dba_segments ds on ds.segment_name = dt.table_name
where dt.owner='GENEVA_ADMIN'
and segment_type = 'TABLE' 
order by table_name;

-- --------------------------------------------------------------------
-- report with all object types
-- --------------------------------------------------------------------
select  dt.owner, dt.table_name, TABLESPACE_NAME TBSP_NAME, 
        to_char(LAST_ANALYZED, 'DDMONYY HH24:MI:SS') analysed, 
        AVG_ROW_LEN, NUM_ROWS, SAMPLE_SIZE, ilv.MB, to_char(degree, '') deg, buffer_pool pool
from dba_tables dt
    join (  SELECT owner, table_name, TRUNC(sum(bytes)/1024/1024) MB 
            FROM 
            (SELECT segment_name table_name, owner, bytes 
            FROM dba_segments 
            WHERE segment_type = 'TABLE' 
            UNION ALL 
            SELECT i.table_name, i.owner, s.bytes 
            FROM dba_indexes i, dba_segments s 
            WHERE s.segment_name = i.index_name 
            AND   s.owner = i.owner 
            AND   s.segment_type = 'INDEX' 
            UNION ALL 
            SELECT l.table_name, l.owner, s.bytes 
            FROM dba_lobs l, dba_segments s 
            WHERE s.segment_name = l.segment_name 
            AND   s.owner = l.owner 
            AND   s.segment_type = 'LOBSEGMENT' 
            UNION ALL 
            SELECT l.table_name, l.owner, s.bytes 
            FROM dba_lobs l, dba_segments s 
            WHERE s.segment_name = l.index_name 
            AND   s.owner = l.owner 
            AND   s.segment_type = 'LOBINDEX')
            GROUP BY table_name, owner ) ilv 
                on ilv.table_name=dt.table_name
where dt.owner='GENEVA_ADMIN'
order by MB desc;