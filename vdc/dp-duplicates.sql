DECLARE
v_event_source varchar2(30);
v_event_type_id number := 0;
v_event_dtm date;
v_reject_dtm date;
v_check varchar2(20) := ' ';
v_cnt number(6) := 0;
CURSOR reject_curs is
       -- Cursor to obtain all the reject data
       SELECT * FROM REJECT_STATUS_07_20070208 order by event_source  ; 
         --  
BEGIN
       DBMS_OUTPUT.ENABLE(1000000000);
         DBMS_OUTPUT.PUT_LINE('Processing Started .....');
         FOR REJECT_REC IN REJECT_CURS LOOP    --Loop through the cursor and set variables
                  v_event_source   := REJECT_REC.event_source; 
                  v_event_type_id  := REJECT_REC.event_type_id; 
                  v_event_dtm      := REJECT_REC.event_dtm;
                          v_reject_dtm     := REJECT_REC.reject_dtm;
--       v_cnt := v_cnt + 1;
       BEGIN
            SELECT event_source INTO v_check from costedevent cc
                  WHERE cc.event_source = v_event_source and 
                        cc.event_type_id = v_event_type_id and 
                          cc.event_dtm = v_event_dtm ;
              EXCEPTION
          WHEN NO_DATA_FOUND THEN
--                 DBMS_OUTPUT.PUT_LINE('NO_DATA_FOUND: '||substr(v_cnt,1,6)||') IMSI :'||v_event_source||' ETI :'||v_event_type_id||' Event Date :'||to_char(v_event_dtm,'yyyy/mm/dd HH24:MI:SS')||' Reject Date :'||to_char(v_reject_dtm,'yyyy/mm/dd HH24:MI:SS'));
                       Insert into Geneva_Duplicates(event_source,event_type_id,event_dtm,reject_dtm)
                       values ( v_event_source,v_event_type_id,v_event_dtm,v_reject_dtm );
          WHEN TOO_MANY_ROWS THEN
                   v_cnt := v_cnt + 1;
               DBMS_OUTPUT.PUT_LINE('TOO_MANY_ROWS: '||substr(v_cnt,1,6)||') IMSI :'||v_event_source||' ETI :'||v_event_type_id||' Event Date :'||to_char(v_event_dtm,'yyyy/mm/dd HH24:MI:SS')||' Reject Date :'||to_char(v_reject_dtm,'yyyy/mm/dd HH24:MI:SS'));
       END;
    END LOOP;
      DBMS_OUTPUT.PUT_LINE('Processing Complete ');
END;
