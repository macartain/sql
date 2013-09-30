col SCRIPTNAME for a25
col LASTMESSAGE for a65
select to_char(sysdate, 'YYYYMONDD-hh24:mi') tstamp from dual;
select * from TMP_LASTKEY;
select to_char(TIMESTAMP, 'YYYYMONDD-hh24:mi') tstamp, RUNNUMBER, SCRIPTNAME, STEPNAME, BEFOREAFTER, LASTMESSAGE from migrationprocess;
exit;
