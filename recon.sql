set linesize 100
--set head off
set feed off pages 40
set trimspool on 
set numwidth 20 numformat 999,999,999,999,999,990.00
alter session set nls_date_format='YYYYMONDD HH24:MI:SS';
--alter session set db_file_multiblock_read_count=128

--set timing on
--spool data-recon.lst

PROMPT "Starting date and Time"
SELECT SYSDATE,host_name FROM v$instance;

PROMPT=====================================================<br>
PROMPT CHECK COUNTS ON GENEVA TABLES<br>
PROMPT=====================================================<br>

prompt Number of customers
select /*+ parallel_index(c,32) index_ffs(c,CUSTOMER_PK) */ count(*) from customer c;
prompt Number of accounts
select /*+ parallel_index(a,32) index_ffs(a,ACCOUNT_PK) */ count(*) from account a;


prompt Number of accounts by account status
SELECT /*+ parallel_index(a,32) index_ffs(a,ACCOUNT_PK) use_hash(a,b) full(b) parallel(b,32) */
       COUNT (*)
  FROM ACCOUNT a,
       (SELECT /*+ use_hash(b,c) parallel(b,32) parallel(c,32) full(b) full(c) */
               b.account_num, b.account_status
          FROM accountstatus b,
               (SELECT   /*+ parallel_index(acs_in,32) index_ffs(acs_in,ACCOUNTSTATUS_PK)  */
                         account_num, MAX (effective_dtm) max_effective_dtm
                    FROM accountstatus acs_in
                GROUP BY account_num) c
         WHERE b.account_num = c.account_num
           AND b.effective_dtm = c.max_effective_dtm) b
 WHERE a.account_num = b.account_num(+);

prompt  Number of accounts by Provider ID
SELECT   /*+ full(b) full(c) full(d) parallel(b,32) parallel(c,32) use_hash(d) use_hash(b) use_hash(c) */  COUNT (*) COUNT
    FROM ACCOUNT b, customer c, provider d
   WHERE b.customer_ref = c.customer_ref
   AND c.provider_id = d.provider_id(+);


prompt Number of accounts by Credit Class
SELECT   /*+ parallel(b,32) parallel(a,32) full(b) full(a) use_hash(b) use_hash(a) */ COUNT (*)
    FROM ACCOUNT a,
         (select /*+ parallel(b,32) parallel(d,32) full(b) full(d) full(c) use_hash(b) use_hash(d) use_hash(c) */ b.account_num,credit_class_name from
         accountdetails b,
         creditclass c,
         (SELECT   /*+ parallel_index(ACCOUNTDETAILS_PK,32) index_ffs(accdt,ACCOUNTDETAILS_PK) */
                   account_num, MAX (accdt.start_dat) max_start_dat
              FROM accountdetails accdt
             WHERE accdt.start_dat < SYSDATE
          GROUP BY account_num) d
     where b.credit_class_id = c.credit_class_id
     AND b.account_num = d.account_num
     AND b.start_dat = max_start_dat) b
WHERE a.account_num = b.account_num(+);


prompt Number of accounts by Payment Method
SELECT   /*+ parallel(b,32) parallel(a,32) full(b) full(a) use_hash(b) use_hash(a) */  COUNT (*)
    FROM ACCOUNT a,
         (select /*+ use_hash(b) use_hash(c) use_hash(d) full(b) full(c) full(d) parallel(b,32) parallel(d,32) */ d.account_num from
         accountdetails b,
         paymentmethod c,
         (SELECT   /*+ parallel_index(ACCOUNTDETAILS_PK,32) index_ffs(accdt,ACCOUNTDETAILS_PK) */
                   account_num, MAX (accdt.start_dat) max_start_dat
              FROM accountdetails accdt
             WHERE accdt.start_dat < SYSDATE
          GROUP BY account_num) d
     where b.PAYMENT_METHOD_ID = c.PAYMENT_METHOD_ID
     AND b.account_num = d.account_num
     AND b.start_dat = max_start_dat) b
WHERE a.account_num = b.account_num(+);

prompt Number of products
select count(*) Count
from product d, productfamily e
where d.PRODUCT_FAMILY_ID = e.PRODUCT_FAMILY_ID;

prompt Number of discount buckets
select /*+ parallel(b,32) parallel(a,32) full(b) full(a) use_hash(b) use_hash(a) */ count(*) "No_of_discounts" from CustProdRatingDiscount a,customer b
where a.customer_ref = b.customer_ref;

prompt Number of bills
SELECT /*+ parallel_index(BILLSUMMARY_PK,32) index_ffs(a,BILLSUMMARY_PK) parallel_index(ACCOUNT_PK,32) index_ffs(b,ACCOUNT_PK) use_hash(a) use_hash(b) */
       COUNT (*)
  FROM billsummary a, ACCOUNT b
 WHERE a.account_num = b.account_num;

prompt Number of Billed Adjustments by status (excluding cancelled and rejected)
SELECT /*+ full(a) full(b) use_hash(a) use_hash(b) parallel(a,32) parallel(b,32) */ COUNT (*)
    FROM adjustment a, account b
    where a.account_num = b.account_num
    and bill_seq is not null
    and a.adjustment_status not in (2,4);

prompt Number of Unbilled Adjustments by status (excluding cancelled and rejected)
SELECT  /*+ full(a) full(b) use_hash(a) use_hash(b) parallel(a,32) parallel(b,32) */ COUNT (*)
    FROM adjustment a, account b
    where a.account_num = b.account_num
    and bill_seq is null
    and a.adjustment_status not in (2,4);

prompt Number of disputes by status
SELECT  /*+ full(a) full(b) use_hash(a) use_hash(b) parallel(a,32) parallel(b,32) */ COUNT (*)
    FROM dispute a, account b
    where a.account_num = b.account_num;

--prompt Total unbilled/unbilled revenue as per event data
------------------------------
--SELECT /*+ ordered parallel(b,4) parallel(a,4) index_ffs(b) */ SUM (CASE
--               WHEN b.event_seq < a.bill_event_seq
--                  THEN  event_cost_mny
--               ELSE 0
--            END) /1000 Unbilled_Revenue_Amount ,
--       SUM (CASE
--               WHEN b.event_seq >= a.bill_event_seq
--                  THEN  event_cost_mny
--               ELSE 0
--            END)/1000 Billed_Revenue_Amount, sum (event_cost_mny)/1000 total_value
--  FROM ACCOUNT a, costedevent b
--WHERE a.account_num = b.account_num
--and  revenue_code_id is not null
--and a.random_hash > 0;
-------------------------------

--prompt GBSF Volume in queues
--select QUEUE,  count(*) from gbsf.aq$service_requests_qtab
--group by rollup(QUEUE)
--order by queue;

prompt Total billed revenue from billdetails

select /*+ full(a) full(b) use_hash(a) use_hash(b) parallel(a,32) parallel(b,32) */
sum(nvl( revenue_mny,0))/1000 "Billed Revenue Amount"
from billdetails a, account b
WHERE a.account_num = b.account_num
and  revenue_code_id is not null
and revenue_start_dat >= to_date('01-Jan-2010','dd-mon-yyyy');

prompt Payment information from 1st Jan 2010
SELECT /*+ full(a) full(b) use_hash(a) use_hash(b) parallel(a,32) parallel(b,32) */
SUM (physical_payment_mny) / 1000 payment_amount
    FROM physicalpayment a, customer b
   WHERE a.customer_ref = b.customer_ref
     AND physical_payment_dat >= TO_DATE ('01-Jan-2010', 'dd-mon-yyyy');


prompt Debt levels per account type
select /*+ full(a) full(b) full(c) full(h) use_hash(a) use_hash(b) use_hash(h) use_hash(c) parallel(a,32) parallel(b,32) */
count(*)
from AccDebtBandSummary a, account b, DebtAgeBand c,accountattributes h
WHERE a.account_num = b.account_num
and a.account_num = h.account_num
and A.DEBT_AGE_THRESHOLD = C.DEBT_AGE_THRESHOLD;

prompt Billed revenues since 1st Jan by account type
select /*+ full(a) full(b) full(h) use_hash(a) use_hash(b) use_hash(h) parallel(a,32) parallel(b,32) parallel(h,32) */
sum(nvl( revenue_mny,0))/1000
"Billed Revenue Amount"
from billdetails a, account b,accountattributes h
WHERE a.account_num = b.account_num
AND a.account_num = h.account_num
and  revenue_code_id is not null
and revenue_start_dat >= to_date('01-Jan-2010','dd-mon-yyyy');

prompt Unbilled revenues per account type
SELECT /*+ full(a) full(b) full(h) use_hash(a) use_hash(b) use_hash(h) parallel(a,32) parallel(b,32) parallel(h,32) */
SUM (a.rated_event_mny)/1000 unbilled_event_mny
    FROM accountratingsummary a, ACCOUNT b,accountattributes h
   WHERE a.account_num = b.account_num
   and a.account_num = h.account_num
     AND (   a.event_seq >= b.bill_event_seq
          OR a.event_seq = -1
         );

prompt Payments made since 1st Jan by account type
SELECT /*+ full(a) full(b) full(c) use_hash(a) use_hash(b) use_hash(c) parallel(a,32) parallel(b,32) parallel(c,32) */
SUM (account_payment_mny) / 1000 Account_payment_amount
    FROM accountpayment a, ACCOUNT b, accountattributes c
   WHERE a.account_num = b.account_num
     AND a.account_num = c.account_num
     AND account_payment_dat >= TO_DATE ('01-Jan-2010', 'dd-mon-yyyy')
     AND account_payment_status = 1;

prompt Accounts by Bill Style
select /*+ full(a) full(b) full(c) use_hash(a) use_hash(b) use_hash(c) parallel(b,32) parallel(c,32) */
count(*)
from BillStyle a, AccountDetails b, account c
where A.BILL_STYLE_ID(+) = b.bill_style_id
and b.account_num = c.account_num
and ( b.end_dat is null or b.end_dat > sysdate)
and b.start_dat < sysdate;

prompt Accounts by Bill Handling Code
select /*+ full(a) full(b) full(c) use_hash(a) use_hash(b) use_hash(c) parallel(b,32) parallel(c,32) */
count(*) from BillHandlingCode a, AccountDetails b, account c
where A.bill_handling_code(+) = b.bill_handling_code
and b.account_num = c.account_num
and ( b.end_dat is null or b.end_dat > sysdate)
and b.start_dat < sysdate;

Prompt Accounts by Payment method and status
SELECT  payment_method_name
         || ' ('
         || mandate_status
         || ')',
         count1
    FROM (SELECT /*+ full(a) full(b) full(c) use_hash(a) use_hash(b) use_hash(c) */
               c.payment_method_name,
                   DECODE (b.mandate_status,
                           1, 'Pending',
                           2, 'Active',
                           3, 'Used',
                           4, 'One-time',
                           5, 'Expired',
                           'Unknown status ' || b.mandate_status
                          ) mandate_status,
                   COUNT (*) count1
              FROM ACCOUNT a, prmandate b, paymentmethod c
             WHERE a.account_num = b.account_num(+)
               AND b.payment_method_id = c.payment_method_id
          GROUP BY  payment_method_name,
                    DECODE (b.mandate_status,
                            1, 'Pending',
                            2, 'Active',
                            3, 'Used',
                            4, 'One-time',
                            5, 'Expired',
                            'Unknown status ' || b.mandate_status
                           )
                   )
ORDER BY 1, 2;

prompt Unallocated Payments
select /*+ full(a) full(b) full(c) use_hash(a) use_hash(b) use_hash(c) parallel(b,32) parallel(c,32) */
sum( account_payment_mny) / 1000
from accountpayment a, account b,accountattributes c
where a.account_num = b.account_num
and a.account_num = c.account_num
--and account_payment_dat >= to_date('01-Jan-2010','dd-mon-yyyy')
and account_payment_status = 1
and (a.account_num, a.account_payment_seq) not in (
--select account_num, account_payment_seq from AccountPayment
--minus
select account_num, account_payment_seq from AllocationToBill);

prompt Number of credit classes
select count(*) from CreditClass;

prompt Rejected Events (REM) volumes
select /*+ full(rejectevent) parallel(rejectevent,32) */ decode(reject_status ,1,'Rejected.',
                 2,'Pending.' ,
                 3,'Post internal.',
                 4,'Post uncosted.',
                 5,'Discarded.',
                 6,'Processed.',
                 7,'Filtered. ',
                 'Unknown '|| reject_status) reject_status, count(*) from rejectevent
group by rollup(reject_status )
order by 1;

-- prompt Number of live users with permission id
-- SELECT e.geneva_user_ora,b.permission_name, a.permission_id,
--        d.business_role_name
--   FROM businessrolehaspermission a,
--        permission b,
 --       genevauserhasbusinessrole c,
 -- --       businessrole d,
--        genevauser e
--  WHERE b.permission_id = a.permission_id
--    AND a.business_role_id = d.business_role_id
--    AND d.business_role_id = c.business_role_id
--    AND c.geneva_user_ora = e.geneva_user_ora
--    order by 1,3,4;

prompt Last process run Started on
select /*+ parallel(a,4) */count(*), max(START_DTM) from ProcessInstancelog a;

prompt Last audit done
select /*+ parallel(a,64) */ count(*), max(TRANSACTION_DTM) from AuditTrail a;

prompt Direct count for accoount/customer
select /*+ parallel(a,64) */ 'BILLDETAILS',count(*) from BILLDETAILS a;
select /*+ parallel(a,64) */ 'BILLEVENTSUMMARY',count(*) from BILLEVENTSUMMARY a;
select /*+ parallel(a,64) */ 'BILLPRODUCTCHARGE',count(*) from BILLPRODUCTCHARGE a;
select /*+ parallel(a,64) */ 'CANCELBILLCUSTPC',count(*) from CANCELBILLCUSTPC a;
select /*+ parallel(a,64) */ 'CPDUMANAGEREQUEST',count(*) from CPDUMANAGEREQUEST a;
select /*+ parallel(a,64) */ 'CUSTPRODUCTCHARGE',count(*) from CUSTPRODUCTCHARGE a;
select /*+ parallel(a,64) */ 'DEBTESCALATIONREQUEST', count(*) from DEBTESCALATIONREQUEST a;
select /*+ parallel(a,64) */ 'EVENTSOURCEUSAGE',count(*) from EVENTSOURCEUSAGE a;
select /*+ parallel(a,64) */ 'FORMATTINGREQUEST', count(*) from FORMATTINGREQUEST a;
select /*+ parallel(a,64) */ 'ACCHASEVENTSUMMARY',count(*) from ACCHASEVENTSUMMARY a;
select /*+ parallel(a,64) */ 'BILLSUMMARY', count(*) from BILLSUMMARY a;
select /*+ parallel(a,64) */ 'CUSTEVENTSOURCE', count(*) from CUSTEVENTSOURCE a;
select /*+ parallel(a,64) */ 'CUSTHASPRODUCT', count(*) from CUSTHASPRODUCT a;
select /*+ parallel(a,64) */ 'CUSTOVERRIDEPRICE', count(*) from CUSTOVERRIDEPRICE a;
select /*+ parallel(a,64) */ 'CUSTPRODUCTATTRDETAILS', count(*) from CUSTPRODUCTATTRDETAILS a;
select /*+ parallel(a,64) */ 'CUSTPRODUCTDETAILS', count(*) from CUSTPRODUCTDETAILS a;
select /*+ parallel(a,64) */ 'CUSTPRODUCTEVENTTYPES', count(*) from CUSTPRODUCTEVENTTYPES a;
select /*+ parallel(a,64) */ 'CUSTPRODUCTSTATUS' , count(*) from CUSTPRODUCTSTATUS a;
SELECT /*+ parallel(a,64) */ 'CUSTPRODUCTTARIFFDETAILS', COUNT (*)FROM custproducttariffdetails a;

prompt Size of GENEVA_ADMIN tables
SELECT segment_name AS "TABLE", ROUND (BYTES / 1024 / 1024, 2) AS "Size(MB)"
  FROM dba_segments
 WHERE owner = 'GENEVA_ADMIN'
   AND segment_name IN
          ('BILLDETAILS', 'BILLEVENTSUMMARY', 'BILLPRODUCTCHARGE',
           'CANCELBILLCUSTPC', 'CPDUMANAGEREQUEST', 'CUSTPRODUCTCHARGE',
           'DEBTESCALATIONREQUEST', 'EVENTSOURCEUSAGE', 'FORMATTINGREQUEST',
           'ACCHASEVENTSUMMARY', 'BILLSUMMARY', 'CUSTEVENTSOURCE',
           'CUSTHASPRODUCT', 'CUSTOVERRIDEPRICE', 'CUSTPRODUCTATTRDETAILS',
           'CUSTPRODUCTDETAILS', 'CUSTPRODUCTEVENTTYPES', 'CUSTPRODUCTSTATUS',
           'CUSTPRODUCTTARIFFDETAILS')
order by 1  ;

PROMPT "End date and Time"
SELECT SYSDATE FROM DUAL;

spool off

-- HOST mv Data_reconciliation.lst Data_reconciliation_`date "+%m%d_%H%M"`.lst

exit















