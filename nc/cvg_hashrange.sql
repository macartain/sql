-- --------------------------------------------------------------------
-- Domain spread
-- --------------------------------------------------------------------
define Range= 1000000000
define Segments=10

select Ranges.LowerBound,
       Ranges.UpperBound,
       count(*) RangeCount
  from ( select sum( SegmentSize ) over ( order by rownum ) - SegmentSize + 1 LowerBound,
                sum( SegmentSize ) over ( order by rownum ) UpperBound       
           from ( select case when rownum <= mod ( &Range, &Segments )
                              then floor( &Range / &Segments ) + 1
                              else floor( &Range / &Segments )
                          end SegmentSize
                    from dual
                  connect by rownum <= &Segments
                 )
        ) Ranges
       -- For other tables just change this join...
       join customer c
         on c.domain_id >= Ranges.LowerBound
        and c.domain_id <= Ranges.UpperBound
 group by Ranges.LowerBound,
          Ranges.UpperBound
 order by Ranges.LowerBound;

-- --------------------------------------------------------------------
-- Random hash spread
-- --------------------------------------------------------------------
 define Range= 1000000
 define Segments=10
 
 select Ranges.LowerBound,
        Ranges.UpperBound,
        count(*) RangeCount
   from ( select sum( SegmentSize ) over ( order by rownum ) - SegmentSize + 1 LowerBound,
                 sum( SegmentSize ) over ( order by rownum ) UpperBound       
            from ( select case when rownum <= mod ( &Range, &Segments )
                               then floor( &Range / &Segments ) + 1
                               else floor( &Range / &Segments )
                           end SegmentSize
                     from dual
                   connect by rownum <= &Segments
                  )
         ) Ranges
        -- For other tables just change this join...
        join customer t
          on t.RANDOM_HASH >= Ranges.LowerBound
         and t.RANDOM_HASH <= Ranges.UpperBound
  group by Ranges.LowerBound,
           Ranges.UpperBound
 order by Ranges.LowerBound;
 
-- --------------------------------------------------------------------
-- Lost entries
-- --------------------------------------------------------------------
select /*+ parallel(32) */ count(*) 
from CustProductDiscountUsage 
where RANDOM_HASH>1000000 
or RANDOM_HASH=0 
or RANDOM_HASH is null;
 
-- --------------------------------------------------------------------
-- Invert hash entries
-- --------------------------------------------------------------------
update account a set a.random_hash = 0 - a.random_hash 
	where a.account_num in
	(select tacc.account_num from terminatedaccounts tacc);

update account a set a.random_hash = 0 - a.random_hash 
	where a.random_hash < 0;