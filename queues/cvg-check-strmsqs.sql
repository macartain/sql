set serveroutput on
declare
        counter                 number;
        counter2                number;
        COUNTER3                NUMBER;
        msg_state               varchar2(100);
        v_sqlcode               number;
        v_address                       varchar2(1000);
        type c_t is ref cursor;
        stmtc c_t;

begin

        for i in ( select queue_table from user_queue_tables where queue_table like 'STRMS%' or queue_table like '%APPLY%' )
        loop
                open stmtc for 
                        'select address,  nvl(SUM(decode(msg_state,''PROCESSED'',1,0)),0), ' ||
                        'nvl(SUM(decode(msg_state,''READY'',1,0)),0), nvl(SUM(decode(msg_state,''UNDELIVERABLE'',1,0)),0) from aq$'||
                        i.queue_table || 
                        ' group by address';
                loop
                begin
                fetch stmtc into v_address, counter, counter2, COUNTER3;
                exit when stmtc%notfound;

                dbms_output.put_line ( '<counter queue_table="' || 
                                     i.queue_table || 
                                     '" address="' || replace(v_address,'"','') || 
                                     '" processed="'||counter || 
                                     '"  ready="' || counter2 || 
                                     '"  undeliverable="' || counter3 || 
                                     '"/>');
                exception
                        when others then
                             v_sqlcode := sqlcode;
                             if v_sqlcode = 1403 then
                                dbms_output.put_line ( 'Count of : ' || i.queue_table||' is : 0 for all message states.' );
                             else
                                dbms_output.put_line ( 'Error: couldn''t count table : ' || i.queue_table || ' sqlcode : ' || v_sqlcode ||
                                                     'with message '|| sqlerrm );
                             end if;
                end;
                end loop;
                close stmtc;
        end loop;
end;