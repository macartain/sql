exec dbms_stats.gather_table_stats('geneva_admin', 'COSTEDEVENT');

---------------------------------------------------------------------

select OWNER, TABLE_NAME, num_rows, blocks, empty_blocks, avg_space, chain_cnt, avg_row_len 
from dba_tables 
where table_name='COSTEDEVENT';

---------------------------------------------------------------------

col MB for 999,999,999.99
SELECT owner, table_name, NVL(num_rows*avg_row_len,0)/1024000 MB
FROM dba_tables
ORDER BY owner, table_name;

---------------------------------------------------------------------

col ALLOCATED_MB for 999,999,999.99
col REQUIRED_MB for 999,999,999.99

SELECT SUBSTR(s.segment_name,1,20) TABLE_NAME,
SUBSTR(s.tablespace_name,1,20) TABLESPACE_NAME,
ROUND(DECODE(s.extents, 1, s.initial_extent,(s.initial_extent + (s.extents-1) * s.next_extent))/1024000,2) ALLOCATED_MB,
ROUND((t.num_rows * t.avg_row_len / 1024000),2) REQUIRED_MB
FROM dba_segments s, dba_tables t
WHERE s.owner = t.owner
AND s.segment_name = t.table_name
-- and t.owner='CETEST'
--and t.table_name='COSTGROUPXREF'
ORDER BY ALLOCATED_MB;

col segment_name for a32
SELECT segment_name, SUBSTR(s.segment_name,1,20) TABLE_NAME,
SUBSTR(s.tablespace_name,1,20) TABLESPACE_NAME,
ROUND(DECODE(s.extents, 1, s.initial_extent,
(s.initial_extent + (s.extents-1) * s.next_extent))/1048576,2) ALLOCATED_MB, 
bytes/(1024*1024) M,
segment_type
FROM dba_segments s
where segment_name like 'ACCOUNTRAT%'
-- and t.owner='CETEST'
ORDER BY ALLOCATED_MB;

select owner, table_name, TABLESPACE_NAME, ROUND((t.num_rows * t.avg_row_len / 1048576),2) REQUIRED_MB 
from dba_tables t
where owner= 'CETEST';
