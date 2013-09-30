col trans_id for a15
col program for a28 wrap
select a.sid, a.program, b.START_TIME, b.USED_UBLK, b.phy_io, b.log_io, b.XIDUSN||'.'||b.XIDSLOT||'.'||b.XIDSQN trans_id
from v$session a right outer join v$transaction b
on a.taddr=b.ADDR 
order by b.start_time, a.program;
