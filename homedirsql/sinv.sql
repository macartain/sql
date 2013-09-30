set lines 180
col object_name for a55
select owner, object_name, OBJECT_TYPE, status
from all_objects
where status='INVALID'
-- and OBJECT_TYPE != 'SYNONYM'
order by owner, OBJECT_TYPE, object_name
;
