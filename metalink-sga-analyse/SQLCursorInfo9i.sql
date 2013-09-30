
REM  Filename:  SQLCursorInfo9i.sql
REM
REM  Review invalidated cursors information
REM
REM  Runs on 9.2.x

accept threshold  prompt 'Enter percentage of top nonshared code (Ex. .8)'

set termout off
set trimout on
set trimspool on

col sql_text for a65 word_wrapped
col "Findings" for a80 word_wrapped newline
col "Additional Findings" for a80 word_wrapped newline head ""
col address head "Address"

set pages 999

REM
REM  Investigate results of this code in the spooled file
REM  nonshared.out
REM
REM  The goal is often to focus on the "worst offenders".  This would be
REM  the percentage of verion_count at 70% or 80%
REM  However, you can change the percentage used in the code below
REM  at the beginning of script.   The lower the percentage the more data in
REM  the report


spool nonshared.out
select 'SQL Address'||sc.address address, sql_text, 
decode(UNBOUND_CURSOR, 'Y','Child Cursor Not Optimized'||chr(10),null)||decode(SQL_TYPE_MISMATCH,'Y',
'SQL Type Not Matching Child Cursor Information'||chr(10),null)||decode(OPTIMIZER_MISMATCH,'Y',
'Mismatch in Optimizer Mode'||chr(10),null)||decode(OUTLINE_MISMATCH,'Y','Mismatch in Outline Information'
||chr(10),null)||decode(STATS_ROW_MISMATCH,'Y','Mismatch in Row Statistics'||chr(10),null)||
decode(LITERAL_MISMATCH,'Y','Mismatch due to Non-Data Literal Values'||chr(10),null)||
decode(SEC_DEPTH_MISMATCH,'Y','Mismatch due to Security Level Differences'||chr(10),null)||
decode(EXPLAIN_PLAN_CURSOR, 'Y','Explain Plan Cursor Cannot be Shared'||chr(10),null)||
decode(BUFFERED_DML_MISMATCH, 'Y','Mismatch due to Buffered DML'||chr(10),null)||
decode(PDML_ENV_MISMATCH, 'Y','Mismatch due to Environment'||chr(10),null)||
decode(INST_DRTLD_MISMATCH, 'Y','Mismatch in Insert Direct Load'||chr(10),null)||
decode(SLAVE_QC_MISMATCH, 'Y','Mismatch in the Slave Query Coordinator'||chr(10),null)||
decode(TYPECHECK_MISMATCH, 'Y','Existing Child Cursor is not Fully Optimized'||chr(10),null)||
decode(AUTH_CHECK_MISMATCH, 'Y','Failed to Match Authentication/Translation Checks'||chr(10),null)||
decode(BIND_MISMATCH, 'Y','Mismatch in Bind Metadata'||chr(10),null)||
decode(DESCRIBE_MISMATCH, 'Y','Mismatch because Type Check Data is Missing'||chr(10),null)||
decode(LANGUAGE_MISMATCH, 'Y','Mismatch in Language Handle'||chr(10),null)||
decode(TRANSLATION_MISMATCH, 'Y','Failed Because Base Objects Do Not Match'||chr(10),null)||
decode(ROW_LEVEL_SEC_MISMATCH, 'Y','Mismatch due to Row Level Security'||chr(10),null)||
decode(INSUFF_PRIVS, 'Y','Insufficient Privs on Base Objects'||chr(10),null)||
decode(INSUFF_PRIVS_REM, 'Y','Insufficient Privs on Remote Objects'||chr(10),null) "Findings",
decode(REMOTE_TRANS_MISMATCH, 'Y','Mismatch due to Remote Objects'||chr(10),null)||
decode(LOGMINER_SESSION_MISMATCH, 'Y','Mismatch due to LogMiner Session Parameters'||chr(10),null)||
decode(INCOMP_LTRL_MISMATCH, 'Y','Bind errors due to Value Mismatch in Bind/Literal Values'||chr(10),null)||
decode(OVERLAP_TIME_MISMATCH, 'Y','Mismatch due to Session Parameter Setting for ERROR_ON_OVERLAP_TIME'||chr(10),null)||
decode(SQL_REDIRECT_MISMATCH, 'Y','Mismatch due to SQL Redirection'||chr(10),null)||
decode(MV_QUERY_GEN_MISMATCH, 'Y','Mismatch due to MV Query (Forced Hard Parse)'||chr(10),null)||
decode(USER_BIND_PEEK_MISMATCH, 'Y','Mismatch due to User Bind Peeking'||chr(10),null)||
decode(TYPCHK_DEP_MISMATCH, 'Y','Mismatch due to Typcheck Dependencies'||chr(10),null)||
decode(NO_TRIGGER_MISMATCH, 'Y','Mismatch due to Cursor and Child Having No Trigger'||chr(10),null)||
decode(FLASHBACK_CURSOR, 'Y','Non Shareable because of Flashback'||chr(10),null)
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
order by 1;

col nr format 999,999,999,999 head "No Reason Listed"

select count(*) NR 
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and UNBOUND_CURSOR='N' AND OPTIMIZER_MISMATCH='N' AND
OUTLINE_MISMATCH='N' AND STATS_ROW_MISMATCH='N' AND
LITERAL_MISMATCH='N' AND SEC_DEPTH_MISMATCH='N' AND
EXPLAIN_PLAN_CURSOR='N' AND BUFFERED_DML_MISMATCH='N' AND
PDML_ENV_MISMATCH='N' AND INST_DRTLD_MISMATCH='N' AND
SLAVE_QC_MISMATCH='N' AND TYPECHECK_MISMATCH='N' AND
AUTH_CHECK_MISMATCH='N' AND BIND_MISMATCH='N' AND
DESCRIBE_MISMATCH='N' AND LANGUAGE_MISMATCH='N' AND
TRANSLATION_MISMATCH='N' AND ROW_LEVEL_SEC_MISMATCH='N' AND
INSUFF_PRIVS='N' AND INSUFF_PRIVS_REM='N' AND
REMOTE_TRANS_MISMATCH='N' AND LOGMINER_SESSION_MISMATCH='N' AND
INCOMP_LTRL_MISMATCH='N' AND OVERLAP_TIME_MISMATCH='N' AND
SQL_REDIRECT_MISMATCH='N' AND MV_QUERY_GEN_MISMATCH='N' AND
USER_BIND_PEEK_MISMATCH='N' AND TYPCHK_DEP_MISMATCH='N' AND
NO_TRIGGER_MISMATCH='N' AND FLASHBACK_CURSOR='N';

col bk heading "Breakdown of Reasons for Non-Shared Code"
select count(*)||'  UNBOUND_CURSOR' BK from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and UNBOUND_CURSOR='Y'having count(*) > 0
union
select count(*)||'  OPTIMIZER_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and OPTIMIZER_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  UNBOUND_CURSOR' BK from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and UNBOUND_CURSOR='Y'
having count(*) > 0
union
select count(*)||'  OUTLINE_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and OUTLINE_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  STATS_ROW_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and STATS_ROW_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  LITERAL_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and LITERAL_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  SEC_DEPTH_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and SEC_DEPTH_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  EXPLAIN_PLAN_CURSOR' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and EXPLAIN_PLAN_CURSOR='Y'
having count(*) > 0
union
select count(*)||'  BUFFERED_DML_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and BUFFERED_DML_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  PDML_ENV_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and PDML_ENV_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  INST_DRTLD_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and INST_DRTLD_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  SLAVE_QC_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and SLAVE_QC_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  TYPECHECK_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and TYPECHECK_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  AUTH_CHECK_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and AUTH_CHECK_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  BIND_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and BIND_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  DESCRIBE_MISMATCH' BK
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and DESCRIBE_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  LANGUAGE_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and LANGUAGE_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  TRANSLATION_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and TRANSLATION_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  ROW_LEVEL_SEC_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and ROW_LEVEL_SEC_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  INSUFF_PRIVS' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and INSUFF_PRIVS='Y'
having count(*) > 0
union
select count(*)||'  INSUFF_PRIVS_REM' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and INSUFF_PRIVS_REM='Y'
having count(*) > 0
union
select count(*)||'  REMOTE_TRANS_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and REMOTE_TRANS_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  LOGMINER_SESSION_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and LOGMINER_SESSION_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  INCOMP_LTRL_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and INCOMP_LTRL_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  OVERLAP_TIME_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and OVERLAP_TIME_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  SQL_REDIRECT_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and SQL_REDIRECT_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  MV_QUERY_GEN_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and MV_QUERY_GEN_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  USER_BIND_PEEK_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and USER_BIND_PEEK_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  TYPCHK_DEP_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and TYPCHK_DEP_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  NO_TRIGGER_MISMATCH' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and NO_TRIGGER_MISMATCH='Y'
having count(*) > 0
union
select count(*)||'  FLASHBACK_CURSOR' BK  
from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.KGLHDPAR
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and FLASHBACK_CURSOR='Y'
having count(*) > 0
order by 1;

spool off
set termout on
set trimout off
set trimspool off
clear col
undef threshold

*/----------------------------------------------------------

Sample Output:

4F064F2C  SELECT MAX(ROWID) FROM MGMT_SYSTEM_ERROR_LOG ERRLOG WHERE
                      ERRLOG.MODULE_NAME = :B5 AND ERRLOG.LOG_LEVEL = :B4 AND
                      ERRLOG.OCCUR_DATE >= :B3 - 1/24 AND ERRLOG.ERROR_CODE = :B2 AND
                      ERRLOG.ERROR_MSG = SUBSTR(:B1 ,1.2048)

Mismatch due to Cursor and Child Having No Trigger

4F064F2C  SELECT MAX(ROWID) FROM MGMT_SYSTEM_ERROR_LOG ERRLOG WHERE
                     ERRLOG.MODULE_NAME = :B5 AND ERRLOG.LOG_LEVEL = :B4 AND
                     ERRLOG.OCCUR_DATE >= :B3 - 1/24 AND ERRLOG.ERROR_CODE = :B2 AND
                     ERRLOG.ERROR_MSG = SUBSTR(:B1 ,1.2048)
Mismatch in Row Statistics
Mismatch due to User Bind Peeking

*/