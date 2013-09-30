SET LINESIZE 132
SET FEEDBACK OFF
SET VERIFY   OFF

COLUMN con_name FORMAT a30 HEADING "Foreign Key"
COLUMN con_col  FORMAT a30 HEADING "Local Column"
COLUMN r_con    FORMAT a65 WRAPPED HEADING "Refers To"
COLUMN ref_tab  FORMAT a30 HEADING "Referenced By"

ACCEPT 1 PROMPT 'Input table owner: '
ACCEPT 2 PROMPt 'Input table name:  '

SET HEADING OFF

SELECT global_name || ' at ' ||
       TO_CHAR (SYSDATE, 'DD-MON-YY HH24:MI:SS')
FROM   global_name;

SELECT 'Foreign Key Constraints on ' ||
       UPPER ('&1') || '.' || UPPER ('&2') || ':'
FROM   dual;

SET HEADING ON
BREAK ON CON_NAME

SELECT   A.constraint_name con_name, B.column_name con_col,
         C.table_name || '.' || C.constraint_name ||
         ' (' || C.constraint_type || ')' r_con
FROM     all_constraints A, all_cons_columns B, all_constraints C
WHERE    A.owner = UPPER ('&1')
AND      A.table_name = UPPER ('&2')
AND      A.constraint_type = 'R'
AND      B.owner = A.owner
AND      B.table_name = A.table_name
AND      B.constraint_name = A.constraint_name
AND      C.owner = A.r_owner (+)
AND      C.constraint_name = A.r_constraint_name (+)
ORDER BY con_name, B.position;

SET HEADING OFF

SELECT 'Table ' || UPPER ('&1') || '.' || UPPER ('&2') ||
       ' is Referenced by:'
FROM   dual;

SET HEADING ON

BREAK ON con_col SKIP 1

SELECT   B.column_name con_col, C.table_name ref_tab,
         C.constraint_name con_name
FROM     all_constraints A, all_cons_columns B, all_constraints C
WHERE    A.owner = UPPER ('&1')
AND      A.table_name = UPPER ('&2')
AND      A.constraint_type IN ('P', 'U')
AND      B.owner = A.owner
AND      B.constraint_name = A.constraint_name
AND      C.r_owner = A.owner
AND      C.r_constraint_name = A.constraint_name
AND      C.constraint_type = 'R'
ORDER BY B.column_name, C.table_name;