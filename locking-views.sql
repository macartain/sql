-- If erros are encountered with CREATE VIEW FORCE, remove the force option to get the detailed error - show errors will not work
-- Required grants
grant select on V_$LOCKED_OBJECT  to public;
grant select on V_$LOCK to public;
grant select on V_$session  to public;

-- Summary MV recreated daily
CREATE MATERIALIZED VIEW TRCUSER.DB$OBJECTS 
        PCTFREE 10 PCTUSED 0 INITRANS 2 MAXTRANS 255 
        STORAGE( 
                MINEXTENTS 1 
                MAXEXTENTS UNLIMITED 
                PCTINCREASE 0 
                BUFFER_POOL DEFAULT 
                ) 
TABLESPACE OSM 
NOLOGGING 
NOCACHE 
NOPARALLEL 
USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
        STORAGE(BUFFER_POOL DEFAULT) 
REFRESH COMPLETE 
        WITH ROWID 
 USING DEFAULT LOCAL ROLLBACK SEGMENT 
DISABLE QUERY REWRITE AS 
SELECT * 
  FROM DBA_OBJECTS 
/

-- View for end user queries
CREATE OR REPLACE FORCE VIEW DB$LOCKED_OBJECTS 
(OBJECT_NAME, SESSION_ID, ORACLE_USERNAME, OS_USER_NAME, SQL_ACTIONS, LOCK_MODE) 
AS 
SELECT /*+ no_merge(lo) */ 
       DO.object_name, lo.SESSION_ID, lo.oracle_username, lo.OS_USER_NAME, 
       DECODE(locked_mode, 
              1, 'SELECT', 
              2, 'SELECT FOR UPDATE / LOCK ROW SHARE', 
              3, 'INSERT/UPDATE/DELETE/LOCK ROW EXCLUSIVE', 
              4, 'CREATE INDEX/LOCK SHARE', 
              5, 'LOCK SHARE ROW EXCLUSIVE', 
              6, 'ALTER TABLE/DROP TABLE/DROP INDEX/TRUNCATE TABLE/LOCK EXCLUSIVE') sql_actions, 
       DECODE(locked_mode, 1, 'NULL', 2, 'SS - SUB SHARE', 3, 'SX - SUB EXCLUSIVE', 
              4, 'S - SHARE', 5, 'SSX - SHARE/SUB EXCLUSIVE', 6, 'X - EXCLUSIVE') Lock_mode 
  FROM sys.V_$LOCKED_OBJECT lo, DB$OBJECTS DO 
 WHERE DO.object_id = lo.object_id; 

CREATE PUBLIC SYNONYM DB$LOCKED_OBJECTS FOR TRCUSER.DB$LOCKED_OBJECTS; 
GRANT SELECT ON  TRCUSER.DB$LOCKED_OBJECTS TO PUBLIC; 

-- View for end user queries
CREATE OR REPLACE FORCE VIEW DB$LOCKS 
(OBJ_OWNER, OBJ_NAME, OBJ_TYPE, OBJ_ROWID, DB_USER,SID, LOCK_TYPE, ROW_WAIT_FILE#, ROW_WAIT_BLOCK#, ROW_WAIT_ROW#) 
AS 
SELECT owner obj_owner, 
       object_name obj_name, 
       object_type  obj_type, 
       dbms_rowid.rowid_create(1, row_wait_obj#, ROW_WAIT_FILE#, 
                               ROW_WAIT_BLOCK#,ROW_WAIT_ROW#) obj_rowid, 
       a.username db_user, a.SID SID, a.TYPE lock_type, 
       a.row_wait_file#, a.row_wait_block#, a.row_wait_row# 
  FROM DB$OBJECTS, 
       (SELECT /*+ no_merge(a) no_merge(b) */ 
               a.username, a.SID, a.row_wait_obj#, a.ROW_WAIT_FILE#, 
               a.ROW_WAIT_BLOCK#, a.ROW_WAIT_ROW#, b.TYPE 
          FROM sys.V_$SESSION a, sys.V_$LOCK b 
         WHERE a.username IS NOT NULL 
           AND a.row_wait_obj# <> -1 
           AND a.SID = b.SID 
           AND b.TYPE IN ('TX','TM') 
           ) a 
 WHERE object_id = a.row_wait_obj#; 
CREATE PUBLIC SYNONYM DB$LOCKS FOR TRCUSER.DB$LOCKS; 
GRANT SELECT ON  TRCUSER.DB$LOCKS TO PUBLIC; 