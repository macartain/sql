REM (c) 2007, Convergys Information Management Group Inc. All Rights Reserved. 
REM           Private and Confidential. May not be disclosed without permission.
REM
REM  Date:  30 July 2007
REM
REM  Version: Schema 5.4P (for Infinys IRB 2.2.9)
REM
REM  Purpose: Reset sequence numbers after import

set heading off
prompt
prompt Please wait ... Resetting relevant geneva_admin sequences.
prompt
set feed off
set verify off
set echo off
set lines 500
set pages 0
set termout off
spool /tmp/run_reset_gnv_seq.sql
-- -----------------------------------------------------------------
-- Not covered:
--     ACCOUNTNUMSEQ (should be max of account_num in account - partial field?)
--     CUSTOMERREFSEQ (should be max of customer_ref in customer - partial field?)
--     DLFBATCHSEQ
--     RTFFILEGROUPSEQ
--     ECAINCIDENTGROUPSEQ (record from source instance)
-- Not in doc and not below:
--     HYBRIDBALANCESYNCIDSEQ
--     HYBRIDCUSTDATASYNCIDSEQ
--     INACTIONSEQ
--     PENDINGHYBRIDDATASYNCIDSEQ
--     RATERDATASEQ
--
-- Reset sequence AEGSEQ
-- 
prompt drop sequence AEGSEQ;;
select 'create sequence AEGSEQ increment by 1 start with '||
	(1+NVL(max(accruals_extract_id),0))
	|| ' nomaxvalue nocache;' from ACCRUALSEXTRACT;
--
-- Reset sequence AUTHCODESEQ
-- 
prompt drop sequence AUTHCODESEQ;;
select 'create sequence AUTHCODESEQ increment by 1 start with '||
	(1+NVL(max(RESERVATION_IDENTIFIER),0))
	|| ' nomaxvalue nocache;' from EVENTRESERVATION;
-- select 'create sequence AUTHCODESEQ increment by 1 start with '||
-- 	(1+NVL(max(AUTHORISATION_CODE),0))
-- 	|| ' nomaxvalue nocache;' from REJECTEVENT;
--
-- Reset sequence BALANCEIDSEQ
--
prompt drop sequence BALANCEIDSEQ;;
select 'create sequence BALANCEIDSEQ increment by 1 start with '||
	(1+NVL(max(EXTERNAL_BALANCE_LIID),0))
	|| ' nomaxvalue nocache;' from CUSTPRODRATINGDISCOUNT;
--
-- Reset sequence BANDINGMODELIDSEQ
-- 
prompt drop sequence BANDINGMODELIDSEQ;;
select 'create sequence BANDINGMODELIDSEQ increment by 1 start with '||
	(1+NVL(max(BANDING_MODEL_ID),0))
	|| ' nomaxvalue nocache;' from BANDINGMODEL;
--
-- Reset sequence BATCHIDSEQ
-- 
prompt drop sequence BATCHIDSEQ;;
select 'create sequence BATCHIDSEQ increment by 1 start with '||
	(1+NVL(max(BATCH_ID),0))
	|| ' nomaxvalue nocache;' from PAYMENTBATCH;  
--
-- Reset sequence BILLDISCOUNTIDSEQ
-- 
prompt drop sequence BILLDISCOUNTIDSEQ;;
select 'create sequence BILLDISCOUNTIDSEQ increment by 1 start with '||
	(1+NVL(max(BILL_DISCOUNT_ID),0))
	|| ' nomaxvalue nocache;' from BILLDISCOUNT;  
--
-- Reset sequence BILLINGARCHIVEFILENUMSEQ
-- 
prompt drop sequence BILLINGARCHIVEFILENUMSEQ;;
select 'create sequence BILLINGARCHIVEFILENUMSEQ increment by 1 start with '||
	(1+NVL(max(ARCHIVE_FILE_NUM),0))
	|| ' nomaxvalue nocache;' from BILLARCHIVELOG;  
--
-- Reset sequence BILLINGCONFLICTSEQ
--
prompt drop sequence BILLINGCONFLICTSEQ;;
select 'create sequence BILLINGCONFLICTSEQ increment by 1 start with '||
	(1+NVL(max(BILLINGCONFLICT_NUM),0))
	|| ' nomaxvalue nocache;' from BILLINGCONFLICT;
--
-- Reset sequence BILLINGEDITSEQ
--
prompt drop sequence BILLINGEDITSEQ;;
select 'create sequence BILLINGEDITSEQ increment by 1 start with '||
	(1+NVL(max(BILLINGEDIT_NUM),0))
	|| ' nomaxvalue nocache;' from BILLINGEDIT;
--
-- Reset sequence BILLINGEXPORTSEQ
--
prompt drop sequence BILLINGEXPORTSEQ;;
select 'create sequence BILLINGEXPORTSEQ increment by 1 start with '||
	(1+NVL(max(BILLINGEXPORT_ID),0))
	|| ' nomaxvalue nocache;' from BILLINGEXPORT;
--
-- Reset sequence BILLINGIMPORTSEQ
--
prompt drop sequence BILLINGIMPORTSEQ;;
select 'create sequence BILLINGIMPORTSEQ increment by 1 start with '||
	(1+NVL(max(BILLINGIMPORT_ID),0))
	|| ' nomaxvalue nocache;' from BILLINGIMPORT;
--
-- Reset sequence BONUSSCHEMEIDSEQ
-- 
prompt drop sequence BONUSSCHEMEIDSEQ;;
select 'create sequence BONUSSCHEMEIDSEQ increment by 1 start with '||
	(1+NVL(max(BONUS_SCHEME_ID),0))
	|| ' nomaxvalue nocache;' from BONUSSCHEME; 
--
-- Reset sequence BUDGETPAYPLANIDSEQ
-- 
prompt drop sequence BUDGETPAYPLANIDSEQ;;
select 'create sequence BUDGETPAYPLANIDSEQ increment by 1 start with '||
	(1+NVL(max(BUDGET_PAYMENT_PLAN_ID),0))
	|| ' nomaxvalue nocache;' from BUDGETPAYMENTPLAN; 
--
-- Reset sequence CCMANDATESEQ
-- 
prompt drop sequence CCMANDATESEQ;;
select 'create sequence CCMANDATESEQ increment by 1 start with '||
	(1+NVL(max(substr(mandate_ref,2,9)),0))
	|| ' nomaxvalue nocache;' from PRMANDATE
  where payment_method_id in (select payment_method_id from paymentmethod
                            where payment_picklist_boo = 'F');
--
-- Reset sequence CHARGESEGMENTIDSEQ
-- 
prompt drop sequence CHARGESEGMENTIDSEQ;;
select 'create sequence CHARGESEGMENTIDSEQ increment by 1 start with '||
	(1+NVL(max(CHARGE_SEGMENT_ID),0))
	|| ' nomaxvalue nocache;' from CHARGESEGMENT;  
--
-- Reset sequence COMPOSITEFILTERIDSEQ
-- 
prompt drop sequence COMPOSITEFILTERIDSEQ;;
select 'create sequence COMPOSITEFILTERIDSEQ increment by 1 start with '||
	(1+NVL(max(COMPOSITE_FILTER_ID),0))
	|| ' nomaxvalue nocache;' from COMPOSITEFILTER; 
--
-- Reset sequence COSTBANDIDSEQ
-- 
prompt drop sequence COSTBANDIDSEQ;;
select 'create sequence COSTBANDIDSEQ increment by 1 start with '||
	(1+NVL(max(COST_BAND_ID),0))
	|| ' nomaxvalue nocache;' from COSTBAND; 
--
-- Reset sequence COSTGROUPIDSEQ
-- 
prompt drop sequence COSTGROUPIDSEQ;;
select 'create sequence COSTGROUPIDSEQ increment by 1 start with '||
	(1+NVL(max(COSTGROUP_ID),0))
	|| ' nomaxvalue nocache;' from COSTGROUP;  
--
-- Reset sequence COSTINGRULESIDSEQ
-- 
prompt drop sequence COSTINGRULESIDSEQ;;
select 'create sequence COSTINGRULESIDSEQ increment by 1 start with '||
	(1+NVL(max(COSTING_RULES_ID),0))
	|| ' nomaxvalue nocache;' from COSTINGRULES;      
--
-- Reset sequence DDMANDATESEQ
-- 
prompt drop sequence DDMANDATESEQ;;
select 'create sequence DDMANDATESEQ increment by 1 start with '||
	(1+NVL(max(substr(mandate_ref,2,9)),0))
	|| ' nomaxvalue nocache;' from PRMANDATE
  where payment_method_id in (select payment_method_id from paymentmethod
                            where payment_picklist_boo = 'T');  
--
-- Reset sequence DUNNINGARCHIVEFILENUMSEQ
-- 
prompt drop sequence DUNNINGARCHIVEFILENUMSEQ;;
select 'create sequence DUNNINGARCHIVEFILENUMSEQ increment by 1 start with '||
	(1+NVL(max(archive_file_num),0))
	|| ' nomaxvalue nocache;' from DUNNINGARCHIVELOG;
--
-- Reset sequence EVENTCLASSIDSEQ
-- 
prompt drop sequence EVENTCLASSIDSEQ;;
select 'create sequence EVENTCLASSIDSEQ increment by 1 start with '||
	(1+NVL(max(event_class_id),0))
	|| ' nomaxvalue nocache;' from EVENTCLASS;  
--
-- Reset sequence EVENTDISCOUNTIDSEQ
-- 
prompt drop sequence EVENTDISCOUNTIDSEQ;;
select 'create sequence EVENTDISCOUNTIDSEQ increment by 1 start with '||
	(1+NVL(max(event_discount_id),0))
	|| ' nomaxvalue nocache;' from EVENTDISCOUNT;  
--
-- Reset sequence EVENTFILTERIDSEQ
-- 
prompt drop sequence EVENTFILTERIDSEQ;;
select 'create sequence EVENTFILTERIDSEQ increment by 1 start with '||
	(1+NVL(max(event_filter_id),0))
	|| ' nomaxvalue nocache;' from EVENTFILTER;  
--
-- Reset sequence JOBIDSEQ
-- 
prompt drop sequence JOBIDSEQ;;
select 'create sequence JOBIDSEQ increment by 1 start with '||
	(1+NVL(max(job_id),0))
	|| ' nomaxvalue nocache;' from JOB;
--
-- Reset sequence LOCKVERSIONSEQ
--
prompt drop sequence LOCKVERSIONSEQ;;
select 'create sequence LOCKVERSIONSEQ increment by 1 start with '||
	(1+NVL(max(ACCOUNT_LOCK_VERSION),0))
	|| ' nomaxvalue nocache;' from ACCOUNT;
--
-- Reset sequence MANAGEDFILEIDSEQ
-- 
prompt drop sequence MANAGEDFILEIDSEQ;;
select 'create sequence MANAGEDFILEIDSEQ increment by 1 start with '||
	(1+NVL(max(managed_file_id),0))
	|| ' nomaxvalue nocache;' from MANAGEDFILE;
--
-- Reset sequence MODIFIERGROUPIDSEQ
-- 
prompt drop sequence MODIFIERGROUPIDSEQ;;
select 'create sequence MODIFIERGROUPIDSEQ increment by 1 start with '||
	(1+NVL(max(modifier_group_id),0))
	|| ' nomaxvalue nocache;' from MODIFIERGROUP;  
--
-- Reset sequence MODIFIERIDSEQ
--
prompt drop sequence MODIFIERIDSEQ;;
select 'create sequence MODIFIERIDSEQ increment by 1 start with '||
	(1+NVL(max(MODIFIER_ID),0))
	|| ' nomaxvalue nocache;' from MODIFIER;
--
-- Reset sequence PACKAGEIDSEQ
-- 
prompt drop sequence PACKAGEIDSEQ;;
select 'create sequence PACKAGEIDSEQ increment by 1 start with '||
	(1+NVL(max(package_id),0))
	|| ' nomaxvalue nocache;' from PACKAGE;   
--
-- Reset sequence PAYREQIDSEQ
-- 
prompt drop sequence PAYREQIDSEQ;;
select 'create sequence PAYREQIDSEQ increment by 1 start with '||
	(1+NVL(max(payment_req_id),0))
	|| ' nomaxvalue nocache;' from PAYMENTREQUEST;  
--
-- Reset sequence PAYSETTLEMENTACTIONSEQ
-- 
prompt drop sequence PAYSETTLEMENTACTIONSEQ;;
select 'create sequence PAYSETTLEMENTACTIONSEQ increment by 1 start with '||
	(1+NVL(max(update_seq),0))
	|| ' nomaxvalue nocache;' from PAYSETTLEMENTACTION; 
--
-- Reset sequence PROCESSIDSEQ
-- 
prompt drop sequence PROCESSIDSEQ;;
select 'create sequence PROCESSIDSEQ increment by 1 start with '||
	(1+NVL(max(process_id),0))
	|| ' nomaxvalue nocache;' from PROCESSLOG;
--
-- Reset sequence PROCESSINSTANCEIDSEQ
-- 
prompt drop sequence PROCESSINSTANCEIDSEQ;;
select 'create sequence PROCESSINSTANCEIDSEQ increment by 1 start with '||
	(1+NVL(max(process_instance_id),0))
	|| ' nomaxvalue nocache;' from PROCESSINSTANCELOG;
--
-- Reset sequence PRODUCTATTRIBUTEIDSEQ
-- 
prompt drop sequence PRODUCTATTRIBUTEIDSEQ;;
select 'create sequence PRODUCTATTRIBUTEIDSEQ increment by 1 start with '||
	(1+NVL(max(product_attribute_subid),0))
	|| ' nomaxvalue nocache;' from PRODUCTATTRIBUTE;  
--
-- Reset sequence PRODUCTCONFLICTSEQ
--
prompt drop sequence PRODUCTCONFLICTSEQ;;
select 'create sequence PRODUCTCONFLICTSEQ increment by 1 start with '||
	(1+NVL(max(PRODUCTCONFLICT_NUM),0))
	|| ' nomaxvalue nocache;' from PRODUCTCONFLICT;
--
-- Reset sequence PRODUCTEDITSEQ
--
prompt drop sequence PRODUCTEDITSEQ;;
select 'create sequence PRODUCTEDITSEQ increment by 1 start with '||
	(1+NVL(max(PRODUCTEDIT_NUM),0))
	|| ' nomaxvalue nocache;' from PRODUCTEDIT;
--
-- Reset sequence PRODUCTEXPORTSEQ
--
prompt drop sequence PRODUCTEXPORTSEQ;;
select 'create sequence PRODUCTEXPORTSEQ increment by 1 start with '||
	(1+NVL(max(PRODUCTEXPORT_ID),0))
	|| ' nomaxvalue nocache;' from PRODUCTEXPORT;
--
-- Reset sequence PRODUCTFAMILYIDSEQ
-- 
prompt drop sequence PRODUCTFAMILYIDSEQ;;
select 'create sequence PRODUCTFAMILYIDSEQ increment by 1 start with '||
	(1+NVL(max(product_family_id),0))
	|| ' nomaxvalue nocache;' from PRODUCTFAMILY;    
--
-- Reset sequence PRODUCTIDSEQ
-- 
prompt drop sequence PRODUCTIDSEQ;;
select 'create sequence PRODUCTIDSEQ increment by 1 start with '||
	(1+NVL(max(product_id),0))
	|| ' nomaxvalue nocache;' from PRODUCT;    
--
-- Reset sequence PRODUCTIMPORTSEQ
--
prompt drop sequence PRODUCTIMPORTSEQ;;
select 'create sequence PRODUCTIMPORTSEQ increment by 1 start with '||
	(1+NVL(max(PRODUCTIMPORT_ID),0))
	|| ' nomaxvalue nocache;' from PRODUCTIMPORT;
--
-- Reset sequence PROVISIONINGSYSTEMIDSEQ
-- 
prompt drop sequence PROVISIONINGSYSTEMIDSEQ;;
select 'create sequence PROVISIONINGSYSTEMIDSEQ increment by 1 start with '||
	(1+NVL(max(provisioning_system_id),0))
	|| ' nomaxvalue nocache;' from PROVISIONINGSYSTEM;   
--
-- Reset sequence RATINGCONFLICTSEQ
--
prompt drop sequence RATINGCONFLICTSEQ;;
select 'create sequence RATINGCONFLICTSEQ increment by 1 start with '||
	(1+NVL(max(RATINGCONFLICT_NUM),0))
	|| ' nomaxvalue nocache;' from RATINGCONFLICT;
--
-- Reset sequence RATINGEDITSEQ
--
prompt drop sequence RATINGEDITSEQ;;
select 'create sequence RATINGEDITSEQ increment by 1 start with '||
	(1+NVL(max(RATINGEDIT_NUM),0))
	|| ' nomaxvalue nocache;' from RATINGEDIT;
--
-- Reset sequence RATINGEXPORTSEQ
--
prompt drop sequence RATINGEXPORTSEQ;;
select 'create sequence RATINGEXPORTSEQ increment by 1 start with '||
	(1+NVL(max(RATINGEXPORT_ID),0))
	|| ' nomaxvalue nocache;' from RATINGEXPORT;
--
-- Reset sequence RATINGIMPORTSEQ
--
prompt drop sequence RATINGIMPORTSEQ;;
select 'create sequence RATINGIMPORTSEQ increment by 1 start with '||
	(1+NVL(max(RATINGIMPORT_ID),0))
	|| ' nomaxvalue nocache;' from RATINGIMPORT;
--
-- Reset sequence RATINGTARIFFIDSEQ
-- 
prompt drop sequence RATINGTARIFFIDSEQ;;
select 'create sequence RATINGTARIFFIDSEQ increment by 1 start with '||
	(1+NVL(max(rating_tariff_id),0))
	|| ' nomaxvalue nocache;' from RATINGTARIFF;  
--
-- Reset sequence RATINGTARIFFTYPEIDSEQ
-- 
prompt drop sequence RATINGTARIFFTYPEIDSEQ;;
select 'create sequence RATINGTARIFFTYPEIDSEQ increment by 1 start with '||
	(1+NVL(max(rating_tariff_type_id),0))
	|| ' nomaxvalue nocache;' from RATINGTARIFFTYPE; 
--
-- Reset sequence REDEMPTIONOPTIONIDSEQ
-- 
prompt drop sequence REDEMPTIONOPTIONIDSEQ;;
select 'create sequence REDEMPTIONOPTIONIDSEQ increment by 1 start with '||
	(1+NVL(max(redemption_option_id),0))
	|| ' nomaxvalue nocache;' from REDEMPTIONOPTION; 
--
-- Reset sequence SCHEDULEINSTANCEIDSEQ
-- 
prompt drop sequence SCHEDULEINSTANCEIDSEQ;;
select 'create sequence SCHEDULEINSTANCEIDSEQ increment by 1 start with '||
	(1+NVL(max(schedule_instance_id),0))
	|| ' nomaxvalue nocache;' from SCHEDULELOG;
--
-- Reset sequence SERVICEREQUESTTRANSSEQ
-- 
prompt drop sequence SERVICEREQUESTTRANSSEQ;;
select 'create sequence SERVICEREQUESTTRANSSEQ increment by 1 start with '||
	(1+NVL(max(service_request_trans_id),0))
	|| ' nomaxvalue nocache;' from SERVICEREQUEST;  
-- 
--  Reset sequence SETTLEMENTPERIODSEQ
--
prompt drop sequence SETTLEMENTPERIODSEQ;;
select 'create sequence SETTLEMENTPERIODSEQ increment by 1 start with '||
	(1+NVL(max(settlement_period_seq),0))
	|| ' nomaxvalue nocache;' from SETTLEMENTBUCKET; 
--
-- Reset sequence STEPGROUPIDSEQ
-- 
prompt drop sequence STEPGROUPIDSEQ;;
select 'create sequence STEPGROUPIDSEQ increment by 1 start with '||
	(1+NVL(max(step_group_id),0))
	|| ' nomaxvalue nocache;' from STEPGROUP;   
--
-- Reset sequence SUBSREFSEQ
-- 
prompt drop sequence SUBSREFSEQ;;
select 'create sequence SUBSREFSEQ increment by 1 start with '||
	(1+NVL(max(subscription_ref),0))
	|| ' nomaxvalue nocache;' from CUSTHASPRODUCT;    
--
-- Reset sequence TARIFFIDSEQ
-- 
prompt drop sequence TARIFFIDSEQ;;
select 'create sequence TARIFFIDSEQ increment by 1 start with '||
	(1+NVL(max(tariff_id),0))
	|| ' nomaxvalue nocache;' from TARIFF;   
--
-- Reset sequence TASKINSTANCEIDSEQ
-- 
prompt drop sequence TASKINSTANCEIDSEQ;;
select 'create sequence TASKINSTANCEIDSEQ increment by 1 start with '||
	(1+NVL(max(task_instance_id),0))
	|| ' nomaxvalue nocache;' from TASKLOG;
--
-- Reset sequence THRESHREDEMPIDSEQ
-- 
prompt drop sequence THRESHREDEMPIDSEQ;;
select 'create sequence THRESHREDEMPIDSEQ increment by 1 start with '||
	(1+NVL(max(threshold_redemption_id),0))
	|| ' nomaxvalue nocache;' from THRESHOLDREDEMPTION;  
--
-- Reset sequence TIMERATEDIARYIDSEQ
-- 
prompt drop sequence TIMERATEDIARYIDSEQ;;
select 'create sequence TIMERATEDIARYIDSEQ increment by 1 start with '||
	(1+NVL(max(time_rate_diary_id),0))
	|| ' nomaxvalue nocache;' from TIMERATEDIARY;   
--
-- Reset sequence TIMERATEIDSEQ
-- 
prompt drop sequence TIMERATEIDSEQ;;
select 'create sequence TIMERATEIDSEQ increment by 1 start with '||
	(1+NVL(max(time_rate_id),0))
	|| ' nomaxvalue nocache;' from TIMERATE;   
--
-- Reset sequence TRANSFERIDSEQ
-- 
prompt drop sequence TRANSFERIDSEQ;;
select 'create sequence TRANSFERIDSEQ increment by 1 start with '||
	(1+NVL(max(transfer_id),0))
	|| ' nomaxvalue nocache;' from FILEGROUPLOG; 
--
-- Reset sequence USAGETYPEIDSEQ
-- 
prompt drop sequence USAGETYPEIDSEQ;;
select 'create sequence USAGETYPEIDSEQ increment by 1 start with '||
	(1+NVL(max(usage_type_id),0))
	|| ' nomaxvalue nocache;' from USAGETYPE;   
--
-- Reset sequence USTPRODUCTCLASSIDSEQ
-- 
prompt drop sequence USTPRODUCTCLASSIDSEQ;;
select 'create sequence USTPRODUCTCLASSIDSEQ increment by 1 start with '||
	(1+NVL(max(ust_product_class_id),0))
	|| ' nomaxvalue nocache;' from USTPRODUCTCLASS;      
-- -----------------------------------------------------------------
spool off
spool /tmp/run_reset_gnv_seq.log
set echo on
@/tmp/run_reset_gnv_seq.sql
spool off
set echo off
set termout on
prompt
prompt The relevant geneva_admin sequences have been reset. 
prompt Review log file /tmp/run_reset_gnv_seq.log for any errors. 
prompt 
