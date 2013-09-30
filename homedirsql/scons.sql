col type format a10
col cons_name format a30
col search_condition for a45 wrap
select  constraint_type,
        decode(constraint_type,
                'C', 'Check',
                'O', 'R/O View',
                'P', 'Primary',
                'R', 'Foreign',
                'U', 'Unique',
                'V', 'Check view') type
,       constraint_name cons_name
,       r_constraint_name
,       status
,       to_char(last_change, 'YYYYMONDD-HH24:MI')
,       search_condition
from    dba_constraints
where   table_name like '&table_name'
order by 1;
