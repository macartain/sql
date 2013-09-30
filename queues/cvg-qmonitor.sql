select case rownum when 1 then 'Queue Head' end "Queue",
       case rownum when 1 then ilv1.tot_count end "Total Count",
       ilv2.msg_state "Message State",
       ilv2.state_count "State Count"
  from ( select count(*) tot_count
           from aq$costedeventqueuehead
        ) ilv1
       left join ( select msg_state,
                          count(*) state_count
                     from aq$costedeventqueuehead
                    group by msg_state
                    order by msg_state desc
                  ) ilv2
              on 1 = 1
 union all
select case rownum when 1 then 'Queue Tail' end "Queue",
       case rownum when 1 then ilv1.tot_count end "Count",
       ilv2.msg_state,
       ilv2.state_count
  from ( select count(*) tot_count
           from aq$costedeventqueuetail
        ) ilv1
       left join ( select msg_state,
                          count(*) state_count
                     from aq$costedeventqueuetail
                    group by msg_state
                    order by msg_state desc
                  ) ilv2
              on 1 = 1
 union all
select case rownum when 1 then 'Reject Head' end "Queue",
       case rownum when 1 then ilv1.tot_count end "Count",
       ilv2.msg_state,
       ilv2.state_count
  from ( select count(*) tot_count
           from aq$rejecteventqueuehead
        ) ilv1
       left join ( select msg_state,
                          count(*) state_count
                     from aq$rejecteventqueuehead
                    group by msg_state
                    order by msg_state desc
                  ) ilv2
              on 1 = 1
 union all
select case rownum when 1 then 'Reject Tail' end "Queue",
       case rownum when 1 then ilv1.tot_count end "Count",
       ilv2.msg_state,
       ilv2.state_count
  from ( select count(*) tot_count
           from aq$rejecteventqueuetail
        ) ilv1
       left join ( select msg_state,
                          count(*) state_count
                     from aq$rejecteventqueuetail
                    group by msg_state
                    order by msg_state desc
                  ) ilv2
              on 1 = 1;
