-- --------------------------------------------------------------------
-- Accounts that should bill - by billstyle
-- --------------------------------------------------------------------
select count(distinct(a.account_num)), ad.bill_style_id 
from account a, accountdetails ad, custproductdetails cpd 
where a.account_num = ad.account_num 
and a.billing_status='OK' 
and ad.end_dat is null 
and cpd.account_num=a.account_num 
and cpd.end_dat is  null 
group by ad.bill_style_id;

-- accounts by billstyle
select count(distinct(a.account_num)), ad.bill_style_id, bst.bill_style_name, bst.rating_only_boo
from account a
      join accountdetails ad on a.account_num = ad.account_num 
      join billstyle bst on bst.bill_style_id = ad.bill_style_id
where ad.end_dat is null 
group by ad.bill_style_id, bst.bill_style_name, bst.rating_only_boo;

-- --------------------------------------------------------------------
-- BS records grouped by billstyle
-- --------------------------------------------------------------------
select bs_cnt.bill_style_id, bst.bill_style_name,
       bs_cnt.the_cnt "Count",
       bst.rating_only_boo "Rate Only?"
  from ( select ad.bill_style_id, 
                count( bs.account_num ) the_cnt
           from billsummary bs
                join accountdetails ad 
                  on ad.account_num = bs.account_num
                 and ad.start_dat <= bs.bill_dtm
                 and ( ad.end_dat is null or ad.end_dat > bs.bill_dtm )
          group by ad.bill_style_id
          order by ad.bill_style_id
        ) bs_cnt
       join billstyle bst
         on bst.bill_style_id = bs_cnt.bill_style_id;

-- --------------------------------------------------------------------
-- Bill requests
-- --------------------------------------------------------------------
select br.account_num, br.request_seq, br.bill_dat, br.bill_seq, bt.bill_type_name,
    decode(br.bill_request_status,
            1, 'Created',
            2, 'Processed') BR_status 
from billrequest br
    join billtype bt on br.bill_type_id = bt.bill_type_id
order by br.account_num, br.request_seq, br.bill_dat;

-- --------------------------------------------------------------------
-- Unbilled usage
-- --------------------------------------------------------------------
select 'UNBILLED - ' || a.account_num as events, count(*) 
from costedevent c, account a
where a.account_num = c.account_num
and c.event_seq >= a.bill_event_seq
-- and a.ACCOUNT_NUM in ('0203132626', 'EA30186062')
group by a.account_num
union all
select 'BILLED - ' || a.account_num as events, count(*) 
from costedevent c, account a
where a.account_num = c.account_num
and c.event_seq < a.bill_event_seq
-- and a.ACCOUNT_NUM in ('A0000049130', 'A0000003201')
group by a.account_num;

-- all unbilled events
select /*+ parallel 8 */ count(*) 
from costedevent c
    join account a on a.account_num = c.account_num
where c.event_seq >= a.bill_event_seq;

-- --------------------------------------------------------------------
-- CDRs by month
-- --------------------------------------------------------------------
select substr(to_char(a.EVENT_DTM,'DD/MM/YYYY'),4,10), b.event_type_name, count(a.event_source) no_events 
from COSTEDEVENT a, EVENTTYPE b 
where a.EVENT_DTM >= to_date('01/10/2010','DD/MM/YYYY') 
and b.EVENT_TYPE_ID = a.EVENT_TYPE_ID 
group by substr(to_char(a.EVENT_DTM,'DD/MM/YYYY'),4,10), b.event_type_name
order by substr(to_char(a.EVENT_DTM,'DD/MM/YYYY'),4,10), b.event_type_name;

-- --------------------------------------------------------------------
-- BILLPRODUCTCHARGE
-- --------------------------------------------------------------------
select bpc.account_num, a.earliest_prod_change_dat, bpc.charge_start_dat,
    decode(nvl(bpc.charge_type, 0),
        0, 'NULL',
        1,'Initiation',
        2,'Periodic',
        3,'Termination',
        4,'Usage'
    ) charge_type, 
    bpc.charge_sub_type,
    decode(nvl(bpc.bpc_status, 0),
        1,     'Active',
        2,     'Implied active',
        3,     'Superseded active',
        4,     'Refunded',
        5,     'Cancelled',
        6,     'Superseded implied active'    
    ) bpc_status,
    count(*) 
from billproductcharge bpc
    join account a on a.account_num=bpc.account_num
where bpc.account_num='LN26327217'
group by bpc.account_num, a.earliest_prod_change_dat, bpc.charge_start_dat, bpc.charge_type, bpc.charge_sub_type, bpc_status
order by bpc.account_num, a.earliest_prod_change_dat, bpc.charge_start_dat, bpc.charge_type, bpc.charge_sub_type, bpc_status
;

-- --------------------------------------------------------------------
-- FORMATTINGREQUEST
-- --------------------------------------------------------------------
col account_num for a12
col request_type for a12
col REQUEST_STATUS for a16 trunc
col REQUEST_TYPE for a8 trunc
col ARCHIVE_STATUS for a27 trunc
col image_file_name for a32 trunc

select fr.account_num, fr.request_dtm, fr.image_file_name, f.formatter_name, fr.bill_data_ready_boo,
    decode(nvl(fr.request_status, 0), 
        '1',     'Created.',
        '2',     'On hold.',
        '3',     'Written to file.',
        '4',     'Processed.',
        '5',     'Bill Formatting Engine faulted.',
        '6',     'Bill Data Writer faulted.',
        '7',     'Subdocument.',
        '8',     'Being processed by BDW.'
        ) request_status,
    decode(nvl(fr.request_type, 0), 
        '1',     'Bill.',
        '2',     'Budget Center Report.',
        '3',     'Dunning',
        '4',     'Statement.'
        ) request_type,
    decode(nvl(fr.archive_status, 0),
        '0', 'Not archived or deleted (produced)', 
        '1',     'Archived (written to file).',
        '2',     'Deleted'
        ) archive_status,
     decode(nvl(fr.bill_purpose, 0),
        '1', 'Master bill', 
        '2',     'Copy bill',
        '3',     'Reissue'
        ) bill_purpose
from formattingrequest fr
    join formatter f on f.formatter_id=fr.formatter_id
-- where fr.account_num='0206650985'
order by fr.account_num, fr.request_dtm;

-- check BDD load
-- BAL
-- -------------------------------------------------------------------------------
-- - archive_type 1 = Bill data. 2 = Budget Center Report data. 3 = Statement.
-- - archive_bill_dat - The actual bill date of all data in this archive.
-- - archive_file_num - The number (sequence) of this archive file within all billing archive files.
-- - archive_instance_name - The name of the file containing this portion of the archive.
-- - archived_dtm - The date and time when this archive was produced (when the file was produced, not when it was exported).
-- - deleted_dtm - The date and time when this archive was deleted.
-- - deleter_pid - The UNIX process ID (pid) of the Bill Data Deleter process assigned to this record.

select /*+ parallel */ b.ARCHIVE_TYPE, to_char(b.ARCHIVE_BILL_DAT, 'YYYY-MM'), count(*) as bal_recs
from BILLARCHIVELOG b
where b.DELETED_DTM is NULL
group by b.ARCHIVE_TYPE, to_char(b.ARCHIVE_BILL_DAT, 'YYYY-MM')
order by b.ARCHIVE_TYPE, to_char(b.ARCHIVE_BILL_DAT, 'YYYY-MM'); 

select /*+ parallel */ to_char(f.REQUEST_DTM, 'YYYY-MM'), count(*) as f_reqs
from FORMATTINGREQUEST f
       join BILLARCHIVELOG b on f.ARCHIVE_NAME = b.ARCHIVE_INSTANCE_NAME
where b.DELETED_DTM is NULL
group by b.ARCHIVE_TYPE, to_char(f.REQUEST_DTM, 'YYYY-MM')
order by b.ARCHIVE_TYPE, to_char(f.REQUEST_DTM, 'YYYY-MM'); 

-- how many bills would BDD pick up for a given month (ignoring statuses)
select 'BILLS', count(*)
from formattingrequest fr
    join billdata b on fr.ACCOUNT_NUM=b.ACCOUNT_NUM
      and b.bill_seq=fr.bill_seq
 where fr.request_dtm between '01-JUL-2013' and '31-JUL-2013' 
union
select 'BCRS', count(*)
from formattingrequest fr
    join bcrdata b on fr.ACCOUNT_NUM=b.ACCOUNT_NUM
      and b.bcr_seq=fr.bcr_seq
 where fr.request_dtm between '01-JUL-2013' and '31-JUL-2013' ;

-- formatters
col FORMATTER_DESC for a30
col FORMATTER_TYPE for a30
col BILL_IMAGE_ROOT_DIR for a30
select FORMATTER_NAME, FORMATTER_DESC, FORMATTER_TYPE, BILL_IMAGE_ROOT_DIR from formatter;
    

