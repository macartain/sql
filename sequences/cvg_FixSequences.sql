
--
--    Fixes the 'Sequences' owned by GENEVA_ADMIN ( v5.3 ).
--
--        Sequences are dropped then created according to max value selected
--        FROM associated tables.
--
--        SELECT and ALTER privileges are granted to role GENEVAADMIN after
--        each sequence is created.
--
--        Script does NOT reset following sequences :
--
--            CCMANDATESEQ                  ( Custom defined, see GNVDDMMANDATES )
--            DDMANDATESEQ                  ( Custom defined, see GNVDDMMANDATES )
--            USTPRODUCTCLASSIDSEQ          ( Only if UST used )
--            AQ$_COSTEDEVENTQUEUEHEAD_N    ( Should not be reset )
--            AQ$_COSTEDEVENTQUEUETAIL_N    ( Should not be reset )
--            AQ$_REJECTEVENTQUEUEHEAD_N    ( Should not be reset )
--            AQ$_REJECTEVENTQUEUETAIL_N    ( Should not be reset )
--            PRODUCTATTRIBUTEIDSEQ         ( Not used Geneva core 5.2 )
--            RTFFILEGROUPSEQ               ( Not used Geneva core 5.2 )
--

SET SERVEROUTPUT ON SIZE 1000000

DECLARE

    GPARAMValue     VARCHAR(255) := NULL;
    sequenceNum     NUMBER(18)   := 1;
    prefixLength    PLS_INTEGER;

    excIntegrityError EXCEPTION;
    PRAGMA EXCEPTION_INIT( excIntegrityError, -20999 );

    PROCEDURE procResetSeq( inSeqName       VARCHAR2,
                            inSeqValue      PLS_INTEGER,
                            inSeqOption     VARCHAR2 )
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE( '. . . Creating Sequence = ' || inSeqName  ||
                                         ' with value = '  || inSeqValue ||
                                         ' with option = ' || inSeqOption );

        DBMS_OUTPUT.PUT_LINE( 'DROP SEQUENCE ' || inSeqName || ';');
        DBMS_OUTPUT.PUT_LINE( 'CREATE SEQUENCE ' || inSeqName   || ' INCREMENT BY 1 START WITH '
                                             || inSeqValue  || ' '
                                             || inSeqOption || ';');
                                             
        -- BEGIN
        --     EXECUTE IMMEDIATE 'DROP SEQUENCE ' || inSeqName;
        -- EXCEPTION
        --     WHEN OTHERS THEN
        --         NULL;
        -- END;

        -- EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || inSeqName   || ' INCREMENT BY 1 START WITH '
        --                                      || inSeqValue  || ' '
        --                                      || inSeqOption;

        -- EXECUTE IMMEDIATE 'GRANT SELECT, ALTER ON ' || inSeqName || ' TO GENEVAADMIN';

    END procResetSeq;

BEGIN

    --
    --    Only if 'Account Num Auto Numbering' is enabled . . .
    --

        DBMS_OUTPUT.PUT_LINE( '. . Checking SYSautoAccountNumberingBoo . . .' );
        GPARAMValue := GNVTranslate.GetTranslatableGPARAM( 'SYSautoAccountNumberingBoo' );

        IF ( GPARAMValue = 'T' )
        THEN
            --
            --    Strip prefix from 'Account Number' values.
            --

            prefixLength := 1;
            GPARAMValue  := GNVTranslate.GetTranslatableGPARAM( 'SYSaccountNumPrefix' );

            IF ( GPARAMValue IS NOT NULL )
            THEN
                prefixLength := LENGTH( GPARAMValue );
            END IF;

            SELECT NVL( SUBSTR( MAX( acc.Account_Num ), prefixLength, 20 ) + 1, 1 )
            INTO   sequenceNum
            FROM   Account  acc
            WHERE  ( acc.Internal_Account_Boo = 'F' );

            procResetSeq( 'ACCOUNTNUMSEQ', sequenceNum, 'NOCACHE' );
        END IF;

    --
    --    Only if 'Customer Reference Auto Numbering' is enabled . . .
    --

        DBMS_OUTPUT.PUT_LINE( '. . Checking SYSautoCustomerNumberingBoo . . .' );
        GPARAMValue := GNVTranslate.GetTranslatableGPARAM( 'SYSautoCustomerNumberingBoo' );

        IF ( GPARAMValue = 'T' )
        THEN
            --
            --    Strip prefix from 'Customer Reference' values.
            --

            prefixLength := 1;
            GPARAMValue  := GNVTranslate.GetTranslatableGPARAM( 'SYScustomerRefPrefix' );

            IF ( GPARAMValue IS NOT NULL )
            THEN
                prefixLength := LENGTH( GPARAMValue );
            END IF;

            SELECT NVL( SUBSTR( MAX( cus.Customer_Ref ), prefixLength, 20 ) + 1, 1 )
            INTO   sequenceNum
            FROM   Customer  cus
            WHERE  ( cus.Account_Count > 0 );

            procResetSeq( 'CUSTOMERREFSEQ', sequenceNum, 'NOCACHE' );
        END IF;

    --
    --    Only if 'Subscription Reference Auto Numbering' is enabled . . .
    --

        DBMS_OUTPUT.PUT_LINE( '. . Checking SYSautoSubsNumberingBoo . . .' );
        GPARAMValue := GNVTranslate.GetTranslatableGPARAM( 'SYSautoSubsNumberingBoo' );

        IF ( GPARAMValue = 'T' )
        THEN
            --
            --    Strip prefix from 'Subscription Reference' values.
            --

            prefixLength := 1;
            GPARAMValue  := GNVTranslate.GetTranslatableGPARAM( 'SYSsubsNumPrefix' );

            IF ( GPARAMValue IS NOT NULL )
            THEN
                prefixLength := LENGTH( GPARAMValue );
            END IF;

            SELECT NVL( SUBSTR( MAX( chp.Subscription_Ref ), prefixLength, 20 ) + 1, 1 )
            INTO   sequenceNum
            FROM   CustHasProduct  chp;

            procResetSeq( 'SUBSREFSEQ', sequenceNum, 'NOCACHE' );
        END IF;

    --
    --    . . .  and now do the simple sequences . . .
    --

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence AEGSEQ . . .' );
        SELECT NVL( MAX( Accruals_Extract_Id ), 1 ) + 1 INTO sequenceNum
                    FROM Accruals;
        procResetSeq( 'AEGSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence AUTHCODESEQ . . .' );
        SELECT NVL( MAX( Reservation_Identifier ), 1 ) + 1 INTO sequenceNum
                    FROM EventReservation;
        procResetSeq( 'AUTHCODESEQ', sequenceNum, 'CACHE 10' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence BANDINGMODELIDSEQ . . .' );
        SELECT NVL( MAX( Banding_Model_Id ), 1 ) + 1 INTO sequenceNum
                    FROM BandingModel;
        procResetSeq( 'BANDINGMODELIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence BATCHIDSEQ . . .' );
        SELECT NVL( MAX( Batch_Id ), 1 ) + 1 INTO sequenceNum
                    FROM PaymentBatch;
        procResetSeq( 'BATCHIDSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence BILLDISCOUNTIDSEQ . . .' );
        SELECT NVL( MAX( Bill_Discount_Id), 1 ) + 1 INTO sequenceNum
                    FROM BillDiscount;
        procResetSeq( 'BILLDISCOUNTIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence BILLINGARCHIVEFILENUMSEQ . . .' );
        SELECT NVL( MAX( Archive_File_Num ), 1 ) + 1 INTO sequenceNum
                    FROM BillArchivelog;
        procResetSeq( 'BILLINGARCHIVEFILENUMSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence BONUSSCHEMEIDSEQ . . .' );
        SELECT NVL( MAX( Bonus_Scheme_Id ), 1 ) + 1 INTO sequenceNum
                    FROM BonusScheme;
        procResetSeq( 'BONUSSCHEMEIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence BUDGETPAYPLANIDSEQ . . .' );
        SELECT NVL( MAX( Budget_Payment_Plan_Id ), 1 ) + 1 INTO sequenceNum
                    FROM BudgetPaymentPlan;
        procResetSeq( 'BUDGETPAYPLANIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence CHARGESEGMENTIDSEQ . . .' );
        SELECT NVL( MAX( Charge_Segment_Id ), 1 ) + 1 INTO sequenceNum
                    FROM ChargeSegment;
        procResetSeq( 'CHARGESEGMENTIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence COMPOSITEFILTERIDSEQ . . .' );
        SELECT NVL( MAX( Composite_Filter_Id ), 1 ) + 1 INTO sequenceNum
                    FROM CompositeFilter;
        procResetSeq( 'COMPOSITEFILTERIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence COSTBANDIDSEQ . . .' );
        SELECT NVL( MAX( Cost_Band_Id ), 1 ) + 1 INTO sequenceNum
                    FROM CostBand;
        procResetSeq( 'COSTBANDIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence COSTGROUPIDSEQ . . .' );
        SELECT NVL( MAX( CostGroup_Id ), 1 ) + 1 INTO sequenceNum
                    FROM CostGroup;
        procResetSeq( 'COSTGROUPIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence COSTINGRULESIDSEQ . . .' );
        SELECT NVL( MAX( Costing_Rules_Id), 1 ) + 1 INTO sequenceNum
                    FROM CostingRules;
        procResetSeq( 'COSTINGRULESIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence DLFBATCHSEQ . . .' );
        SELECT NVL( MAX( Dunning_Letter_Seq ), 1 ) + 1 INTO sequenceNum
                    FROM FormattingRequest;
        procResetSeq( 'DLFBATCHSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence DUNNINGARCHIVEFILENUMSEQ . . .' );
        SELECT NVL( MAX( Archive_File_Num ), 1 ) + 1 INTO sequenceNum
                    FROM DunningArchiveLog;
        procResetSeq( 'DUNNINGARCHIVEFILENUMSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence EVENTCLASSIDSEQ . . .' );
        SELECT NVL( MAX( Event_Class_Id ), 1 ) + 1 INTO sequenceNum
                    FROM EventClass;
        procResetSeq( 'EVENTCLASSIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence EVENTDISCOUNTIDSEQ . . .' );
        SELECT NVL( MAX( Event_Discount_Id ), 1 ) + 1 INTO sequenceNum
                    FROM EventDiscount;
        procResetSeq( 'EVENTDISCOUNTIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence EVENTFILTERIDSEQ . . .' );
        SELECT NVL( MAX( Event_Filter_Id ), 1 ) + 1 INTO sequenceNum
                    FROM EventFilter;
        procResetSeq( 'EVENTFILTERIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence JOBIDSEQ . . .' );
        SELECT NVL( MAX( Job_Id ), 1 ) + 1 INTO sequenceNum
                    FROM Job;
        procResetSeq( 'JOBIDSEQ', sequenceNum, 'MAXVALUE 999999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence MANAGEDFILEIDSEQ . . .' );
        SELECT NVL( MAX( Managed_File_Id ), 1 ) + 1 INTO sequenceNum
                    FROM ManagedFile;
        procResetSeq( 'MANAGEDFILEIDSEQ', sequenceNum, 'MAXVALUE 999999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence MODIFIERGROUPIDSEQ . . .' );
        SELECT NVL( MAX( Modifier_Group_Id ), 1 ) + 1 INTO sequenceNum
                    FROM ModifierGroup;
        procResetSeq( 'MODIFIERGROUPIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence PACKAGEIDSEQ . . .' );
        SELECT NVL( MAX( Package_Id ), 1 ) + 1 INTO sequenceNum
                    FROM Package;
        procResetSeq( 'PACKAGEIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence PARAMETERIDSEQ . . .' );
        SELECT NVL( MAX( Parameter_Id ), 1 ) + 1 INTO sequenceNum
                    FROM ReportParameter;
        procResetSeq( 'PARAMETERIDSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence PAYREQIDSEQ . . .' );
        SELECT NVL( MAX( Payment_Req_Id ), 1 ) + 1 INTO sequenceNum
                    FROM PaymentRequest;
        procResetSeq( 'PAYREQIDSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence PAYSETTLEMENTACTIONSEQ . . .' );
        SELECT NVL( MAX( Update_Seq ), 1 ) + 1 INTO sequenceNum
                    FROM PaySettlementAction;
        procResetSeq( 'PAYSETTLEMENTACTIONSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence PROCESSIDSEQ . . .' );
        SELECT NVL( MAX( Process_Id ), 1 ) + 1 INTO sequenceNum
                    FROM ProcessLog;
        procResetSeq( 'PROCESSIDSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence PROCESSINSTANCEIDSEQ . . .' );
        SELECT NVL( MAX( Process_Instance_Id ), 1 ) + 1 INTO sequenceNum
                    FROM ProcessInstanceLog;
        procResetSeq( 'PROCESSINSTANCEIDSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence PRODUCTFAMILYIDSEQ . . .' );
        SELECT NVL( MAX( Product_Family_Id ), 1 ) + 1 INTO sequenceNum
                    FROM ProductFamily;
        procResetSeq( 'PRODUCTFAMILYIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence PRODUCTIDSEQ . . .' );
        SELECT NVL( MAX( Product_Id ), 1 ) + 1 INTO sequenceNum
                    FROM Product;
        procResetSeq( 'PRODUCTIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence PROVISIONINGSYSTEMIDSEQ . . .' );
        SELECT NVL( MAX( Provisioning_System_Id ), 1 ) + 1 INTO sequenceNum
                    FROM ProvisioningSystem;
        procResetSeq( 'PROVISIONINGSYSTEMIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence RATINGTARIFFIDSEQ . . .' );
        SELECT NVL( MAX( Rating_Tariff_Id), 1 ) + 1 INTO sequenceNum
                    FROM RatingTariff;
        procResetSeq( 'RATINGTARIFFIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence REDEMPTIONOPTIONIDSEQ . . .' );
        SELECT NVL( MAX( Redemption_Option_Id ), 1 ) + 1 INTO sequenceNum
                    FROM RedemptionOption;
        procResetSeq( 'REDEMPTIONOPTIONIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence SCHEDULEINSTANCEIDSEQ . . .' );
        SELECT NVL( MAX( Schedule_Instance_Id ), 1 ) + 1 INTO sequenceNum
                    FROM ScheduleLog;
        procResetSeq( 'SCHEDULEINSTANCEIDSEQ', sequenceNum, 'NOMAXVALUE NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence SERVICEREQUESTTRANSSEQ . . .' );
        SELECT NVL( MAX( Service_Request_Trans_Id ), 1 ) + 1 INTO sequenceNum
                    FROM ServiceRequest;
        procResetSeq( 'SERVICEREQUESTTRANSSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence SETTLEMENTPERIODSEQ . . .' );
        SELECT NVL( MAX( Settlement_Period_Seq ), 1 ) + 1 INTO sequenceNum
                    FROM SettlementPeriod;
        procResetSeq( 'SETTLEMENTPERIODSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence STEPGROUPIDSEQ . . .' );
        SELECT NVL( MAX( Step_Group_Id ), 1 ) + 1 INTO sequenceNum
                    FROM StepGroup;
        procResetSeq( 'STEPGROUPIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence TARIFFIDSEQ . . .' );
        SELECT NVL( MAX( Tariff_Id ), 1 ) + 1 INTO sequenceNum
                    FROM Tariff;
        procResetSeq( 'TARIFFIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence TASKINSTANCEIDSEQ . . .' );
        SELECT NVL( MAX( Task_Instance_Id ), 1 ) + 1 INTO sequenceNum
                    FROM TaskLog;
        procResetSeq( 'TASKINSTANCEIDSEQ', sequenceNum, 'NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence THRESHREDEMPIDSEQ . . .' );
        SELECT NVL( MAX( Threshold_Redemption_Id ), 1 ) + 1 INTO sequenceNum
                    FROM ThresholdRedemption;
        procResetSeq( 'THRESHREDEMPIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence TIMERATEDIARYIDSEQ . . .' );
        SELECT NVL( MAX( Time_Rate_Diary_Id ), 1 ) + 1 INTO sequenceNum
                    FROM TimeRateDiary;
        procResetSeq( 'TIMERATEDIARYIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence TIMERATEIDSEQ . . .' );
        SELECT NVL( MAX( Time_Rate_Id ), 1 ) + 1 INTO sequenceNum
                    FROM TimeRate;
        procResetSeq( 'TIMERATEIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence TRANSFERIDSEQ . . .' );
        SELECT NVL( MAX( Transfer_Id ), 1 ) + 1 INTO sequenceNum
                    FROM FileGroupLog;
        procResetSeq( 'TRANSFERIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

        DBMS_OUTPUT.PUT_LINE( '. . Doing sequence USAGETYPEIDSEQ . . .' );
        SELECT NVL( MAX( Usage_Type_Id ), 1 ) + 1 INTO sequenceNum
                    FROM UsageType;
        procResetSeq( 'USAGETYPEIDSEQ', sequenceNum, 'MAXVALUE 999999 NOCACHE' );

    --
    --    All done.
    --

    COMMIT;

EXCEPTION
    WHEN excIntegrityError THEN
        DBMS_OUTPUT.PUT_LINE( 'Integrity Error : '      );
        DBMS_OUTPUT.PUT_LINE( 'Errno : '  || SQLCODE    );
        DBMS_OUTPUT.PUT_LINE( 'ErrMsg : ' || SQLERRM    );
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE( 'Oracle Error : '         );
        DBMS_OUTPUT.PUT_LINE( 'Errno : '  || SQLCODE    );
        DBMS_OUTPUT.PUT_LINE( 'ErrMsg : ' || SQLERRM    );
END;
/
