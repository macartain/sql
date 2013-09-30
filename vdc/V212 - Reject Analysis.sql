-- Looking at the number of duplicates on the criteria are larger
select *
from ( select re.origin_major, count(*) numbr
       from rejectevent re
       where re.reject_status = 7
         and re.reject_code = 'RATE-19001'
       group by re.origin_major 
     ) ilv
where ilv.numbr > 2;


select *
from jobhasfile jhf
where jhf.managed_file_id in (
                           select ilv.origin_major
                           from ( select re.origin_major, count(*) numbr
                                  from rejectevent re
                                  where re.reject_status = 7
                                    and re.reject_code = 'RATE-19001'
                                  group by re.origin_major 
                                 ) ilv
                           where ilv.numbr > 2
                           );


-- Takes too long to run
select count(*)
from rejectevent re
  left join costedevent ce on
    ( ce.event_source = re.event_source and
      ce.event_type_id = re.event_type_id and
      ce.event_dtm = re.event_dtm )
where re.reject_status = 7
  and re.reject_code = 'RATE-19001'
  and trunc(re.event_dtm) = to_date('09/02/2007','DD/MM/YYYY')
--  and rownum <= 100
     