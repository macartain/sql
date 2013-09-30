REM  This code works with 11g.
REM  
REM  The goal is often to focus on the "worst offenders".  This would be
REM  the percentage of verion_count at 70% or 80%
REM  However, you can change the percentage used in the code below
REM  at the beginning of script.   The lower the percentage the more data in
REM  the report

accept threshold  prompt 'Enter percentage of top nonshared code (Ex. .8)'

set lines 120
clear col
set pages 999
set termout off
set trimout on
set trimspool on

col "SQL Address" format a30 
col sql_text for a65 word_wrapped
col "Findings" for a80 word_wrapped newline
col "Additional Findings" for a80 word_wrapped newline head ""

spool nonshared.out

select 'SQL Address'||address||'/'||child_address||'-'||to_char(CHILD_NUMBER) "SQL Address", sql_text,
decode(UNBOUND_CURSOR, 'Y','Child Cursor Not Optimized'||chr(10),null)||
decode(SQL_TYPE_MISMATCH,'Y','SQL Type Not Matching Child Cursor Information'||chr(10),null)||
decode(OPTIMIZER_MISMATCH,'Y','Mismatch in Optimizer Mode'||chr(10),null)||
decode(OUTLINE_MISMATCH,'Y','Mismatch in Outline Information'||chr(10),null)||
decode(STATS_ROW_MISMATCH,'Y','Mismatch in Row Statistics'||chr(10),null)||
decode(LITERAL_MISMATCH,'Y','Mismatch due to Non-Data Literal Values'||chr(10),null)||
decode(FORCE_HARD_PARSE,'Y','Mismatch due to Forced Hard Parse'||chr(10),null)||
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
decode(MV_QUERY_GEN_MISMATCH, 'Y','Mismatch due to MV Query (Forced Hard Parse)'||chr(10),null)||
decode(USER_BIND_PEEK_MISMATCH, 'Y','Mismatch due to User Bind Peeking'||chr(10),null)||
decode(TYPCHK_DEP_MISMATCH, 'Y','Mismatch due to Typcheck Dependencies'||chr(10),null)||
decode(NO_TRIGGER_MISMATCH, 'Y','Mismatch due to Cursor and Child Having No Trigger'||chr(10),null)||
decode(FLASHBACK_CURSOR, 'Y','Non Shareable because of Flashback'||chr(10),null)||
decode(ANYDATA_TRANSFORMATION, 'Y','Mismatch due to Opaque Type Transformation'||chr(10),null)||
decode(INCOMPLETE_CURSOR, 'Y','Incomplete Cursor'||chr(10),null)||
decode(TOP_LEVEL_RPI_CURSOR, 'Y','Top Level RPI Cursors'||chr(10),null)||
decode(DIFFERENT_LONG_LENGTH, 'Y','Differences in Long Value Lengths'||chr(10),null)||
decode(LOGICAL_STANDBY_APPLY, 'Y','Mismatch in Logical Standby Apply context'||chr(10),null)||
decode(DIFF_CALL_DURN, 'Y','Mismatch due to Slave SQL Cursors'||chr(10),null)||
decode(BIND_UACS_DIFF, 'Y','One Cursor has Bind UACS and One Does Not'||chr(10),null)||
decode(PLSQL_CMP_SWITCHS_DIFF, 'Y','PLSQL Switches Different at Compile Time'||chr(10),null)||
decode(CURSOR_PARTS_MISMATCH, 'Y','Mismatch Because of Cursor Compiled with Subexecutions'||chr(10),null)||
decode(STB_OBJECT_MISMATCH, 'Y','STB Created After Cursor Was Compiled'||chr(10),null)||
decode(PQ_SLAVE_MISMATCH, 'Y','Top-level PQ Slave forced Non-Shared Cursor'||chr(10),null)||
decode(TOP_LEVEL_DDL_MISMATCH, 'Y','Top Level DDL Not Shared'||chr(10),null)||
decode(MULTI_PX_MISMATCH, 'Y','Cursor has Multi parallelizers'||chr(10),null)||
decode(BIND_PEEKED_PQ_MISMATCH, 'Y','Mismatch due to Bind Peeking'||chr(10),null)||
decode(MV_REWRITE_MISMATCH, 'Y','Mismatch due to MV Rewrite'||chr(10),null)||
decode(ROLL_INVALID_MISMATCH, 'Y','Mismatch due to rolling invalidations'||chr(10),null)||
decode(OPTIMIZER_MODE_MISMATCH, 'Y','Mismatch due to parameter Optimizer_Mode'||chr(10),null)||
decode(PX_MISMATCH, 'Y','Mismatch due to Parameter Settings Related to Parallelism'||chr(10),null)||
decode(MV_STALEOBJ_MISMATCH, 'Y','Mismatch due to MV Stale Object  -  ',null)||
decode(FLASHBACK_TABLE_MISMATCH, 'Y','Mismatch due to Flashback Table'||chr(10),null)||
decode(LITREP_COMP_MISMATCH, 'Y','Mismatch due to Literal Replacement'||chr(10),null)||
decode(CROSSEDITION_TRIGGER_MISMATCH, 'Y','Mismatch due to Crossedition Trigger'||chr(10),null)||
decode(EDITION_MISMATCH, 'Y','Edition Mismatch'||chr(10),null)||
decode(FORCE_HARD_PARSE, 'Y','Hard Parse Forced'||chr(10),null) "Additional Findings"
from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id
and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
order by 1;

col NR format 999,999,999,999,999 heading "No Reasons Listed"
select count(*) NR
from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id
and version_count> (select (max(version_count)*&threshold) from v$sqlarea) and
UNBOUND_CURSOR='N' and SQL_TYPE_MISMATCH='N' and
OPTIMIZER_MISMATCH='N' and OUTLINE_MISMATCH='N' and
STATS_ROW_MISMATCH='N' and LITERAL_MISMATCH='N' and
FORCE_HARD_PARSE='N' and EXPLAIN_PLAN_CURSOR='N' and
BUFFERED_DML_MISMATCH='N' and PDML_ENV_MISMATCH='N' and
INST_DRTLD_MISMATCH='N' and SLAVE_QC_MISMATCH='N' and
TYPECHECK_MISMATCH='N' and AUTH_CHECK_MISMATCH='N' and
BIND_MISMATCH='N' and DESCRIBE_MISMATCH='N' and
LANGUAGE_MISMATCH='N' and TRANSLATION_MISMATCH='N' and
ROW_LEVEL_SEC_MISMATCH='N' and INSUFF_PRIVS='N' and
INSUFF_PRIVS_REM='N' and REMOTE_TRANS_MISMATCH='N' and
LOGMINER_SESSION_MISMATCH='N' and INCOMP_LTRL_MISMATCH='N' and
OVERLAP_TIME_MISMATCH='N' and MV_QUERY_GEN_MISMATCH='N' and
USER_BIND_PEEK_MISMATCH='N' and TYPCHK_DEP_MISMATCH='N' and
NO_TRIGGER_MISMATCH='N' and FLASHBACK_CURSOR='N' and
ANYDATA_TRANSFORMATION='N' and INCOMPLETE_CURSOR='N' and
TOP_LEVEL_RPI_CURSOR='N' and DIFFERENT_LONG_LENGTH='N' and
LOGICAL_STANDBY_APPLY='N' and DIFF_CALL_DURN='N' and
BIND_UACS_DIFF='N' and PLSQL_CMP_SWITCHS_DIFF='N' and
CURSOR_PARTS_MISMATCH='N' and STB_OBJECT_MISMATCH='N' and
PQ_SLAVE_MISMATCH='N' and TOP_LEVEL_DDL_MISMATCH='N' and
MULTI_PX_MISMATCH='N' and BIND_PEEKED_PQ_MISMATCH='N' and
MV_REWRITE_MISMATCH='N' and ROLL_INVALID_MISMATCH='N' and
OPTIMIZER_MODE_MISMATCH='N' and PX_MISMATCH='N' and
MV_STALEOBJ_MISMATCH='N' and FLASHBACK_TABLE_MISMATCH='N' and
LITREP_COMP_MISMATCH='N' and CROSSEDITION_TRIGGER_MISMATCH='N' 
and EDITION_MISMATCH='N' and FORCE_HARD_PARSE='N';


col bk heading "Breakdown of Reasons for Non-Shared Code"
select count(*)||' UNBOUND_CURSOR' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and UNBOUND_CURSOR='Y'
having count(*) > 0
union
select count(*)||' SQL_TYPE_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and SQL_TYPE_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' OPTIMIZER_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and OPTIMIZER_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' OUTLINE_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and OUTLINE_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' STATS_ROW_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and STATS_ROW_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' LITERAL_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and LITERAL_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' FORCE_HARD_PARSE' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and FORCE_HARD_PARSE='Y'
having count(*) > 0
union 
select count(*)||' EXPLAIN_PLAN_CURSOR' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and EXPLAIN_PLAN_CURSOR='Y'
having count(*) > 0
union 
select count(*)||' BUFFERED_DML_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and BUFFERED_DML_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' PDML_ENV_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and PDML_ENV_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' INST_DRTLD_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and INST_DRTLD_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' SLAVE_QC_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and SLAVE_QC_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' TYPECHECK_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and TYPECHECK_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' AUTH_CHECK_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and AUTH_CHECK_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' BIND_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and BIND_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' DESCRIBE_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and DESCRIBE_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' LANGUAGE_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and LANGUAGE_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' TRANSLATION_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and TRANSLATION_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' ROW_LEVEL_SEC_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and ROW_LEVEL_SEC_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' INSUFF_PRIVS' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and INSUFF_PRIVS='Y'
having count(*) > 0
union 
select count(*)||' INSUFF_PRIVS_REM' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and INSUFF_PRIVS_REM='Y'
having count(*) > 0
union 
select count(*)||' REMOTE_TRANS_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and REMOTE_TRANS_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' LOGMINER_SESSION_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and LOGMINER_SESSION_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' INCOMP_LTRL_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and INCOMP_LTRL_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' OVERLAP_TIME_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and OVERLAP_TIME_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' MV_QUERY_GEN_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and MV_QUERY_GEN_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' USER_BIND_PEEK_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and USER_BIND_PEEK_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' TYPCHK_DEP_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and TYPCHK_DEP_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' NO_TRIGGER_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and NO_TRIGGER_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' FLASHBACK_CURSOR' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and FLASHBACK_CURSOR='Y'
having count(*) > 0
union 
select count(*)||' ANYDATA_TRANSFORMATION' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and ANYDATA_TRANSFORMATION='Y'
having count(*) > 0
union 
select count(*)||' INCOMPLETE_CURSOR' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and INCOMPLETE_CURSOR='Y'
having count(*) > 0
union 
select count(*)||' TOP_LEVEL_RPI_CURSOR' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and TOP_LEVEL_RPI_CURSOR='Y'
having count(*) > 0
union 
select count(*)||' DIFFERENT_LONG_LENGTH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and DIFFERENT_LONG_LENGTH='Y'
having count(*) > 0
union 
select count(*)||' LOGICAL_STANDBY_APPLY' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and LOGICAL_STANDBY_APPLY='Y'
having count(*) > 0
union 
select count(*)||' DIFF_CALL_DURN' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and DIFF_CALL_DURN='Y'
having count(*) > 0
union 
select count(*)||' BIND_UACS_DIFF' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and BIND_UACS_DIFF='Y'
having count(*) > 0
union 
select count(*)||' PLSQL_CMP_SWITCHS_DIFF' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and PLSQL_CMP_SWITCHS_DIFF='Y'
having count(*) > 0
union 
select count(*)||' CURSOR_PARTS_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and CURSOR_PARTS_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' STB_OBJECT_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and STB_OBJECT_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' PQ_SLAVE_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and PQ_SLAVE_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' TOP_LEVEL_DDL_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and TOP_LEVEL_DDL_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' MULTI_PX_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and MULTI_PX_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' BIND_PEEKED_PQ_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and BIND_PEEKED_PQ_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' MV_REWRITE_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and MV_REWRITE_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' ROLL_INVALID_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and ROLL_INVALID_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' OPTIMIZER_MODE_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and OPTIMIZER_MODE_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' PX_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and PX_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' MV_STALEOBJ_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and MV_STALEOBJ_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' FLASHBACK_TABLE_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and FLASHBACK_TABLE_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' LITREP_COMP_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and LITREP_COMP_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' CROSSEDITION_TRIGGER_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and CROSSEDITION_TRIGGER_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' EDITION_MISMATCH' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and EDITION_MISMATCH='Y'
having count(*) > 0
union 
select count(*)||' FORCE_HARD_PARSE' BK from v$sql_shared_cursor sc, v$sqlstats ss
where sc.sql_id  = ss.sql_id and version_count> (select (max(version_count)*&threshold) from v$sqlarea)
and FORCE_HARD_PARSE='Y'
having count(*) > 0
order by 1;

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