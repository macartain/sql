col MEG_USED for 9999999.99
col MEG_FREE for 9999999.99
select tablespace_name, file_id, bytes_used/(1024*1024) MEG_USED, bytes_free/(1024*1024) MEG_FREE
from v$temp_space_header;

select TABLESPACE_NAME, TOTAL_EXTENTS, USED_EXTENTS, FREE_EXTENTS from v$sort_segment;

select * from V$TEMPSEG_USAGE;
