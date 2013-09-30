
REM 
REM  Review information about why code pieces are not shared
REM  This looks at the top 20% of problem code pieces
REM  You can take out the part of the where clause about 
REM  version_count to investigate all code listed as not shared
REM  

REM   
REM  The goal is often to focus on the "worst offenders".  This would be
REM  the percentage of verion_count at 70% or 80%
REM  However, you can change the percentage used in the code below
REM  at the beginning of script.   The lower the percentage the more data in
REM  the report

accept threshold  prompt 'Enter percentage of top nonshared code (Ex. .8)  '

set serveroutput on
SET VERIFY OFF
spool SPInfo.out
DECLARE
   i number; j number; k number;
   blankline varchar2(70);
   SQL_TEXT varchar2(1000);
   SQL_ID varchar2(1);
   UNBOUND_CURSOR varchar2(1);
   SQL_TYPE_MISMATCH varchar2(1);
   OPTIMIZER_MISMATCH varchar2(1);
   OUTLINE_MISMATCH varchar2(1);
   STATS_ROW_MISMATCH varchar2(1);
   LITERAL_MISMATCH varchar2(1);
   FORCE_HARD_PARSE varchar2(1);
   EXPLAIN_PLAN_CURSOR varchar2(1);
   BUFFERED_DML_MISMATCH varchar2(1);
   PDML_ENV_MISMATCH varchar2(1);
   INST_DRTLD_MISMATCH varchar2(1);
   SLAVE_QC_MISMATCH varchar2(1);
   TYPECHECK_MISMATCH varchar2(1);
   AUTH_CHECK_MISMATCH varchar2(1);
   BIND_MISMATCH varchar2(1);
   DESCRIBE_MISMATCH varchar2(1);
   LANGUAGE_MISMATCH varchar2(1);
   TRANSLATION_MISMATCH varchar2(1);
   ROW_LEVEL_SEC_MISMATCH varchar2(1);
   INSUFF_PRIVS varchar2(1);
   INSUFF_PRIVS_REM varchar2(1);
   REMOTE_TRANS_MISMATCH varchar2(1);
   LOGMINER_SESSION_MISMATCH varchar2(1);
   INCOMP_LTRL_MISMATCH varchar2(1);
   OVERLAP_TIME_MISMATCH varchar2(1);
   EDITION_MISMATCH varchar2(1);
   MV_QUERY_GEN_MISMATCH varchar2(1);
   USER_BIND_PEEK_MISMATCH varchar2(1);
   TYPCHK_DEP_MISMATCH varchar2(1);
   NO_TRIGGER_MISMATCH varchar2(1);
   FLASHBACK_CURSOR varchar2(1);
   ANYDATA_TRANSFORMATION varchar2(1);
   INCOMPLETE_CURSOR varchar2(1);
   TOP_LEVEL_RPI_CURSOR varchar2(1);
   DIFFERENT_LONG_LENGTH varchar2(1);
   LOGICAL_STANDBY_APPLY varchar2(1);
   DIFF_CALL_DURN varchar2(1);
   BIND_UACS_DIFF varchar2(1);
   PLSQL_CMP_SWITCHS_DIFF varchar2(1);
   CURSOR_PARTS_MISMATCH varchar2(1);
   STB_OBJECT_MISMATCH varchar2(1);
   CROSSEDITION_TRIGGER_MISMATCH varchar2(1);
   PQ_SLAVE_MISMATCH varchar2(1);
   TOP_LEVEL_DDL_MISMATCH varchar2(1);
   MULTI_PX_MISMATCH varchar2(1);
   BIND_PEEKED_PQ_MISMATCH varchar2(1);
   MV_REWRITE_MISMATCH varchar2(1);
   ROLL_INVALID_MISMATCH varchar2(1);
   OPTIMIZER_MODE_MISMATCH varchar2(1);
   PX_MISMATCH varchar2(1);
   MV_STALEOBJ_MISMATCH varchar2(1);
   FLASHBACK_TABLE_MISMATCH varchar2(1);
   LITREP_COMP_MISMATCH varchar2(1);
   PLSQL_DEBUG varchar2(1);
   LOAD_OPTIMIZER_STATS varchar2(1);
   ACL_MISMATCH varchar2(1);
   FLASHBACK_ARCHIVE_MISMATCH varchar2(1);
   LOCK_USER_SCHEMA_FAILED varchar2(1);
   REMOTE_MAPPING_MISMATCH varchar2(1);
   LOAD_RUNTIME_HEAP_FAILED varchar2(1);
   UC number; STM number; OPM number; 
   OUM number; SRM1 number; LM1 number;
   SDM number; EPC number; BDM number; 
   PEM number; IDM number; SQM number; 
   TM1 number; ACM number; BM number; DM number; 
   LM2 number; TM2 number; RLSM number; FHP number;
   LSM number; ILM number; OTM number; EM number;
   SRM2 number; MQGM number; UBPM number; 
   TDM number; NTM number; FC number; CTM number;
   AT1 number; IC number; TLRC number; 
   DLL number; LSA number; DCD number; 
   BUD number; PCSD number; CPM number; 
   SOM number; RSM number; PSM number; PD number; 
   TLDM number; MPM number; IP number;
   BPPM number; MRM number; RIM number; 
   OMM number; PM number; MSM number; RIR number;
   FTM number; LCM number; IPR number; RTM number;
   LOS number; AM1 number; FAM number; LUSF number;
   RMM number; LRHF number;

   CURSOR code is select substr(sql_text,1,500),
      UNBOUND_CURSOR, SQL_TYPE_MISMATCH, OPTIMIZER_MISMATCH, 
      OUTLINE_MISMATCH, STATS_ROW_MISMATCH, LITERAL_MISMATCH,
      FORCE_HARD_PARSE, EXPLAIN_PLAN_CURSOR, BUFFERED_DML_MISMATCH,
      PDML_ENV_MISMATCH, INST_DRTLD_MISMATCH, SLAVE_QC_MISMATCH,
      TYPECHECK_MISMATCH, AUTH_CHECK_MISMATCH, BIND_MISMATCH,
      DESCRIBE_MISMATCH, LANGUAGE_MISMATCH, TRANSLATION_MISMATCH, 
      ROW_LEVEL_SEC_MISMATCH, INSUFF_PRIVS,  INSUFF_PRIVS_REM,
      REMOTE_TRANS_MISMATCH, LOGMINER_SESSION_MISMATCH, INCOMP_LTRL_MISMATCH,
      OVERLAP_TIME_MISMATCH, EDITION_MISMATCH, MV_QUERY_GEN_MISMATCH,
      USER_BIND_PEEK_MISMATCH,TYPCHK_DEP_MISMATCH,NO_TRIGGER_MISMATCH,
      FLASHBACK_CURSOR,ANYDATA_TRANSFORMATION,INCOMPLETE_CURSOR,
      TOP_LEVEL_RPI_CURSOR,DIFFERENT_LONG_LENGTH,LOGICAL_STANDBY_APPLY,
      DIFF_CALL_DURN,BIND_UACS_DIFF,PLSQL_CMP_SWITCHS_DIFF,
      CURSOR_PARTS_MISMATCH,STB_OBJECT_MISMATCH,CROSSEDITION_TRIGGER_MISMATCH,
      PQ_SLAVE_MISMATCH,TOP_LEVEL_DDL_MISMATCH,MULTI_PX_MISMATCH,
      BIND_PEEKED_PQ_MISMATCH,MV_REWRITE_MISMATCH,ROLL_INVALID_MISMATCH,
      OPTIMIZER_MODE_MISMATCH,PX_MISMATCH,MV_STALEOBJ_MISMATCH,
      FLASHBACK_TABLE_MISMATCH,LITREP_COMP_MISMATCH,PLSQL_DEBUG,
      LOAD_OPTIMIZER_STATS,ACL_MISMATCH,FLASHBACK_ARCHIVE_MISMATCH,
      LOCK_USER_SCHEMA_FAILED,REMOTE_MAPPING_MISMATCH,LOAD_RUNTIME_HEAP_FAILED
      from v$sql_shared_cursor sc, v$sqlstats ss
      where sc.sql_id  = ss.sql_id
      and version_count >= (select (max(version_count)*&threshold) from v$sqlarea)
      order by 1;

begin
     i:=0; k:=0;
     blankline:=chr(13);
     UC:=0; STM:=0; OPM:=0; 
     OUM:=0; SRM1:=0; LM1:=0;
     SDM:=0; EPC:=0; BDM:=0; 
     PEM:=0; IDM:=0; SQM:=0; 
     TM1:=0; ACM:=0; BM:=0; DM:=0; 
     LM2:=0; TM2:=0; RLSM:=0; FHP:=0;
     LSM:=0; ILM:=0; OTM:=0; EM:=0;
     SRM2:=0; MQGM:=0; UBPM:=0; 
     TDM:=0; NTM:=0; FC:=0; CTM:=0;
     AT1:=0; IC:=0; TLRC:=0; 
     DLL:=0; LSA:=0; DCD:=0; 
     BUD:=0; PCSD:=0; CPM:=0; 
     SOM:=0; RSM:=0; PSM:=0; PD:=0; 
     TLDM:=0; MPM:=0; IP:=0;
     BPPM:=0; MRM:=0; RIM:=0; 
     OMM:=0; PM:=0; MSM:=0; RIR:=0;
     FTM:=0; LCM:=0; IPR:=0; RTM:=0;
     LOS:=0; AM1:=0; FAM:=0; LUSF:=0;
     RMM:=0; LRHF:=0;

     open code;
     loop
        fetch code into 
        sql_text, UNBOUND_CURSOR, SQL_TYPE_MISMATCH, OPTIMIZER_MISMATCH, 
        OUTLINE_MISMATCH, STATS_ROW_MISMATCH, LITERAL_MISMATCH,
        FORCE_HARD_PARSE, EXPLAIN_PLAN_CURSOR, BUFFERED_DML_MISMATCH,
        PDML_ENV_MISMATCH, INST_DRTLD_MISMATCH, SLAVE_QC_MISMATCH,
        TYPECHECK_MISMATCH, AUTH_CHECK_MISMATCH, BIND_MISMATCH,
        DESCRIBE_MISMATCH, LANGUAGE_MISMATCH, TRANSLATION_MISMATCH, 
        ROW_LEVEL_SEC_MISMATCH, INSUFF_PRIVS,  INSUFF_PRIVS_REM,
        REMOTE_TRANS_MISMATCH, LOGMINER_SESSION_MISMATCH, INCOMP_LTRL_MISMATCH,
        OVERLAP_TIME_MISMATCH, EDITION_MISMATCH, MV_QUERY_GEN_MISMATCH,
        USER_BIND_PEEK_MISMATCH,TYPCHK_DEP_MISMATCH,NO_TRIGGER_MISMATCH,
        FLASHBACK_CURSOR,ANYDATA_TRANSFORMATION,INCOMPLETE_CURSOR,
        TOP_LEVEL_RPI_CURSOR,DIFFERENT_LONG_LENGTH,LOGICAL_STANDBY_APPLY,
        DIFF_CALL_DURN,BIND_UACS_DIFF,PLSQL_CMP_SWITCHS_DIFF,
        CURSOR_PARTS_MISMATCH,STB_OBJECT_MISMATCH,CROSSEDITION_TRIGGER_MISMATCH,
        PQ_SLAVE_MISMATCH,TOP_LEVEL_DDL_MISMATCH,MULTI_PX_MISMATCH,
        BIND_PEEKED_PQ_MISMATCH,MV_REWRITE_MISMATCH,ROLL_INVALID_MISMATCH,
        OPTIMIZER_MODE_MISMATCH,PX_MISMATCH,MV_STALEOBJ_MISMATCH,
        FLASHBACK_TABLE_MISMATCH,LITREP_COMP_MISMATCH,PLSQL_DEBUG,
        LOAD_OPTIMIZER_STATS,ACL_MISMATCH,FLASHBACK_ARCHIVE_MISMATCH,
        LOCK_USER_SCHEMA_FAILED,REMOTE_MAPPING_MISMATCH,LOAD_RUNTIME_HEAP_FAILED;
        exit when code%NOTFOUND;
            i:=i+1; j:=0;
            dbms_output.put_line(blankline);
            dbms_output.put_line(sql_text);
            dbms_output.put_line('---------- Not Shared Because of ---------------');
            IF 
               UNBOUND_CURSOR='Y' 
            THEN   
               dbms_output.put_line('Child Cursor Not Optimized');
               j:=j+1;
               UC:=UC+1;
            END IF;
            IF 
               SQL_TYPE_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('SQL Type Not Matching Child Cursor Information');
               j:=j+1;
               STM:=STM+1;
           END IF;
            IF 
               OPTIMIZER_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch in Optimizer Mode');
               j:=j+1;
               OPM:=OPM+1;
           END IF;
            IF 
               OUTLINE_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch in Outline Information');
               j:=j+1;
               OUM:=OUM+1;
            END IF;
            IF 
               STATS_ROW_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch in Row Statistics');
               j:=j+1;
               SRM1:=SRM1+1;
            END IF;
            IF 
               LITERAL_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Non-Data Literal Values');
               j:=j+1;
               LM1:=LM1+1;
            END IF;
            IF
               FORCE_HARD_PARSE='Y'
            THEN   
               dbms_output.put_line('Hard Parse Forced');
               j:=j+1;
               FHP:=FHP+1;
            END IF;
            IF 
               EXPLAIN_PLAN_CURSOR='Y' 
            THEN   
               dbms_output.put_line('Explain Plan Cursors Cannot be Shared');
               j:=j+1;
               EPC:=EPC+1;
            END IF;
            IF 
               BUFFERED_DML_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Buffered DML');
               j:=j+1;
               BDM:=BDM+1;
            END IF;
            IF 
               PDML_ENV_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Environment');
               j:=j+1;
               PEM:=PEM+1;
            END IF;
            IF 
               INST_DRTLD_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch in Insert Direct Load');
               j:=j+1;
               IDM:=IDM+1;
            END IF;
            IF 
               SLAVE_QC_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch in the Slave Query Coordinator');
               j:=j+1;
               SQM:=SQM+1;
            END IF;
            IF 
               TYPECHECK_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Existing Child Cursor is not Fully Optimized');
               j:=j+1;
               TM1:=TM1+1;
            END IF;
            IF 
               AUTH_CHECK_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Failed to Match Authentication/Translation Checks');
               j:=j+1;
               ACM:=ACM+1;
            END IF;
            IF 
               BIND_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch in Bind Metadata');
               j:=j+1;
               BM:=BM+1;
            END IF;
            IF 
               DESCRIBE_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch because Type Check Data is Missing');
               j:=j+1;
               DM:=DM+1;
            END IF;
            IF 
               LANGUAGE_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch in Language Handle');
               j:=j+1;
               LM2:=LM2+1;
            END IF;
            IF 
               TRANSLATION_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Failed Because Base Objects Do Not Match');
               j:=j+1;
               TM2:=TM2+1;
            END IF;
            IF 
               ROW_LEVEL_SEC_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Row Level Security');
               j:=j+1;
               RLSM:=RLSM+1;
            END IF;
            IF 
               INSUFF_PRIVS='Y' 
            THEN   
               dbms_output.put_line('Insufficient Privs on Base Objects');
               j:=j+1;
               IP:=IP+1;
            END IF;
            IF 
               INSUFF_PRIVS_REM='Y' 
            THEN   
               dbms_output.put_line('Insufficient Privs on Remote Objects');
               j:=j+1;
               IPR:=IPR+1;
            END IF;
            IF 
               REMOTE_TRANS_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Remote Objects');
               j:=j+1;
               RTM:=RTM+1;
            END IF;
            IF 
               LOGMINER_SESSION_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to LogMiner Session Parameters');
               j:=j+1;
               LSM:=LSM+1;
            END IF;
            IF 
               INCOMP_LTRL_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Bind errors due to Value Mismatch in Bind/Literal Values');
               j:=j+1;
               ILM:=ILM+1;
            END IF;
            IF 
               OVERLAP_TIME_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Session Parameter Setting for ERROR_ON_OVERLAP_TIME');
               j:=j+1;
               OTM:=OTM+1;
            END IF;
            IF 
               EDITION_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Edition Issues');
               j:=j+1;
               EM:=EM+1;
            END IF;
            IF 
               MV_QUERY_GEN_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to MV Query (Forced Hard Parse)');
               j:=j+1;
               MQGM:=MQGM+1;
            END IF;
            IF 
               USER_BIND_PEEK_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to User Bind Peeking');
               j:=j+1;
               UBPM:=UBPM+1;
            END IF;
            IF 
               TYPCHK_DEP_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Typcheck Dependencies');
               j:=j+1;
               TDM:=TDM+1;
            END IF;
            IF 
               NO_TRIGGER_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Cursor and Child Having No Trigger');
               j:=j+1;
               NTM:=NTM+1;
            END IF;
            IF 
               FLASHBACK_CURSOR='Y' 
            THEN   
               dbms_output.put_line('Non Shareable because of Flashback');
               j:=j+1;
               FC:=FC+1;
            END IF;
            IF 
               ANYDATA_TRANSFORMATION='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Opaque Type Transformation');
               j:=j+1;
               AT1:=AT1+1;
            END IF;
            IF 
               INCOMPLETE_CURSOR='Y' 
            THEN   
               dbms_output.put_line('Incomplete Cursor');
               j:=j+1;
               IC:=IC+1;
            END IF;
            IF 
               TOP_LEVEL_RPI_CURSOR='Y' 
            THEN   
               dbms_output.put_line('Top Level RPI Cursors');
               j:=j+1;
               TLRC:=TLRC+1;
            END IF;
            IF 
               DIFFERENT_LONG_LENGTH='Y' 
            THEN   
               dbms_output.put_line('Differences in Long Value Lengths');
               j:=j+1;
               DLL:=DLL+1;
            END IF;
            IF 
               LOGICAL_STANDBY_APPLY='Y' 
            THEN   
               dbms_output.put_line('Mismatch in Logical Standby Apply context');
               j:=j+1;
               LSA:=LSA+1;
            END IF;
            IF 
               DIFF_CALL_DURN='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Slave SQL Cursors');
               j:=j+1;
               DCD:=DCD+1;
            END IF;
            IF 
               BIND_UACS_DIFF='Y' 
            THEN   
               dbms_output.put_line('One Cursor has Bind UACS and One Does Not');
               j:=j+1;
               BUD:=BUD+1;
            END IF;
            IF 
               PLSQL_CMP_SWITCHS_DIFF='Y' 
            THEN   
               dbms_output.put_line('PLSQL Switches Different at Compile Time');
               j:=j+1;
               PCSD:=PCSD+1;
            END IF;
            IF 
               CURSOR_PARTS_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch Because of Cursor Compiled with Subexecutions');
               j:=j+1;
               CPM:=CPM+1;
            END IF;
            IF 
               STB_OBJECT_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('STB Created After Cursor Was Compiled');
               j:=j+1;
               SOM:=SOM+1;
            END IF;
            IF 
               CROSSEDITION_TRIGGER_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Trigger Version Mismatch');
               j:=j+1;
               CTM:=CTM+1;
            END IF;
            IF 
               PQ_SLAVE_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Top-level PQ Slave forced Non-Shared Cursor');
               j:=j+1;
               PSM:=PSM+1;
            END IF;
            IF 
               TOP_LEVEL_DDL_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Top Level DDL Not Shared');
               j:=j+1;
               TLDM:=TLDM+1;
            END IF;
            IF 
               MULTI_PX_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Cursor has Multi parallelizers');
               j:=j+1;
               MPM:=MPM+1;
            END IF;
            IF 
               BIND_PEEKED_PQ_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Bind Peeking');
               j:=j+1;
               BPPM:=BPPM+1;
            END IF;
            IF 
               MV_REWRITE_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to MV Rewrite');
               j:=j+1;
               MRM:=MRM+1;
            END IF;
            IF 
               ROLL_INVALID_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to rolling invalidations');
               j:=j+1;
               RIM:=RIM+1;
            END IF;
            IF 
               OPTIMIZER_MODE_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to parameter Optimizer_Mode');
               j:=j+1;
               OMM:=OMM+1;
            END IF;
            IF 
               PX_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Parameter Settings Related to Parallelism');
               j:=j+1;
               PM:=PM+1;
            END IF;
            IF 
               MV_STALEOBJ_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to MV Stale Object');
               j:=j+1;
               MSM:=MSM+1;
            END IF;
            IF 
               FLASHBACK_TABLE_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Flashback Table');
               j:=j+1;
               FTM:=FTM+1;
            END IF;
            IF 
               LITREP_COMP_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Literal Replacement');
               j:=j+1;
               LCM:=LCM+1;
            END IF;
            IF 
               PLSQL_DEBUG='Y' 
            THEN   
               dbms_output.put_line('PLSQL Debug Mismatch');
               j:=j+1;
               PD:=PD+1;
            END IF;
            IF 
               LOAD_OPTIMIZER_STATS='Y' 
            THEN   
               dbms_output.put_line('Optimizer Stats Mismatch');
               j:=j+1;
               LOS:=LOS+1;
            END IF;
            IF 
               ACL_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('ACL');
               j:=j+1;
               AM1:=AM1+1;
            END IF;
            IF 
               FLASHBACK_ARCHIVE_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Flashback Archive Issues');
               j:=j+1;
               FAM:=FAM+1;
            END IF;
            IF 
               LOCK_USER_SCHEMA_FAILED='Y' 
            THEN   
               dbms_output.put_line('User Schema Lock Issues');
               j:=j+1;
               LUSF:=LUSF+1;
            END IF;
            IF 
               REMOTE_MAPPING_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Remote Mapping Issues');
               j:=j+1;
               RMM:=RMM+1;
            END IF;
            IF 
               LOAD_RUNTIME_HEAP_FAILED='Y' 
            THEN   
               dbms_output.put_line('Runtime Issues');
               j:=j+1;
               LRHF:=LRHF+1;
            END IF;
            IF j=0
            THEN
               dbms_output.put_line('No Reasons Indicated');
               k:=k+1;
            ELSE
               dbms_output.put_line('Not Shared for '||j||' reasons');
            END IF;
            dbms_output.put_line(' -------------');

        end loop;
        dbms_output.put_line(blankline);
        dbms_output.put_line(blankline);
        dbms_output.put_line('################## Statistics ##################');
        dbms_output.put_line(blankline);
        dbms_output.put_line(blankline);
        dbms_output.put_line('########## Rows indicating non-shared code: '||i); 
        dbms_output.put_line('########## Rows not showing a reason for non-shared code:  '||k);
        dbms_output.put_line('########## Percent no reason indicated:  '||round(100*(k/i),0));
        dbms_output.put_line(blankline);
        dbms_output.put_line(blankline);
        dbms_output.put_line('############# Breakdown of Reasons #############');
        dbms_output.put_line(blankline);
        dbms_output.put_line(blankline);
        IF UC>0
        THEN
           dbms_output.put_line('UNBOUND_CURSOR   '||UC);
        END IF;
        IF STM > 0
        THEN
           dbms_output.put_line('SQL_TYPE_MISMATCH   '||STM);
        END IF;
        IF OPM > 0
        THEN   
            dbms_output.put_line('OPTIMIZER_MISMATCH    '||OPM);
        END IF;
        IF OUM > 0
        THEN   
            dbms_output.put_line('OUTLINE_MISMATCH   '||OUM);
        END IF;
                IF SRM1 > 0
        THEN   
            dbms_output.put_line('STATS_ROW_MISMATCH  '||SRM1);
        END IF;
        IF LM1 > 0
        THEN   
            dbms_output.put_line('LITERAL_MISMATCH   '||LM1);
        END IF;
        IF FHP > 0
        THEN
            dbms_output.put_line('FORCE_HARD_PARSE  '||FHP);
        END IF;
        IF EPC > 0
        THEN   
            dbms_output.put_line('EXPLAIN_PLAN_CURSOR   '||EPC);
        END IF;
        IF BDM > 0
        THEN   
            dbms_output.put_line('BUFFERED_DML_MISMATCH   '||BDM);
        END IF;
        IF PEM > 0
        THEN   
            dbms_output.put_line('PDML_ENV_MISMATCH   '||PEM);
        END IF;
        IF IDM > 0
        THEN   
            dbms_output.put_line('INST_DRTLD_MISMATCH  '||IDM);
        END IF;
        IF SQM > 0
        THEN   
            dbms_output.put_line('SLAVE_QC_MISMATCH   '||SQM);
        END IF;
        IF TM1 > 0
        THEN   
            dbms_output.put_line('TYPECHECK_MISMATCH   '||TM1);
        END IF;
        IF ACM > 0
        THEN   
            dbms_output.put_line('AUTH_CHECK_MISMATCH   '||ACM);
        END IF;
        IF BM > 0
        THEN   
            dbms_output.put_line('BIND_MISMATCH   '||BM);
        END IF;
        IF DM > 0
        THEN   
            dbms_output.put_line('DESCRIBE_MISMATCH   '||DM);
        END IF;
        IF LM2 > 0
        THEN   
            dbms_output.put_line('LANGUAGE_MISMATCH   '||LM2);
        END IF;
        IF TM2 > 0
        THEN   
            dbms_output.put_line('TRANSLATION_MISMATCH   '||LM2);
        END IF;
        IF RLSM > 0 
        THEN   
            dbms_output.put_line('ROW_LEVEL_SEC_MISMATCH   '||RLSM);
        END IF;
        IF IP > 0
        THEN   
            dbms_output.put_line('INSUFF_PRIVS   '||IP);
        END IF;
        IF IPR > 0
        THEN   
            dbms_output.put_line('INSUFF_PRIVS_REM   '||IPR);
        END IF;
        IF RTM > 0
        THEN   
            dbms_output.put_line('REMOTE_TRANS_MISMATCH   '||RTM);
        END IF;
        IF LSM > 0
        THEN   
            dbms_output.put_line('LOGMINER_SESSION_MISMATCH   '||LSM);
        END IF;
        IF ILM > 0
        THEN   
            dbms_output.put_line('INCOMP_LTRL_MISMATCH   '||ILM);
        END IF;
        IF  OTM > 0
        THEN   
            dbms_output.put_line('OVERLAP_TIME_MISMATCH   '||OTM);
        END IF;
        IF EM > 0
        THEN   
            dbms_output.put_line('EDITION_MISMATCH   '||EM);
        END IF;
        IF MQGM > 0
        THEN   
            dbms_output.put_line('MV_QUERY_GEN_MISMATCH   '||MQGM);
        END IF;
        IF UBPM > 0
        THEN   
            dbms_output.put_line('USER_BIND_PEEK_MISMATCH   '||UBPM);
        END IF;
        IF TDM > 0
        THEN   
            dbms_output.put_line('TYPCHK_DEP_MISMATCH   '||TDM);
        END IF;
        IF NTM > 0
        THEN   
            dbms_output.put_line('NO_TRIGGER_MISMATCH   '||NTM);
        END IF;
        IF FC > 0
        THEN   
            dbms_output.put_line('FLASHBACK_CURSOR   '||FC);
        END IF;
        IF AT1 > 0
        THEN   
            dbms_output.put_line('ANYDATA_TRANSFORMATION   '||AT1);
        END IF;
        IF IC > 0
        THEN   
            dbms_output.put_line('INCOMPLETE_CURSOR   '||IC);
        END IF;
        IF TLRC > 0
        THEN   
            dbms_output.put_line('TOP_LEVEL_RPI_CURSOR   '||TLRC);
        END IF;
        IF DLL > 0
        THEN   
            dbms_output.put_line('DIFFERENT_LONG_LENGTH   '||DLL);
        END IF;
        IF LSA > 0
        THEN   
            dbms_output.put_line('LOGICAL_STANDBY_APPLY   '||LSA);
        END IF;
        IF DCD > 0
        THEN   
            dbms_output.put_line('DIFF_CALL_DURN   '||DCD);
        END IF;
        IF BUD > 0
        THEN   
            dbms_output.put_line('BIND_UACS_DIFF   '||BUD);
        END IF;
        IF PCSD > 0
        THEN   
            dbms_output.put_line('PLSQL_CMP_SWITCHS_DIFF   '||PCSD);
        END IF;
        IF CPM > 0
        THEN   
            dbms_output.put_line('CURSOR_PARTS_MISMATCH   '||CPM);
        END IF;
        IF SOM > 0
        THEN   
            dbms_output.put_line('STB_OBJECT_MISMATCH   '||SOM);
        END IF;
         If CTM > 0
        THEN 
            dbms_output.put_line('CROSSEDITION_TRIGGER_MISMATCH   '||CTM);
        END IF;
        IF PSM > 0
        THEN   
            dbms_output.put_line('PQ_SLAVE_MISMATCH   '||PSM);
        END IF;
        IF TLDM > 0
        THEN   
            dbms_output.put_line('TOP_LEVEL_DDL_MISMATCH   '||TLDM);
        END IF;
        IF MPM > 0
        THEN   
            dbms_output.put_line('MULTI_PX_MISMATCH   '||MPM);
        END IF;
        IF BPPM > 0
        THEN   
            dbms_output.put_line('BIND_PEEKED_PQ_MISMATCH   '||BPPM);
        END IF;
        IF MRM > 0
        THEN   
            dbms_output.put_line('MV_REWRITE_MISMATCH   '||MRM);
        END IF;
        IF RIM > 0
        THEN   
            dbms_output.put_line('ROLL_INVALID_MISMATCH   '||RIM);
        END IF;
        IF OMM > 0
        THEN   
            dbms_output.put_line('OPTIMIZER_MODE_MISMATCH   '||OMM);
        END IF;
        IF PM > 0
        THEN   
            dbms_output.put_line('PX_MISMATCH   '||PM);
        END IF;
        IF MSM > 0
        THEN   
            dbms_output.put_line('MV_STALEOBJ_MISMATCH   '||MSM);
        END IF;
        IF FTM > 0
        THEN   
            dbms_output.put_line('FLASHBACK_TABLE_MISMATCH   '||FTM);
        END IF;
        IF LCM > 0
        THEN   
            dbms_output.put_line('LITREP_COMP_MISMATCH   '||LCM);
        END IF;
        IF PD > 0
        THEN
            dbms_output.put_line('PLSQL_DEBUG    '||PD); 
        END IF;
        IF LOS > 0
        THEN   
            dbms_output.put_line('LOAD_OPTIMIZER_STATS   '||LOS);
        END IF;
        IF AM1 > 0
        THEN   
            dbms_output.put_line('ACL_MISMATCH   '||AM1);
        END IF;
        IF FAM > 0
        THEN   
            dbms_output.put_line('FLASHBACK_ARCHIVE_MISMATCH   '||FAM);
        END IF;
        IF LUSF > 0
        THEN   
            dbms_output.put_line('LOCK_USER_SCHEMA_FAILED  '||LUSF);
        END IF;
        IF RMM > 0
        THEN   
            dbms_output.put_line('REMOTE_MAPPING_MISMATCH  '||RMM);
        END IF;
        IF LRHF > 0
        THEN   
            dbms_output.put_line('LOAD_RUNTIME_HEAP_FAILED  '||LRHF);
        END IF;
        close code;
end;
/
spool off
undef threshold
SET VERIFY ON
