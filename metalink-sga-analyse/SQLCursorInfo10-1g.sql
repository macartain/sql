REM  Filename:  SQLStats.sql
REM
REM  SQL Area Statistics
REM
REM   runs on 10g Release 1
REM  Review results in the spooled file
REM   nonshared.out

REM  Filename:  SQLCursorInfo10g.sql
REM
REM  This code works with 10g Release 1.   V$SQLSTATS does not exist prior to 10g.
REM   Use the "Versions HWM" number to tweak this query to fit your scenario
REM  
REM      and version_count....    can be changed in the where clause to 
REM      investigate different subsets of the data
REM   
REM  The goal is often to focus on the "worst offenders".  This would be
REM  the percentage of verion_count at 70% or 80%
REM  However, you can change the percentage used in the code below
REM  at the beginning of script.   The lower the percentage the more data in
REM  the report

accept threshold  prompt 'Enter percentage of top nonshared code (Ex. .8)  '

set lines 132
clear col
set pages 999
set termout off
set trimout on
set trimspool on
col "SQL Address" format a20 head ""
col sql_text for a65 word_wrapped head "SQL"
col "Findings" for a80 word_wrapped newline
col executions for 999,999,999 head "Executed"
col "Additional Findings" for a80 word_wrapped newline head ""


col max(invalidations) format 999,999,999,999 head "Max Invalidations"
col max(loaded_versions) format 999,999,999 head "Max Versions|Loaded"
col max(version_count) format 999,999,999,999 head "Versions HWM"
col max(sharable_mem) format 999,999,999,999 head "Largest Memory"

spool nonshared.out

select max(version_count), max(invalidations), max(loaded_versions),
max(sharable_mem)
from v$sqlarea;

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
where ss.address = sc.address
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
order by 1;

col NR format 999,999,999,999 head "No Reasons Listed"
select count(*) NR from v$sql_shared_cursor sc, v$sqlarea ss
where ss.address = sc.address
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and UNBOUND_CURSOR = 'N' and SQL_TYPE_MISMATCH = 'N' and
OPTIMIZER_MISMATCH = 'N' and OUTLINE_MISMATCH = 'N' and
STATS_ROW_MISMATCH = 'N' and LITERAL_MISMATCH = 'N' and
SEC_DEPTH_MISMATCH = 'N' and EXPLAIN_PLAN_CURSOR = 'N' and
BUFFERED_DML_MISMATCH = 'N' and PDML_ENV_MISMATCH = 'N' and
INST_DRTLD_MISMATCH = 'N' and SLAVE_QC_MISMATCH = 'N' and
TYPECHECK_MISMATCH = 'N' and AUTH_CHECK_MISMATCH = 'N' and
BIND_MISMATCH = 'N' and DESCRIBE_MISMATCH = 'N' and
LANGUAGE_MISMATCH = 'N' and TRANSLATION_MISMATCH = 'N' and
ROW_LEVEL_SEC_MISMATCH = 'N' and INSUFF_PRIVS = 'N' and
INSUFF_PRIVS_REM = 'N' and REMOTE_TRANS_MISMATCH = 'N' and
LOGMINER_SESSION_MISMATCH = 'N' and INCOMP_LTRL_MISMATCH = 'N' and
OVERLAP_TIME_MISMATCH = 'N' and SQL_REDIRECT_MISMATCH = 'N' and
MV_QUERY_GEN_MISMATCH = 'N' and USER_BIND_PEEK_MISMATCH = 'N' and
TYPCHK_DEP_MISMATCH = 'N' and NO_TRIGGER_MISMATCH = 'N' and
FLASHBACK_CURSOR = 'N'
/

col bk head "Breakdown of Reasons for Non-Shared Code"
select count(*)||'  UNBOUND_CURSOR' BK from v$sql_shared_cursor sc, v$sqlarea ss where UNBOUND_CURSOR='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  SQL_TYPE_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where SQL_TYPE_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  OPTIMIZER_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where OPTIMIZER_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  OUTLINE_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where OUTLINE_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  STATS_ROW_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where STATS_ROW_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  LITERAL_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where LITERAL_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  SEC_DEPTH_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where SEC_DEPTH_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  EXPLAIN_PLAN_CURSOR' from v$sql_shared_cursor sc, v$sqlarea ss where EXPLAIN_PLAN_CURSOR='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  BUFFERED_DML_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where BUFFERED_DML_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  PDML_ENV_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where PDML_ENV_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  INST_DRTLD_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where INST_DRTLD_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  SLAVE_QC_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where SLAVE_QC_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  TYPECHECK_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where TYPECHECK_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  AUTH_CHECK_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where AUTH_CHECK_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  BIND_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where BIND_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  DESCRIBE_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where DESCRIBE_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  LANGUAGE_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where LANGUAGE_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  TRANSLATION_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where TRANSLATION_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  ROW_LEVEL_SEC_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where ROW_LEVEL_SEC_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  INSUFF_PRIVS' from v$sql_shared_cursor sc, v$sqlarea ss where INSUFF_PRIVS='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  INSUFF_PRIVS_REM' from v$sql_shared_cursor sc, v$sqlarea ss where INSUFF_PRIVS_REM='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  REMOTE_TRANS_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where REMOTE_TRANS_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  LOGMINER_SESSION_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where LOGMINER_SESSION_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  INCOMP_LTRL_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where INCOMP_LTRL_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  OVERLAP_TIME_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where OVERLAP_TIME_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  SQL_REDIRECT_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where SQL_REDIRECT_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  MV_QUERY_GEN_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where MV_QUERY_GEN_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  USER_BIND_PEEK_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where USER_BIND_PEEK_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  TYPCHK_DEP_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where TYPCHK_DEP_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  NO_TRIGGER_MISMATCH' from v$sql_shared_cursor sc, v$sqlarea ss where NO_TRIGGER_MISMATCH='Y'
and ss.address=sc.address and version_count > (select (max(version_count)*&threshold) from v$sqlarea) 
having count(*) > 0
union
select count(*)||'  FLASHBACK_CURSOR' from v$sql_shared_cursor sc, v$sqlarea ss where FLASHBACK_CURSOR='Y'
having count(*) > 0
order by 1
/


spool off
set termout on
set trimout off
set trimspool off
set head on
clear col
undef threshold

/*----------------------------------------------------------

Find the output for this report in the spooled file nonshared.out

Sample Output:

SQL Address4A71A570/ SELECT status FROM sys.wri$_adv_tasks WHERE id = :1
4A5DAC88-2

Mismatch due to rolling invalidations

SQL Address4F064F2C/ SELECT MAX(ROWID) FROM MGMT_SYSTEM_ERROR_LOG ERRLOG WHERE
497A6B10-2           ERRLOG.MODULE_NAME = :B5 AND ERRLOG.LOG_LEVEL = :B4 AND
                     ERRLOG.OCCUR_DATE >= :B3 - 1/24 AND ERRLOG.ERROR_CODE = :B2 AND
                     ERRLOG.ERROR_MSG = SUBSTR(:B1 ,1.2048)

Mismatch due to rolling invalidations

SQL Address4F064F2C/ SELECT MAX(ROWID) FROM MGMT_SYSTEM_ERROR_LOG ERRLOG WHERE
4A759C0C-3           ERRLOG.MODULE_NAME = :B5 AND ERRLOG.LOG_LEVEL = :B4 AND
                     ERRLOG.OCCUR_DATE >= :B3 - 1/24 AND ERRLOG.ERROR_CODE = :B2 AND
                     ERRLOG.ERROR_MSG = SUBSTR(:B1 ,1.2048)
Failed to Match Authentication/Translation Checks
Mismatch in Language Handle
Mismatch due to rolling invalidations

*/
