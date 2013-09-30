set lines 200
col sql_text for a38 word
col module for a20 word
col executions for 999,999,999,999.99
col buffer_gets for 999,999,999,999.99
col disk_reads for 999,999,999,999.99
col rows_processed for 999,999,999,999.99

select * from (select module, sql_text, buffer_gets, executions, disk_reads, rows_processed
	from v$sql
	order by 3 desc)
where rownum < 11;
/
