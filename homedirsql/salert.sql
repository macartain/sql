col ORIGINATING_TIMESTAMP for a32
col message_text for a140 wrap
select ORIGINATING_TIMESTAMP, message_text from X$DBGALERTEXT
where lower(message_text) like '%&lower_search_txt%';

