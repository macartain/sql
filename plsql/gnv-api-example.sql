set serveroutput on size unlimited

declare

errorStatus        NUMBER(9);
returnValue        INTEGER;
v_error            INTEGER;
v_mess             VARCHAR2(200);
productSeq         INTEGER;
paymentMethodId    INTEGER;
customerRef        VARCHAR2(40);
accountNum         VARCHAR2(40);
mandateRef         VARCHAR2(50);
mandateSeq         INTEGER;
cardNumber         VARCHAR2(26);
activeToDat        DATE;
activeFromDat      DATE;
cardExpiryDat      DATE;
cardIssueDat       DATE;


begin

    cardNumber:='0000000000000102';
    accountNum:='0000000011';
    --accountNum:='GP000000222';
    paymentMethodId:=200;
    activeFromDat:=trunc(gnvgen.systemdate);
    activeToDat:=to_date('20101201','YYYYMMDD');
    cardIssueDat:=to_date('20080101','YYYYMMDD');
    cardExpiryDat:=to_date('20101231','YYYYMMDD');

SI_CREATEMANDATE1NC
(
  ACCOUNTNUM=>accountNum,
  PAYMENTMETHODID=>paymentMethodId,
  ACTIVEFROMDAT=>activeFromDat,
  ACTIVETODAT=>activeToDat,
  BANKACCOUNTHOLDER=>null,
  BANKACCOUNTNUMBER=>null,
  BANKCODE=>null,
  BANKBRANCHNUMBER=>null,
  CARDNUMBER=>cardNumber,
  CARDEXPIRYDAT=>cardExpiryDat,
  CARDISSUEDAT=>cardIssueDat,
  CARDISSUENUM=>null,
  MANDATEATTR1 =>'name on card',
  MANDATEATTR2=>'VI',
  MANDATEATTR3=>null,
  MANDATEATTR4=>null,
  MANDATEATTR5=>null,
  MANDATEATTR6=>'OT',
  MANDATEREF=>mandateRef,
  MANDATESEQ=>mandateSeq
    ) ;


   dbms_output.put_line('Created mandate '||mandateRef||' sequence '||mandateSeq);

    errorStatus:=SQLCODE;

    if(errorStatus < 0)
    then
        raise_application_error(-20999,'Error running API');
    end if;

   if(returnValue <0)
   then
        raise_application_error(-20999,'API returned an error');
   else
        commit;
   end if;

EXCEPTION
WHEN OTHERS THEN
        rollback;
        v_error:=SQLCODE;
        v_mess:=SQLERRM;
        dbms_output.put_line(v_error || ' : ' || v_mess);
end;
/
quit;
