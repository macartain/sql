/* ACCOUNTRATINGSUMMARY reorg */
RENAME ACCOUNTRATINGSUMMARY TO ACCOUNTRATINGSUMMARY_BKP;

CREATE TABLE ACCOUNTRATINGSUMMARY
TABLESPACE CUSTOMER_TAB_TS_1
PCTUSED    40
PCTFREE    30
INITRANS   40
MAXTRANS   255
STORAGE    (
            INITIAL          10M
            NEXT             10M
            MINEXTENTS       1
            MAXEXTENTS       2147483645
            PCTINCREASE      0
            FREELISTS        40
            FREELIST GROUPS  8
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCACHE
NOPARALLEL
MONITORING
AS
SELECT /*+ PARALLEL(ACCOUNTRATINGSUMMARY_BKP 16) */ *
FROM ACCOUNTRATINGSUMMARY_BKP
ORDER BY ACCOUNT_NUM, EVENT_SEQ, EVENT_PROCESS_GROUP;

ALTER TABLE ACCOUNTRATINGSUMMARY_BKP DROP CONSTRAINT ACCOUNTRATINGSUMMARY_PK;

CREATE UNIQUE INDEX ACCOUNTRATINGSUMMARY_PK ON ACCOUNTRATINGSUMMARY
(ACCOUNT_NUM, EVENT_SEQ, EVENT_PROCESS_GROUP)
LOGGING
TABLESPACE INDEX01
PCTFREE    10
INITRANS   40
MAXTRANS   255
STORAGE    (
            INITIAL          10M
            NEXT             10M
            MINEXTENTS       1
            MAXEXTENTS       2147483645
            PCTINCREASE      0
            FREELISTS        40
            FREELIST GROUPS  8
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL
NOSORT
;

ALTER TABLE ACCOUNTRATINGSUMMARY ADD (
  CONSTRAINT ACCOUNTRATINGSUMMARY_PK PRIMARY KEY (ACCOUNT_NUM, EVENT_SEQ, EVENT_PROCESS_GROUP)
    USING INDEX 
    TABLESPACE INDEX01
    PCTFREE    10
    INITRANS   40
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        40
                FREELIST GROUPS  8
               ))
;

GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE ON  ACCOUNTRATINGSUMMARY TO SUBADMINAPI;
GRANT ALTER, DELETE, INSERT, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, DEBUG, FLASHBACK ON  ACCOUNTRATINGSUMMARY TO GENEVAADMIN;
GRANT SELECT ON  ACCOUNTRATINGSUMMARY TO SUBINFO;

exec dbms_stats.gather_table_stats(ownname => 'GENEVA_ADMIN', tabname => 'ACCOUNTRATINGSUMMARY', estimate_percent => dbms_stats.auto_sample_size, degree => 12, method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => true);


/* COSTEDEVENTQUEUETAIL reorg  */

execute dbms_aqadm.unschedule_propagation(USER||'.COSTEDEVENTQUEUEHEAD', NULL);
execute dbms_aqadm.stop_queue(queue_name => 'COSTEDEVENTQUEUETAIL');
execute dbms_aqadm.drop_queue(queue_name => 'COSTEDEVENTQUEUETAIL');
execute dbms_aqadm.drop_queue_table(queue_table => 'COSTEDEVENTQUEUETAIL', force => TRUE);
begin
    dbms_aqadm.create_queue_table(queue_table        => 'COSTEDEVENTQUEUETAIL',
                                  queue_payload_type => 'RAW',
                                  multiple_consumers => TRUE,
                                  compatible         => '8.1.3',
                                  storage_clause     => 'tablespace QUEUETAIL_TS');
end;
/
begin
    dbms_aqadm.create_queue(queue_name     => 'COSTEDEVENTQUEUETAIL',
                            queue_table    => 'COSTEDEVENTQUEUETAIL',
                            retention_time => 0);
    dbms_aqadm.start_queue(queue_name => 'COSTEDEVENTQUEUETAIL');
end;
/
declare
    v_subscriber sys.aq$_agent;
begin
    v_subscriber := sys.aq$_agent('CEW', 'COSTEDEVENTQUEUETAIL', 0);

    dbms_aqadm.add_subscriber(queue_name => 'COSTEDEVENTQUEUETAIL',
                              subscriber => v_subscriber);
end;
/
declare
    v_subscriber sys.aq$_agent;
    v_eventdb varchar2(255)         := null;
    v_eventdb_username varchar2(30) := null;
    v_dblink  varchar2(255)         := null;
begin
    v_eventdb_username := USER;
    v_subscriber := sys.aq$_agent(NULL,
                                  v_eventdb_username||'.COSTEDEVENTQUEUETAIL'||v_dblink,
                                  NULL);

    dbms_aqadm.add_subscriber(queue_name => USER||'.COSTEDEVENTQUEUEHEAD',
                              subscriber => v_subscriber);
end;
/
begin
    dbms_aqadm.schedule_propagation(queue_name  => USER||'.COSTEDEVENTQUEUEHEAD',
                                    latency     => 0);
end;
/


DROP TABLE CPDUMANAGEREQUEST;

CREATE TABLE CPDUMANAGEREQUEST
(
  CUSTOMER_REF      VARCHAR2(20 BYTE)           NOT NULL,
  PRODUCT_SEQ       NUMBER(9),
  ACTION_DAT        DATE                        NOT NULL,
  RANDOM_WORK_HASH  NUMBER(6)                   NOT NULL
)
TABLESPACE DATA
PCTUSED    40
PCTFREE    10
INITRANS   40
MAXTRANS   255
STORAGE    (
            INITIAL          10M
            NEXT             10M
            MINEXTENTS       1
            MAXEXTENTS       2147483645
            PCTINCREASE      0
            FREELISTS        40
            FREELIST GROUPS  8
            BUFFER_POOL      KEEP
           )
LOGGING 
NOCACHE
NOPARALLEL
MONITORING;

CREATE INDEX CPDUMANAGEREQUEST_AK1 ON CPDUMANAGEREQUEST
(RANDOM_WORK_HASH, ACTION_DAT)
LOGGING
TABLESPACE INDEX01
PCTFREE    10
INITRANS   40
MAXTRANS   255
STORAGE    (
            INITIAL          10M
            NEXT             10M
            MINEXTENTS       1
            MAXEXTENTS       2147483645
            PCTINCREASE      0
            FREELISTS        40
            FREELIST GROUPS  8
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

CREATE UNIQUE INDEX CPDUMANAGEREQUEST_UKP ON CPDUMANAGEREQUEST
(CUSTOMER_REF, PRODUCT_SEQ)
LOGGING
TABLESPACE CUSTOMER_IND_TS_1
PCTFREE    10
INITRANS   40
MAXTRANS   255
STORAGE    (
            INITIAL          10M
            NEXT             10M
            MINEXTENTS       1
            MAXEXTENTS       2147483645
            PCTINCREASE      0
            FREELISTS        40
            FREELIST GROUPS  8
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

ALTER TABLE CPDUMANAGEREQUEST ADD (
  CONSTRAINT CPDUMANAGEREQUEST_UKP UNIQUE (CUSTOMER_REF, PRODUCT_SEQ)
    USING INDEX 
    TABLESPACE CUSTOMER_IND_TS_1
    PCTFREE    10
    INITRANS   40
    MAXTRANS   255
    STORAGE    (
                INITIAL          10M
                NEXT             10M
                MINEXTENTS       1
                MAXEXTENTS       2147483645
                PCTINCREASE      0
                FREELISTS        40
                FREELIST GROUPS  8
               ));


CREATE OR REPLACE TRIGGER IPGTRADMANAGEREQUEST
	AFTER DELETE ON CPDUMANAGEREQUEST
FOR EACH ROW
DECLARE
  -- local variables here
  prodSeq       NUMBER;

BEGIN
    -- If trigger actioned due to termination of migrated product the
    -- procedures will not be implemented and the error is nullified.
    SELECT product_seq
      INTO prodSeq
      FROM ipgMigProducts
     WHERE customer_ref = :old.customer_ref
       AND product_seq = :old.product_seq;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    	ipggsmdiscount.proRateBucket(
    		customerRef	=>	:old.customer_ref,
    		productSeq  =>  :old.product_seq,
    		actionDat   =>  :old.action_dat );

      	ipggsmdiscount.resetNewMigratedBucket(
      		customerRef 	=>	:old.customer_ref,
      		newProductSeq  	=>  :old.product_seq
      		);

END ipgtradmanagerequest;
/
SHOW ERRORS;



GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE ON  CPDUMANAGEREQUEST TO SUBADMINAPI;

GRANT ALTER, DELETE, INSERT, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, DEBUG, FLASHBACK ON  CPDUMANAGEREQUEST TO GENEVAADMIN;

GRANT SELECT ON  CPDUMANAGEREQUEST TO SUBINFO;
exec dbms_stats.gather_table_stats(ownname => 'GENEVA_ADMIN', tabname => 'CPDUMANAGEREQUEST', estimate_percent => dbms_stats.auto_sample_size, degree => 12, method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => true);
