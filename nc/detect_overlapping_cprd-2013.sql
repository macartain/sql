create table cprd_check as 
select /*+ parallel(custprodratingdiscount,64) */ customer_ref, product_seq, event_discount_id,event_source,'PE' as status 
from custprodratingdiscount group by customer_ref, product_seq, event_discount_id,event_source
having count(1) > 1;
create index cprd_check_ak1 on cprd_check ( customer_ref, product_seq, event_discount_id,event_source);

declare
overlapcount number(5)    := 0;
lastcustref varchar2(20)  := null;
lastprodseq number(9)     := null;
lastevdiscid number(9)    := null;
lastevsource varchar2(40) := null;
updatecount number(9)     := 0;
begin
for rec in (select p.*
              from cprd_check c, custprodratingdiscount p
             where c.customer_ref = p.customer_Ref
               and c.product_seq = p.product_seq
               and c.event_discount_id = p.event_discount_id
               and c.event_source || 'xxx' = p.event_source || 'xxx'
               and c.status = 'PE'
             order by p.customer_Ref,
                      p.product_seq,
                      p.event_discount_id,
                      p.event_source,
                      p.start_dat
) loop
  if (lastcustref != rec.customer_Ref or 
      lastprodseq != rec.product_seq or
      lastevdiscid != rec.event_discount_id or
      lastevsource||'xxx' != rec.event_source||'xxx')
  then
    if updatecount > 100
      then
        commit;
        updatecount := 0;
    end if;
  end if;
  lastcustref  := rec.customer_Ref;
  lastprodseq  := rec.product_seq;
  lastevdiscid := rec.event_discount_id;
  lastevsource := rec.event_source;
  select count(1) 
  into overlapcount
  from custprodratingdiscount c 
  where c.customer_ref = rec.customer_Ref
    and c.product_seq = rec.product_seq
    and c.event_discount_id = rec.event_discount_id
    and c.event_source||'xxx' = rec.event_source||'xxx'
    and c.start_dat != rec.start_dat
    and rec.start_dat < c.start_dat
    and nvl(rec.end_dat,date '4000-01-01') > c.start_dat;
  if overlapcount = 0 then
    update cprd_check c set status = 'OK' 
    where c.customer_ref = rec.customer_Ref
    and c.product_seq = rec.product_seq
    and c.event_discount_id = rec.event_discount_id
    and c.event_source||'xxx' = rec.event_source||'xxx'
    and status = 'PE';
  else
    update cprd_check c set status = 'ER' 
    where c.customer_ref = rec.customer_Ref
    and c.product_seq = rec.product_seq
    and c.event_discount_id = rec.event_discount_id
    and c.event_source||'xxx' = rec.event_source||'xxx';
  end if;
  updatecount := updatecount+1;
end loop;
commit;
end;
/
