#!/usr/bin/perl -w

use strict;
use DBI;
$|++;


#- returns the last number used for the sequence provided in parameter.
sub getSequenceNextVal()
{
   my $dbh = shift;
   my $seqName = shift;
   my $sth;

   $sth = $dbh->prepare(
          qq/select LAST_NUMBER
             from   dba_sequences
             where  sequence_name = '$seqName'
            /);

   $sth->execute;

   my @result = $sth->fetchrow_array();

   $sth->finish;

   return $result[0];
}

#- returns the max value of the corresponding column in table.
sub getTableFieldMaxVal()
{
   my $dbh = shift;
   my $table = shift;
   my $field = shift;
   my $sth;

   $sth = $dbh->prepare(
          qq/SELECT MAX($field)
             FROM   $table/);

   $sth->execute;

   my @result  = $sth->fetchrow_array();

   $result[0] = 0 if not defined $result[0];

   $sth->finish;

   return $result[0];
}

#- Drop and recreate KO Sequences
sub DropRecreateKOSequences
{
   my $dbh = shift;
   my $seqName = shift;
   my $seqNextVal = shift;
   print "..... inside DropRecreateKOSequences with $seqName | $seqNextVal\n";
   eval
   {
      $dbh->do("drop sequence $seqName");
      $dbh->do("create sequence $seqName increment by 1 start with $seqNextVal nomaxvalue nocache");
      $dbh->commit;
   };
   print "------------------ failed: $@" if $@;

}

#- compare sequence last value with max of corresponding column.table
#  and print on STDOUT the result of the comparaison.
sub checkSequence()
{
   my $dbh = shift;
   my ($seqName, $table, $field) = @_;

   my $seqNextVal = &getSequenceNextVal($dbh,$seqName);
   my $maxVal     = &getTableFieldMaxVal($dbh,$table, $field);

   print "" . ($maxVal != 0 && $maxVal>=$seqNextVal ?"KO - ":"OK - ") . "$seqName -> $seqNextVal - max($table.$field) -> $maxVal\n";
   
   
   
   if ( $maxVal != 0 && $maxVal >= $seqNextVal )
   {
        my $nextVal = $maxVal + 1;
   	print "Recreating sequence $seqName to  value $nextVal\n";
   	DropRecreateKOSequences($dbh,$seqName,$nextVal);
   	
   }
   
   

}


#####################################
### MAIN
#####################################

#- initialize a database connection object
#  the script will connect the database instance pointed by the DATABASE env variable.
# -------------------------------------------------------------------------------------


#- decode user name / password / SID from the env variable.
$ENV{DATABASE} =~ m#(.*)/(.*)@(.*)#;

#- initialize the database connection using the parameter decoded above.
my $dbh = DBI->connect("dbi:Oracle:$3","$1","$2",
              {
                 RaiseError => 1,
                 PrintError => 0,
                 AutoCommit => 0   #- to make sure that our transaction
                                   #- won't get committed in the middle
              }
          );

#- terminate the script if connection failed.
die "Can't connect to $ENV{DATABASE}" if not defined $dbh;



#- loop on the data to execute the check logic...
# ------------------------------------------------

while ( <DATA> )
{
    #- skip empty or comment lines
    next if /^$/ or /^#/;
    
    #- remove carriage return caracter from the read data
    chomp;
    
    #- split the fields of the records into corresponding variables.
    my ($seqName, $table, $field) = split ",";
    
    #- proceed with the checking of the corresponding sequence.
    &checkSequence($dbh, $seqName, $table, $field);
}




#- close database connection after a rollback
# --------------------------------------------

$dbh->rollback;
$dbh->disconnect;

exit 0;

__DATA__

# list the sequences and corresponding table/column used by IRB
# THE LIST MIGHT NOT BE COMPLETE

AEGSEQ,ACCRUALSEXTRACT,ACCRUALS_EXTRACT_ID
AUTHCODESEQ,EVENTRESERVATION,RESERVATION_IDENTIFIER
BANDINGMODELIDSEQ,BANDINGMODEL,BANDING_MODEL_ID
BATCHIDSEQ,PAYMENTBATCH,BATCH_ID
BILLDISCOUNTIDSEQ,BILLDISCOUNT,BILL_DISCOUNT_ID
BILLINGARCHIVEFILENUMSEQ,BILLARCHIVELOG,ARCHIVE_FILE_NUM
BILLINGCONFLICTSEQ,BILLINGCONFLICT,BILLINGCONFLICT_NUM
BILLINGEDITSEQ,BILLINGEDIT,BILLINGEDIT_NUM
BILLINGEXPORTSEQ,BILLINGEXPORT,BILLINGEXPORT_ID
BILLINGIMPORTSEQ,BILLINGIMPORT,BILLINGIMPORT_ID
BONUSSCHEMEIDSEQ,BONUSSCHEME,BONUS_SCHEME_ID
BUDGETPAYPLANIDSEQ,BUDGETPAYMENTPLAN,BUDGET_PAYMENT_PLAN_ID
CHARGESEGMENTIDSEQ,CHARGESEGMENT,CHARGE_SEGMENT_ID
COMPOSITEFILTERIDSEQ,COMPOSITEFILTER,COMPOSITE_FILTER_ID
COSTBANDIDSEQ,COSTBAND,COST_BAND_ID
COSTGROUPIDSEQ,COSTGROUP,COSTGROUP_ID
COSTINGRULESIDSEQ,COSTINGRULES,COSTING_RULES_ID
DUNNINGARCHIVEFILENUMSEQ,DUNNINGARCHIVELOG,ARCHIVE_FILE_NUM
EVENTCLASSIDSEQ,EVENTCLASS,EVENT_CLASS_ID
EVENTDISCOUNTIDSEQ,EVENTDISCOUNT,EVENT_DISCOUNT_ID
EVENTFILTERIDSEQ,EVENTFILTER,EVENT_FILTER_ID
JOBIDSEQ,JOB,JOB_ID
LOCKVERSIONSEQ,ACCOUNT,ACCOUNT_LOCK_VERSION
MANAGEDFILEIDSEQ,MANAGEDFILE,MANAGED_FILE_ID
MODIFIERGROUPIDSEQ,MODIFIERGROUP,MODIFIER_GROUP_ID
MODIFIERIDSEQ,MODIFIER,MODIFIER_ID
PACKAGEIDSEQ,PACKAGE,PACKAGE_ID
#PARAMETERIDSEQ,REPORTHASPARAMETER,PARAMETER_ID
PAYREQIDSEQ,PAYMENTREQUEST,PAYMENT_REQ_ID
PAYSETTLEMENTACTIONSEQ,PAYSETTLEMENTACTION,UPDATE_SEQ
PROCESSIDSEQ,PROCESSLOG,PROCESS_ID
PROCESSINSTANCEIDSEQ,PROCESSINSTANCELOG,PROCESS_INSTANCE_ID
PRODUCTATTRIBUTEIDSEQ,PRODUCTATTRIBUTE,PRODUCT_ATTRIBUTE_SUBID
PRODUCTCONFLICTSEQ,PRODUCTCONFLICT,PRODUCTCONFLICT_NUM
PRODUCTEDITSEQ,PRODUCTEDIT,PRODUCTEDIT_NUM
PRODUCTEXPORTSEQ,PRODUCTEXPORT,PRODUCTEXPORT_ID
PRODUCTFAMILYIDSEQ,PRODUCTFAMILY,PRODUCT_FAMILY_ID
PRODUCTIDSEQ,PRODUCT,PRODUCT_ID
PRODUCTIMPORTSEQ,PRODUCTIMPORT,PRODUCTIMPORT_ID
PROVISIONINGSYSTEMIDSEQ,PROVISIONINGSYSTEM,PROVISIONING_SYSTEM_ID
RATINGCONFLICTSEQ,RATINGCONFLICT,RATINGCONFLICT_NUM
RATINGEDITSEQ,RATINGEDIT,RATINGEDIT_NUM
RATINGEXPORTSEQ,RATINGEXPORT,RATINGEXPORT_ID
RATINGIMPORTSEQ,RATINGIMPORT,RATINGIMPORT_ID
RATINGTARIFFIDSEQ,RATINGTARIFF,RATING_TARIFF_ID
RATINGTARIFFTYPEIDSEQ,RATINGTARIFFTYPE,RATING_TARIFF_TYPE_ID
REDEMPTIONOPTIONIDSEQ,REDEMPTIONOPTION,REDEMPTION_OPTION_ID
SCHEDULEINSTANCEIDSEQ,SCHEDULELOG,SCHEDULE_INSTANCE_ID
SERVICEREQUESTTRANSSEQ,SERVICEREQUEST,SERVICE_REQUEST_TRANS_ID
SETTLEMENTPERIODSEQ,SETTLEMENTPERIOD,SETTLEMENT_PERIOD_SEQ
STEPGROUPIDSEQ,STEPGROUP,STEP_GROUP_ID
SUBSREFSEQ,CUSTHASPRODUCT,SUBSCRIPTION_REF
TARIFFIDSEQ,TARIFF,TARIFF_ID
TASKINSTANCEIDSEQ,TASKLOG,TASK_INSTANCE_ID
THRESHREDEMPIDSEQ,THRESHOLDREDEMPTION,THRESHOLD_REDEMPTION_ID
TIMERATEDIARYIDSEQ,TIMERATEDIARY,TIME_RATE_DIARY_ID
TIMERATEIDSEQ,TIMERATE,TIME_RATE_ID
TRANSFERIDSEQ,FILEGROUPLOG,TRANSFER_ID
USAGETYPEIDSEQ,USAGETYPE,USAGE_TYPE_ID
USTPRODUCTCLASSIDSEQ,USTPRODUCTCLASS,UST_PRODUCT_CLASS_ID
