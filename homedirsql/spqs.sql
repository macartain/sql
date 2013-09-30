col program for a28
col iid for 99 trunc
col req for 9999
col deg for 9999
col qcsid for 9999
col sid for 9999
col srvgrp for 9999
col srvset for 9999
col PHYSICAL_READS for 999,999,999
col BLOCK_GETS for 999,999,999
col CONSISTENT_GETS for 999,999,999
col program for a30 trunc
col osuser for a12 trunc
col username for a22 trunc
break on qcsid on OSUSER on USERNAME on iid skip 1
SELECT   vs.inst_id iid, vs.OSUSER, vs.USERNAME, vs.PROGRAM, vs.sql_id, vsi.PHYSICAL_READS, vsi.BLOCK_GETS , vsi.CONSISTENT_GETS, qcsid, ps.sid,
NVL(server_group,0) srvgrp, server_set srvset, degree deg, req_degree req
FROM     SYS.gV_$PX_SESSION ps, gv$session vs, gv$sess_io vsi
where vs.SID=ps.SID
and vsi.SID=vs.SID
and vsi.inst_id=vs.inst_id
and vsi.inst_id=ps.inst_id
ORDER BY qcsid,
        NVL(server_group,0),
        nvl(server_set,0), program;
