set pages 180
col LOADER_ID for 999999 trunc
col EVENT_COUNT for 999,999
col LOG_START_TS for a15 trunc
col LOG_END_TS for a15 trunc
col LOG_COMMENTS for a45 wrap
col DAT_FILENAME for a15 trunc
col CTL_FILENAME for a40 trunc
col LOG_CAT for a7 trunc
col LOG_TYPE for a7 trunc
col PROGRAM_UNIT for a10 trunc
select LOG_START_TS, LOG_END_TS, CTL_FILENAME, DAT_FILENAME, EVENT_COUNT,LOG_COMMENTS
from roar.loader_log ll 
where LOG_START_TS>to_date('12-03-2010','dd-mm-yyyy')
order by ll.log_start_ts asc;
