column table_name format a32 
column object_name format a32 
column owner format a15 
col mb for 999,999,999.99
 
DEFINE  lower_owner = 'geneva_admin'

SELECT 
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
WHERE owner in UPPER('&lower_owner') 
GROUP BY table_name, owner 
HAVING SUM(bytes)/1024/1024 > 10  /* Ignore really small tables */ 
ORDER BY SUM(bytes) desc 
;
