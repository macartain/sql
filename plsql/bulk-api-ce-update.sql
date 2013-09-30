set serveroutput on 
set pages 50000
timing start ce_update

DECLARE
cursor ce_cursor is
   select ce.*   
    from COSTEDEVENT ce, --partition (p76)  ce             
(select distinct ACCOUNT.ACCOUNT_NUM, ACCOUNTRATINGSUMMARY.EVENT_SEQ
from ACCOUNTRATINGSUMMARY, 
     ACCOUNT, 
     ACCOUNTATTRIBUTES aa
where aa.account_num = ACCOUNT.ACCOUNT_NUM
 and aa.bill_cycle = '1'
 and ACCOUNT.ACCOUNT_NUM = ACCOUNTRATINGSUMMARY.ACCOUNT_NUM 
 and ( ACCOUNTRATINGSUMMARY.EVENT_SEQ >= ACCOUNT.BILL_EVENT_SEQ or
      ACCOUNTRATINGSUMMARY.EVENT_SEQ = -1 )
) bob
where ce.account_num = bob.ACCOUNT_NUM
and ce.event_seq = bob.EVENT_SEQ;             
         
    
  counter         INTEGER;
  type ce_tab_t is table of reportcostedevent%ROWTYPE index by binary_integer;
  reportCE                  ce_tab_t;
  ce_indx                   binary_integer;
  done                      boolean := false;

BEGIN
  counter := 0;
  open ce_cursor;

  while not done
  loop

    fetch ce_cursor bulk collect into reportCE           
       limit 1000;
       
   if reportCE.last < 1000 then
      done := true;
   end if;


    if reportCE is not null then
        forall ce_indx in reportCE.first..reportCE.last
          insert /*+ append */ into RPTCOSTEDEVENT 
           values reportCE(ce_indx);
          
          counter := counter + sql%rowcount;
          dbms_output.put_line ( 'inserted : '||counter||' rows' );
    end if;

    commit;
    exit when ce_cursor%notfound;

  end loop;

  dbms_output.put_line ( 'inserted : '||counter||' rows' );
  commit;


END;
/
timing stop ce_update
