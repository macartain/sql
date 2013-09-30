set pages 80
set lines 120
col FILE_NAME for a45

select file_id, fecrc_tim creation_date, file_name, tablespace_name
from x$kccfe int, dba_data_files dba
where dba.file_id = int.indx + 1 order by file_id;
