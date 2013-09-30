
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
   SQL_TEXT varchar2(1000);
   SQL_ID varchar2(1);
   UNBOUND_CURSOR VARCHAR2(1);
   SQL_TYPE_MISMATCH VARCHAR2(1);
   OPTIMIZER_MISMATCH VARCHAR2(1);
   OUTLINE_MISMATCH   VARCHAR2(1);
   STATS_ROW_MISMATCH VARCHAR2(1);
   LITERAL_MISMATCH VARCHAR2(1);
   SEC_DEPTH_MISMATCH VARCHAR2(1);
   EXPLAIN_PLAN_CURSOR VARCHAR2(1);
   BUFFERED_DML_MISMATCH VARCHAR2(1);
   PDML_ENV_MISMATCH VARCHAR2(1);
   INST_DRTLD_MISMATCH VARCHAR2(1);
   SLAVE_QC_MISMATCH VARCHAR2(1);
   TYPECHECK_MISMATCH VARCHAR2(1);
   AUTH_CHECK_MISMATCH VARCHAR2(1);
   BIND_MISMATCH VARCHAR2(1);
   DESCRIBE_MISMATCH VARCHAR2(1);
   LANGUAGE_MISMATCH VARCHAR2(1);
   TRANSLATION_MISMATCH VARCHAR2(1); 
   ROW_LEVEL_SEC_MISMATCH VARCHAR2(1);
   INSUFF_PRIVS VARCHAR2(1);
   INSUFF_PRIVS_REM VARCHAR2(1);
   REMOTE_TRANS_MISMATCH VARCHAR2(1);
   LOGMINER_SESSION_MISMATCH VARCHAR2(1);
   INCOMP_LTRL_MISMATCH VARCHAR2(1);
   OVERLAP_TIME_MISMATCH VARCHAR2(1);
   SQL_REDIRECT_MISMATCH VARCHAR2(1);
   MV_QUERY_GEN_MISMATCH VARCHAR2(1);
   USER_BIND_PEEK_MISMATCH VARCHAR2(1);
   TYPCHK_DEP_MISMATCH VARCHAR2(1);
   NO_TRIGGER_MISMATCH VARCHAR2(1);
   FLASHBACK_CURSOR  VARCHAR2(1);
   LITREP_COMP_MISMATCH  VARCHAR2(1);
   UC number; STM number; OPM number; 
   OUM number; SRM1 number; LM1 number;
   SDM number; EPC number; BDM number; 
   PEM number; IDM number; SQM number; 
   TM1 number; ACM number; BM number; 
   LM2 number; TM2 number; DM number;
   RLSM number; LSM number; ILM number; 
   OTM number; SRM2 number; MQGM number; 
   UBPM number; TDM number; NTM number; 
   FC number; IP number; LCM number; 
   IPR number; RTM number; blankline varchar2(70);

   CURSOR code is select substr(sql_text,1,500),
         UNBOUND_CURSOR, SQL_TYPE_MISMATCH, OPTIMIZER_MISMATCH, OUTLINE_MISMATCH  , 
         STATS_ROW_MISMATCH, LITERAL_MISMATCH, SEC_DEPTH_MISMATCH, EXPLAIN_PLAN_CURSOR,
         BUFFERED_DML_MISMATCH, PDML_ENV_MISMATCH, INST_DRTLD_MISMATCH, SLAVE_QC_MISMATCH,
         TYPECHECK_MISMATCH, AUTH_CHECK_MISMATCH, BIND_MISMATCH, DESCRIBE_MISMATCH,
         LANGUAGE_MISMATCH, TRANSLATION_MISMATCH, ROW_LEVEL_SEC_MISMATCH, INSUFF_PRIVS,
         INSUFF_PRIVS_REM, REMOTE_TRANS_MISMATCH, LOGMINER_SESSION_MISMATCH, INCOMP_LTRL_MISMATCH,
         OVERLAP_TIME_MISMATCH, SQL_REDIRECT_MISMATCH, MV_QUERY_GEN_MISMATCH, USER_BIND_PEEK_MISMATCH,
         TYPCHK_DEP_MISMATCH, NO_TRIGGER_MISMATCH, FLASHBACK_CURSOR , LITREP_COMP_MISMATCH
      from v$sql_shared_cursor sc, v$sqlarea sa
      where sa.address = sc.address
      and   version_count> (select (max(version_count)*&threshold) from v$sqlarea)
      order by 1;

begin
     i:=0; k:=0;
     UC:=0; STM:=0; OPM:=0; 
     OUM:=0; SRM1:=0; LM1:=0;
     SDM:=0; EPC:=0; BDM:=0; 
     PEM:=0; IDM:=0; SQM:=0; 
     TM1:=0; ACM:=0; BM:=0; 
     LM2:=0; TM2:=0; DM:=0;
     RLSM:=0; LSM:=0; ILM:=0; 
     OTM:=0; SRM2:=0; MQGM:=0; 
     UBPM:=0; TDM:=0; NTM:=0; 
     FC:=0; IP:=0; LCM:=0; 
     IPR:=0; RTM:=0;
     blankline:=chr(13);
     open code;
     loop
        fetch code into 
        sql_text, UNBOUND_CURSOR, SQL_TYPE_MISMATCH, OPTIMIZER_MISMATCH, OUTLINE_MISMATCH  , 
         STATS_ROW_MISMATCH, LITERAL_MISMATCH, SEC_DEPTH_MISMATCH, EXPLAIN_PLAN_CURSOR,
         BUFFERED_DML_MISMATCH, PDML_ENV_MISMATCH, INST_DRTLD_MISMATCH, SLAVE_QC_MISMATCH,
         TYPECHECK_MISMATCH, AUTH_CHECK_MISMATCH, BIND_MISMATCH, DESCRIBE_MISMATCH,
         LANGUAGE_MISMATCH, TRANSLATION_MISMATCH, ROW_LEVEL_SEC_MISMATCH, INSUFF_PRIVS,
         INSUFF_PRIVS_REM, REMOTE_TRANS_MISMATCH, LOGMINER_SESSION_MISMATCH, INCOMP_LTRL_MISMATCH,
         OVERLAP_TIME_MISMATCH, SQL_REDIRECT_MISMATCH, MV_QUERY_GEN_MISMATCH, USER_BIND_PEEK_MISMATCH,
         TYPCHK_DEP_MISMATCH, NO_TRIGGER_MISMATCH, FLASHBACK_CURSOR , LITREP_COMP_MISMATCH;
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
               SEC_DEPTH_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Security Level Differences');
               j:=j+1;
               SDM:=SDM+1;
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
               TM1:=Tm1+1;
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
               SQL_REDIRECT_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to SQL Redirection');
               j:=j+1;
               SRM2:=SRM2+1;
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
               LITREP_COMP_MISMATCH='Y' 
            THEN   
               dbms_output.put_line('Mismatch due to Literal Replacement');
               j:=j+1;
               LCM:=LCM+1;
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
        IF SDM > 0
        THEN   
            dbms_output.put_line('SEC_DEPTH_MISMATCH   '||SDM);
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
        IF SRM2 > 0
        THEN   
            dbms_output.put_line('SQL_REDIRECT_MISMATCH   '||LM1);
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
        IF LCM > 0
        THEN   
            dbms_output.put_line('LITREP_COMP_MISMATCH   '||LCM);
        END IF;
        close code;
end;
/
spool off
undef threshold
SET VERIFY ON