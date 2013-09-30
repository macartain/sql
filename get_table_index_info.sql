/* 
Program     : get_table_index_info.sql
Purpose     : Get current optimizer statistics for a table
Author      : Daniel W. Fink OptimalDBA.com
Created     : March 17, 2009
Update      : 
Parameters  : &1 owner_table in the format owner.table (not case sensitive)
            : Example @get_table_index_info.sql scott.emp
Exit Code   : Not Used
Comments    : 
Disclaimer  : No warranty is provided for any use of the script, statements or logic included. 
              This script, statements and logic are for personal use only and may not be included 
              as part of a commercial product. 
              Please address any comments to script_feedback@optimaldba.com
              This comment block and all lines above must be included.

*/

SET VERIFY OFF PAGESIZE 400 LINESIZE 135

DEFINE  owner_table = &1
COLUMN spoolname FORMAT A50 NEW_VALUE spool_name NOPRINT

SELECT    'tab_idx_info_'||UPPER('&&owner_table')||'_'||TO_CHAR(SYSDATE, 'YYYYMMDDhh24miss')||'.log' spoolname
FROM       dual
/

SPOOL &&spool_name


COLUMN     tab_degree                FORMAT 9999             HEADING 'Deg'
COLUMN     tab_partitioned           FORMAT A4               HEADING 'Prtn'
COLUMN     tab_num_rows              FORMAT 999,999,999      HEADING 'Rows'
COLUMN     tab_alloc_blocks          FORMAT 999,999,999      HEADING 'Allocated|Blocks'
COLUMN     tab_hwm_blocks            FORMAT 999,999,999      HEADING 'HWM|Blocks'
COLUMN     tab_last_analyzed_time    FORMAT A17              HEADING 'Analyzed Date'
COLUMN     tab_analyzed_pct          FORMAT 999.99           HEADING 'Analyze|Pct'
COLUMN     tab_avg_space             FORMAT 99999            HEADING 'Avg Block|Free Space'
COLUMN     tab_avg_row_length        FORMAT 99999            HEADING 'Avg Row|Length'
COLUMN     tab_monitoring            FORMAT A4               HEADING 'Mntr'

PROMPT
PROMPT
PROMPT *********************************************************************************
PROMPT Table Statistics for &&owner_table
PROMPT *********************************************************************************
PROMPT


SELECT     TO_NUMBER(t.degree)                             tab_degree,
           t.partitioned                                   tab_partitioned,
           t.num_rows                                      tab_num_rows,
           t.blocks                                        tab_alloc_blocks,
           (t.blocks - t.empty_blocks)                     tab_hwm_blocks,
           TO_CHAR(t.last_analyzed, 'MM/DD/YYYY hh24:mi')  tab_last_analyzed_time,
           ROUND((t.sample_size/DECODE(t.num_rows,0,1,t.num_rows))*100,2)
                                                           tab_analyzed_pct,
           t.avg_space                                     tab_avg_space,
           t.avg_row_len                                   tab_avg_row_length,
           t.monitoring                                    tab_monitoring
FROM       dba_tables t
WHERE      t.owner||'.'||t.table_name = UPPER('&&owner_table')
ORDER BY   t.table_name
/



COLUMN     tab_column_name           FORMAT A30              HEADING 'Column Name'
COLUMN     tab_column_datatype       FORMAT A20              HEADING 'Datatype'
COLUMN     tab_column_nullable       FORMAT A10              HEADING 'Nullable?'
COLUMN     tab_column_numdistinct    FORMAT 999,999,999      HEADING 'Distinct|Values'
COLUMN     tab_column_density        FORMAT 9.99999          HEADING 'Density'
COLUMN     tab_column_numnulls       FORMAT 999,999,999      HEADING 'Number|of Nulls'
COLUMN     tab_column_histogram      FORMAT A16              HEADING 'Histogram'
COLUMN     tab_column_numbuckets     FORMAT 999,999          HEADING 'Buckets'

PROMPT
PROMPT
PROMPT *********************************************************************************
PROMPT Column Statistics for &&owner_table
PROMPT *********************************************************************************
PROMPT

SELECT     tc.column_name                                  tab_column_name,
           tc.data_type                                    tab_column_datatype,
           DECODE(tc.nullable, 'N', 'NOT NULL', NULL)      tab_column_nullable,
           tc.num_distinct                                 tab_column_numdistinct,
           tc.density                                      tab_column_density,
           tc.num_nulls                                    tab_column_numnulls,
           DECODE(tc.histogram,'NONE', NULL, tc.histogram) tab_column_histogram,
           TO_NUMBER(DECODE(tc.num_buckets,1,NULL,
                                      tc.num_buckets))     tab_column_numbuckets
FROM       dba_tab_columns tc
WHERE      tc.owner||'.'||tc.table_name = UPPER('&&owner_table')
ORDER BY   tc.column_id
/


PROMPT
PROMPT
PROMPT *********************************************************************************
PROMPT Index Statistics for &&owner_table
PROMPT *********************************************************************************
PROMPT

SELECT     i.index_name                                    ind_name,
           i.status                                        ind_status,
           DECODE(i.uniqueness,'UNIQUE','Y',NULL)          ind_unique,
           i.blevel                                        ind_blevel,
           i.leaf_blocks                                   ind_leafblocks,
           i.num_rows                                      ind_numrows,
           i.distinct_keys                                 ind_distinctkeys,
           i.clustering_factor                             ind_clufac,
           TO_CHAR(i.last_analyzed, 'MM/DD/YYYY hh24:mi')  last_analyzed_time
FROM       dba_indexes i
WHERE      i.table_owner||'.'||i.table_name = UPPER('&&owner_table')
ORDER BY   i.uniqueness DESC, i.index_name
/

COLUMN   index_name  FORMAT A30 HEADING 'Index Name'
COLUMN   column_name FORMAT A30 HEADING 'Column Name'
COLUMN   low_value   FORMAT A20 HEADING 'Low Value'
COLUMN   high_value  FORMAT A20 HEADING 'High Value'

BREAK ON index_name NODUP

PROMPT
PROMPT
PROMPT *********************************************************************************
PROMPT Index Columns for &&owner_table
PROMPT *********************************************************************************
PROMPT

WITH col_hi_lo_vals AS
( select     tc.column_name
        ,    tc.data_type
        ,    tc.low_value raw_low_value
        ,    tc.high_value raw_high_value
        ,    SUBSTR(dump(tc.low_value), (INSTR(dump(tc.low_value),': ')+2)) date_low_val
        ,    SUBSTR(dump(tc.high_value), (INSTR(dump(tc.high_value),': ')+2)) date_high_val   
  from       dba_tab_columns tc
  WHERE      tc.owner||'.'||tc.table_name = UPPER('&&owner_table')
),
col_hi_lo_vals_translated AS
( SELECT     column_name
         ,   data_type
         ,   CASE when data_type = 'DATE'
             THEN 
                  TO_CHAR(REGEXP_SUBSTR(date_low_val, '[0-9]+',1,1)-100, '09')|| -- low_century 
                  TO_CHAR(REGEXP_SUBSTR(date_low_val, '[0-9]+',1,2)-100, '09')|| -- low_year
                  TO_CHAR(REGEXP_SUBSTR(date_low_val, '[0-9]+',1,3),'09')|| --      low_month     
                  TO_CHAR(REGEXP_SUBSTR(date_low_val, '[0-9]+',1,4),'09')|| --      low_day     
                  TO_CHAR(REGEXP_SUBSTR(date_low_val, '[0-9]+',1,5)-1,'09')|| --      low_hour24     
                  TO_CHAR(REGEXP_SUBSTR(date_low_val, '[0-9]+',1,6)-1,'09')|| --      low_minute     
                  TO_CHAR(REGEXP_SUBSTR(date_low_val, '[0-9]+',1,7)-1,'09')   --      low_second
             ELSE
                 NULL
             END low_date
         ,   CASE when data_type = 'DATE'
             THEN 
                  TO_CHAR(REGEXP_SUBSTR(date_high_val, '[0-9]+',1,1)-100, '09')|| -- high_century
                  TO_CHAR(REGEXP_SUBSTR(date_high_val, '[0-9]+',1,2)-100, '09')|| -- high_year
                  TO_CHAR(REGEXP_SUBSTR(date_high_val, '[0-9]+',1,3), '09')|| --     high_month     
                  TO_CHAR(REGEXP_SUBSTR(date_high_val, '[0-9]+',1,4), '09')|| --     high_day
                  TO_CHAR(REGEXP_SUBSTR(date_high_val, '[0-9]+',1,5)-1, '09')|| --     high_hour24
                  TO_CHAR(REGEXP_SUBSTR(date_high_val, '[0-9]+',1,6)-1, '09')|| --     high_minute 
                  TO_CHAR(REGEXP_SUBSTR(date_high_val, '[0-9]+',1,7)-1, '09')   --     high_second     
             ELSE
                  NULL
             END high_date
         ,   CASE WHEN data_type = 'NUMBER'
                  THEN
                       utl_raw.cast_to_number(raw_low_value)
             ELSE
                  NULL
             END low_num
         ,   CASE WHEN data_type = 'NUMBER'
                  THEN
                       utl_raw.cast_to_number(raw_high_value)
             ELSE
                  NULL
             END high_num           
         ,   CASE WHEN data_type LIKE '%CHAR%'
                  THEN
                       utl_raw.cast_to_varchar2(raw_low_value)
             ELSE
                  NULL
             END low_char
         ,   CASE WHEN data_type LIKE '%CHAR%'
                  THEN
                       utl_raw.cast_to_varchar2(raw_high_value)
             ELSE
                  NULL
             END high_char           
FROM         col_hi_lo_vals
)
SELECT     ic.index_name,
           ic.column_name
      ,    CASE WHEN chlvt.data_type = 'DATE'
                THEN TO_CHAR(TO_DATE(REPLACE(chlvt.low_date, ' '), 'YYYYMMDDHH24MISS'), 'MM/DD/YYYY hh24:mi:ss')
                WHEN chlvt.data_type = 'NUMBER'
                THEN LPAD(TO_CHAR(chlvt.low_num),20)
                WHEN chlvt.data_type LIKE '%CHAR%'
                THEN chlvt.low_char
           END low_value
      ,    CASE WHEN chlvt.data_type = 'DATE'
                THEN TO_CHAR(TO_DATE(REPLACE(chlvt.high_date, ' '), 'YYYYMMDDHH24MISS'), 'MM/DD/YYYY hh24:mi:ss')
                WHEN chlvt.data_type = 'NUMBER'
                THEN LPAD(TO_CHAR(chlvt.high_num),20)
                WHEN chlvt.data_type LIKE '%CHAR%'
                THEN chlvt.high_char
           END high_value           
FROM       dba_ind_columns ic
      ,    col_hi_lo_vals_translated chlvt
WHERE      ic.table_owner||'.'||ic.table_name = UPPER('&&owner_table')
  AND      ic.column_name = chlvt.column_name
ORDER BY   ic.index_name, ic.column_position
/

SPOOL off
