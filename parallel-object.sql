-- --------------------------------------------------------------------
-- Object DOP
-- --------------------------------------------------------------------
select * from  (
SELECT OWNER, 'INDEX' OBJECT_TYPE, INDEX_NAME OBJ_NAME, TRIM(DEGREE)
FROM DBA_INDEXES
WHERE TRIM(DEGREE) > TO_CHAR(1)
	-- and owner='GENEVA_ADMIN'
UNION ALL
SELECT OWNER, 'TABLE' OBJECT_TYPE, TABLE_NAME OBJ_NAME, TRIM(DEGREE)
FROM DBA_TABLES
WHERE TRIM(DEGREE) > TO_CHAR(1)
	-- and owner='GENEVA_ADMIN'
)
order by 1,2,3
/

-- batch up some resets
SELECT 'alter index '||OWNER||'.'||INDEX_NAME||' noparallel;'
FROM DBA_INDEXES
WHERE TRIM(DEGREE) > TO_CHAR(1)
and owner='GENEVA_ADMIN';

-- --------------------------------------------------------------------
-- Check PQ slave status
-- --------------------------------------------------------------------

col username for a12
col "QC SID" for A6
col SID for A6
col "QC/Slave" for A10
col "Requested DOP" for 9999
col "Actual DOP" for 9999
col "slave set" for  A10
set pages 100

select
decode(px.qcinst_id,NULL,username,
' - '||lower(substr(s.program,length(s.program)-4,4) ) ) "Username",
decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" ,
to_char( px.server_set) "Slave Set",
to_char(s.sid) "SID",
decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) "QC SID",
px.req_degree "Requested DOP",
px.degree "Actual DOP"
from
v$px_session px,
v$session s
where
px.sid=s.sid (+)
and
px.serial#=s.serial#
order by 5 , 1 desc;

-- --------------------------------------------------------------------
-- J Lewis - but doesn't report same as above - only works for same session
-- --------------------------------------------------------------------

SELECT dfo_number, tq_id, server_type, process, num_rows, bytes
FROM v$pq_tqstat
ORDER BY dfo_number DESC, tq_id, server_type DESC , process;

-- --------------------------------------------------------------------
-- PX session waits
-- --------------------------------------------------------------------
column child_wait  format a30
column parent_wait format 30
column osuser    format a10
column server_name format a4  heading 'Name'
column x_status    format a10 heading 'Status'
column schemaname  format a14 heading 'Schema'
column x_sid format 9990 heading 'Sid'
column x_pid format 9990 heading 'Pid'
column p_sid format 9990 heading 'Parent'

break on p_sid skip 1

select x.server_name
        , x.status as x_status
        , x.pid as x_pid
        , x.sid as x_sid
        , w2.sid as p_sid
        , v.osuser
        , v.schemaname
        , w1.event as child_wait
        , w2.event as parent_wait
from  v$px_process x
       , v$lock l
       , v$session v
       , v$session_wait w1
       , v$session_wait w2
where x.sid <> l.sid(+)
and   to_number (substr(x.server_name,2)) = l.id2(+)
and   x.sid = w1.sid(+)
and   l.sid = w2.sid(+)
and   x.sid = v.sid(+)
and   nvl(l.type,'PS') = 'PS'
order by 1,2;

-- --------------------------------------------------------------------
-- I/O per slave
-- --------------------------------------------------------------------

col program for a28
col req for 9999
col deg for 9999
col qcsid for 9999
col sid for 9999
col srvgrp for 9999
col srvset for 9999
col PHYSICAL_READS for 999,999,999
col BLOCK_GETS for 999,999,999
col CONSISTENT_GETS for 999,999,999
SELECT   vs.OSUSER, vs.PROGRAM, vs.sql_id, vsi.PHYSICAL_READS, vsi.BLOCK_GETS , vsi.CONSISTENT_GETS, qcsid, ps.sid,
NVL(server_group,0) srvgrp, server_set srvset, degree deg, req_degree req
FROM     SYS.V_$PX_SESSION ps, v$session vs, v$sess_io vsi
where vs.SID=ps.SID
and vsi.SID=vs.SID
ORDER BY qcsid,
         NVL(server_group,0),
         server_set;

-- --------------------------------------------------------------------
-- Tables on which PDML cannot be used
-- --------------------------------------------------------------------
SELECT u.name, o.name 
FROM obj$ o, tab$ t, user$ u
WHERE o.obj# = t.obj# AND o.owner# = u.user#
AND bitand(t.property,536870912) != 536870912
order by u.name, o.name;

-- --------------------------------------------------------------------
-- Common tasks
-- --------------------------------------------------------------------

-- set session-level DOP
alter session force parallel DML parallel 8;
alter session force parallel query parallel 8;

-- parallelise update - example from benjamin cantat(?)
update /*+ PARALLEL(bs, 24) */ BILLSUMMARY bs -- Set the parallelism to whatever you want - I used 24 as you have 24 cores.
set    INVOICE_NET_MNY = nvl((select SUM(RATED_EVENT_MNY)
                              from   ACCOUNTRATINGSUMMARY
                              where  ACCOUNT_NUM = bs.account_num
                              and    EVENT_SEQ = bs.event_seq
                            ), 0)
where  bs.bill_status between 12 and 20;

-- change degree of an object

-- multiple table parallel hint:
select customer_ref, count(account_num) 
from account
where customer_ref in (
  SELECT /*+ parallel(cpibl) parallel(cpidu) */ unique cpibl.customer_ref 
  FROM CUSTPRODINVBONUSLOG cpibl
  LEFT
  JOIN custprodinvoicediscusage cpidu
  ON cpidu.customer_ref = cpibl.customer_ref
  AND cpidu.product_seq = cpibl.product_seq
  AND cpidu.event_discount_id = cpibl.event_discount_id
  AND cpidu.period_num = cpibl.period_num
  AND cpidu.event_seq = cpibl.event_seq
  WHERE cpidu.customer_ref is null)
group by customer_ref
order by 2 desc;

-- force index PX
select /*+ parallel_index(bd) index_ffs(bd,billdetails_pk) */ count(*) 
from billdetails bd
    where bd.account_num not in (select /*+ parallel_index(a) index_ffs(a,account_pk) */ account_num from account a);    

-- parallel CTAS
create table CVG_BAK_CUST_7171971 parallel (degree 8)
tablespace users
as select * from CUSTOMER;

-- Session PX stats
SELECT * FROM v$pq_sesstat;
-- Server numbers 
SELECT * FROM v$pq_sysstat;
-- User stats related to PX
select name,value
from v$mystat s, v$statname n
where lower(n.name) like '%arallel%'
and s.statistic# = n.statistic#;
