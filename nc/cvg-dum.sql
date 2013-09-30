-- --------------------------------------------------------------------
-- CP tables
-- -------------------------------------------------------------------- 
select *
  from CustProdRatingDiscount t
 where t.customer_ref = '368447'
   and t.product_seq=2
   and t.event_discount_id=4
;

select *
  from CustProductDiscountUsage t
 where t.customer_ref = '368447'
   and t.product_seq=2
   and t.event_discount_id=4
 order by t.period_num
;

select *
  from CustProdInvoiceDiscUsage t
 where t.customer_ref = '368447'
   and t.product_seq=2
   and t.event_discount_id=4
 order by t.period_num
;

-- --------------------------------------------------------------------
-- Orphaned records
-- --------------------------------------------------------------------
SELECT 'CPIDU without CPDU',
cpidu.customer_ref,cpidu.product_seq,cpidu.event_discount_id,cpidu.period_num
FROM custprodinvoicediscusage cpidu
LEFT
JOIN custproductdiscountusage cpdu
ON cpdu.customer_ref = cpidu.customer_ref
AND cpdu.product_seq = cpidu.product_seq
AND cpdu.event_discount_id = cpidu.event_discount_id
AND cpdu.period_num = cpidu.period_num
WHERE cpdu.customer_ref is null                                       

SELECT 'CPRD with no CPDU',
cprd.customer_ref,cprd.product_seq,cprd.event_discount_id,cprd.start_dtm
FROM custprodratingdiscount cprd
LEFT
JOIN custproductdiscountusage cpdu
ON cpdu.customer_ref = cprd.customer_ref
AND cpdu.product_seq = cprd.product_seq
AND cpdu.event_discount_id = cprd.event_discount_id
AND cpdu.period_start_dat >= cprd.start_dtm
AND TRUNC(cpdu.period_end_dat) <= cprd.extended_to_dat

-- --------------------------------------------------------------------
-- Query to check batch DUM is extending Discounts - March 2010
-- --------------------------------------------------------------------
with cat 
  as ( select gnvgen.liveBillingCatalogueID('ZAR') bill_ver 
         from dual
      )
SELECT /*+ ordered parallel(cprd) */
       cprd.event_discount_id, 
       ed.discount_name,
       cprd.next_allocation_dat,
       cprd.extended_to_dat, 
       COUNT(*)
  FROM ( SELECT ed1.event_discount_id,
                ed1.discount_name
           FROM cat
                JOIN eventdiscount ed1
                  ON ed1.catalogue_change_id = cat.bill_ver
          WHERE ed1.discount_period_units = 'M' -- Monthly Discounts Only
            AND ed1.keep_periods IS NULL        -- not include keep_periods discounts
            AND ed1.discount_type = 1           -- RTD's only (7 for UC)
        ) ed
       JOIN custprodratingdiscount cprd
         ON cprd.event_discount_id = ed.event_discount_id
 WHERE cprd.end_dat IS NULL
   AND CASE WHEN ( SELECT CASE WHEN ver.table_name is null 
                                    THEN 0
                                    ELSE 1
                          END irb_4_3
                     FROM dual
                          LEFT JOIN ( SELECT ut.table_name
                                        FROM user_tables ut
                                       WHERE ut.table_name = 'VERSION_RB_4_3'
                                     ) ver
                                 ON 1 = 1
                  ) = 1 
                 THEN cprd.next_allocation_dat -- IRB4.3
                 ELSE cprd.extended_to_dat --IRB3.0
       END < SYSDATE
 GROUP BY cprd.event_discount_id, 
          ed.discount_name, 
          cprd.next_allocation_dat, 
          cprd.extended_to_dat
 ORDER BY cprd.event_discount_id;


-- --------------------------------------------------------------------
-- Stuart's version - March 2010
-- --------------------------------------------------------------------

select ed.discount_name, d.extended_to_dat, count(d.customer_ref) 
	from custprodratingdiscount d
       inner join eventdiscount ed 
             on (ed.event_discount_id = d.event_discount_id
             and ed.catalogue_change_id = gnvgen.liveBillingCatalogueID('ZAR'))
where d.end_dat is null
group by 
      d.extended_to_dat,
      ed.discount_name;

-- --------------------------------------------------------------------
-- RTD scope spread
-- --------------------------------------------------------------------
col num for 999,999,999 
select /*+ parallel */ decode(nvl(rating_discount_scope, 0),
                 0, 'unset',
                 1, '1-NONE',
                 2, '2-PRODUCT',
                 3, '3-ACCOUNT',
                 4, '4-CUSTOMER',
                 5, '5-EVENT SOURCE',
                 6, '6-SUBSCRIPTION',
                 7, '7-PACKAGE'
                 ) rtd_scope, count(*) num
from ACCOUNTRATING
group by rating_discount_scope;

-- --------------------------------------------------------------------
-- Rerate requests
-- --------------------------------------------------------------------
select count(*), to_char(rerate_created_dtm, 'DDMONYYYY'),
decode(nvl(rerate_request_status, 0),
0, 'NULL - initial value',
1, '1-In pending',
2, '2-In progress (ready for unloading)',
3, '3-Unloading failed',
4, '4-In progress (ready for rerating)',
5, '5-Rerating failed',
6, '6-Completed',
7, '7-Canceled') rrstatus
 from reraterequest 
 group by rerate_request_status, to_char(rerate_created_dtm, 'DDMONYYYY')
 order by rerate_request_status;

-- --------------------------------------------------------------------
-- Problem CPDUs - duplicates with invalid period_nums
-- --------------------------------------------------------------------

select * from 
  ( select cpdu.customer_ref, cpdu.period_start_dat, cpdu.product_seq, cpdu.event_discount_id, cpdu.event_source,
           count (*) dups 
    from custproductdiscountusage cpdu 
    group by cpdu.customer_ref, cpdu.period_start_dat, cpdu.product_seq, cpdu.event_discount_id, cpdu.event_source
   ) 
where dups > 1;

-- --------------------------------------------------------------------
-- DUAD distribution over time vs account status
-- --------------------------------------------------------------------
select to_char(ar.discount_usage_action_dat, 'YYYY-MM'), ilv.account_status, count(1)  
from accountrating ar 
join  (       select account_num, account_status
                from ( select cs.account_num,
                            cs.account_status,
                            cs.effective_dtm,
                            row_number () over (partition by cs.account_num order by cs.effective_dtm desc) nth
                        from accountstatus cs
                    )
                where nth = 1) ilv 
        on ilv.account_num = ar.account_num
where ar.discount_usage_action_dat is not null
group by to_char(ar.discount_usage_action_dat, 'YYYY-MM'),  ilv.account_status
order by to_char(ar.discount_usage_action_dat, 'YYYY-MM'),  ilv.account_status;

-- --------------------------------------------------------------------
-- Discounts associated with a catalogue
-- --------------------------------------------------------------------
SELECT CPDU.CUSTOMER_REF,
       CPDU.ACCOUNT_NUM,
       CPDU.PRODUCT_SEQ,
       CPDU.EVENT_SOURCE,
       CPDU.EVENT_DISCOUNT_ID,
       CPRD.AGGREGATION_LEVEL,
       CPDU.DISCOUNT_FINISHED_BOO,
       CPDU.CATALOGUE_CURRENCY_CODE,
       CC.CATALOGUE_CHANGE_ID,
       CPRD.MAX_PERIOD_NUM,
       COUNT (DISTINCT ES.STEP_NUMBER) AS STEPS,
       p.product_name,
       ed.discount_name
  FROM PVCUSTPRODUCTDISCOUNTUSAGE5 CPDU,
       PVCATALOGUECHANGE3 CC,
       PVEVENTDISCOUNTSTEP6 ES,
       PVCUSTPRODRATINGDISCOUNT CPRD,
       custhasproduct chp,
       product p,
       eventdiscount ed
 WHERE CPDU.CUSTOMER_REF = 'LN26327217'
       AND CC.CATALOGUE_CHANGE_ID = 1687
       AND ES.EVENT_DISCOUNT_ID = CPDU.EVENT_DISCOUNT_ID
       AND ES.CATALOGUE_CHANGE_ID = CC.CATALOGUE_CHANGE_ID
       AND CPRD.CUSTOMER_REF = CPDU.CUSTOMER_REF
       AND CPRD.PRODUCT_SEQ = CPDU.PRODUCT_SEQ
       AND CPRD.EVENT_DISCOUNT_ID = CPDU.EVENT_DISCOUNT_ID
       AND (CPDU.EVENT_SOURCE IS NULL
            OR ( (CPDU.EVENT_SOURCE IS NOT NULL)
                AND (CPRD.EVENT_SOURCE = CPDU.EVENT_SOURCE)))
       AND CPDU.PERIOD_NUM = CPRD.MAX_PERIOD_NUM
       and chp.product_seq = cpdu.product_seq
       and chp.customer_ref = cpdu.customer_ref
       and p.product_id = chp.product_id
       and ed.event_discount_id=cpdu.event_discount_id
GROUP BY CPDU.CUSTOMER_REF,
       CPDU.ACCOUNT_NUM,
       CPDU.PRODUCT_SEQ,
       CPDU.EVENT_SOURCE,
       CPDU.EVENT_DISCOUNT_ID,
       CPRD.AGGREGATION_LEVEL,
       CPDU.DISCOUNT_FINISHED_BOO,
       CC.CATALOGUE_CHANGE_ID,
       CPDU.CATALOGUE_CURRENCY_CODE,
       CPRD.MAX_PERIOD_NUM,
       p.product_name,
       ed.discount_name; 
              