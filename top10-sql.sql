
set linesize 160
set pagesize 100

column "Seconds"    format 99999990.99
column "Gets/Exec"  format 99999990.99
column "Reads/Exec" format 99999990.99
column "Rows/Exec"  format 99999990.99
column "version_count" format 99999999

Prompt Top 10 by CPU:

SELECT * FROM
(SELECT substr(sql_text,1,80) sql,
        hash_value, cpu_time/(1000000) "Seconds"
   FROM V$SQLAREA
  WHERE cpu_time > 10000
  ORDER BY 3 DESC)
  WHERE rownum <= 10 ;

Prompt Top 10 by Buffer Gets:

SELECT * FROM
(SELECT substr(sql_text,1,80) sql,
        buffer_gets, executions, buffer_gets/executions "Gets/Exec",
        hash_value,address
   FROM V$SQLAREA
  WHERE buffer_gets > 10000
    AND executions != 0
 ORDER BY buffer_gets DESC)
WHERE rownum <= 10;

Prompt Top 10 by Physical Reads:

SELECT * FROM
(SELECT substr(sql_text,1,80) sql,
        disk_reads, executions, disk_reads/executions "Reads/Exec",
        hash_value,address
   FROM V$SQLAREA
  WHERE disk_reads > 1000
    AND executions != 0
 ORDER BY disk_reads DESC)
WHERE rownum <= 10;

Prompt Top 10 by Executions:

SELECT * FROM
(SELECT substr(sql_text,1,80) sql,
        executions, rows_processed, rows_processed/executions "Rows/Exec",
        hash_value,address
   FROM V$SQLAREA
  WHERE executions > 100
 ORDER BY executions DESC)
WHERE rownum <= 10;

Prompt Top 10 by Parse Calls:

SELECT * FROM
(SELECT substr(sql_text,1,80) sql,
        parse_calls, executions, hash_value,address
   FROM V$SQLAREA
  WHERE parse_calls > 1000
 ORDER BY parse_calls DESC)
WHERE rownum <= 10;

Prompt Top 10 by Sharable Memory:

SELECT * FROM
(SELECT substr(sql_text,1,80) sql,
        sharable_mem, executions, hash_value,address
   FROM V$SQLAREA
  WHERE sharable_mem > 1048576
 ORDER BY sharable_mem DESC)
WHERE rownum <= 10;

Prompt Top 10 by Version Count:

SELECT * FROM
(SELECT substr(sql_text,1,80) sql,
        version_count, executions, hash_value,address
   FROM V$SQLAREA
  WHERE version_count > 20
 ORDER BY version_count DESC)
WHERE rownum <= 10;

#!/usr/bin/ksh
# set -x
# chkvercnt
# This script check for high version counts
# Alejandro

. /mysrv/scripts/cshrc/817/.profile
cd /mysrv/scripts/av/freezedb/chkvercnts

ts=`date +%d%m%Y%H%M`
export ts
sid=$1
newsid=`echo $sid | tr '[a-z]' '[A-Z]'`
sqlplus -s sys/$x1@$sid <<eof1
set pages 100 feed off veri off flush off lines 120
column  sql_text for a60

spool $sid.$ts.chkvercnt

prompt * Get the statements with the highests version counts.
prompt

select  sql_text,
        version_count,
        executions,
        address
from    v$sqlarea where version_count>= (select        max(version_count) -5
                                          from          v$sqlarea)
order   by version_count
/

prompt
prompt * v$sql_shared_cursor - Use the describe to identify the type of mismatch
prompt

describe v$sql_shared_cursor

select  *
from    v$sql_shared_cursor
where   KGLHDPAR =
        (select address
         from   v$sqlarea
         where  version_count=(select   max(version_count)
                               from     v$sqlarea))
/


spool off
exit
eof1
exit
## eof chkvercnt