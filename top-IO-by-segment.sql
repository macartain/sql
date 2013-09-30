set lines 200
set pages 200
col value for 999,999,999,999.99
col STATISTIC_NAME for a15
col OWNER for a12
col OBJECT_TYPE for a10

select *
from
  (select statistic_name,
     st.owner,
     st.obj#,
     st.object_type,
     st.object_name,
     st.value,
     dense_rank() over(partition by statistic_name
   order by st.value desc) rnk
   from v$segment_statistics st)
where rnk <= 10
 and statistic_name in ('logical reads', 'physical reads');
 