set lines 180
set pages 200
col sharable_mem for 99.99
col persistent_mem for 99.99
col runtime_mem for 99.99
col total_mem for 99.99

SELECT   A.username, COUNT(*), SUM (B.sharable_mem)/(1024*1024) sharable_mem,
         SUM (B.persistent_mem)/(1024*1024) persistent_mem,
         SUM (B.runtime_mem)/(1024*1024) runtime_mem,
         SUM (B.sharable_mem + B.persistent_mem + B.runtime_mem)/(1024*1024) total_mem
FROM     dba_users A left outer join v$sql B
ON       A.username IN (select username from dba_users)
AND      B.parsing_user_id = A.user_id
GROUP BY A.username;
