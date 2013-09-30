-- Script to identify customers with large number of products
create table largecustomers 
("customer_ref" VARCHAR2(20),"random_hash" NUMBER(6),"product_count" NUMBER(9),"event_source_count" NUMBER(9));

DECLARE
  my_customerref      VARCHAR2(20);
  my_randomhash       NUMBER(6);
  my_productcount     NUMBER(9);
  my_eventsourcecount NUMBER(9);
  CURSOR c1 IS
    select chp.customer_ref,
           max(c.random_hash),
           count(*),
           sum(chp.event_source_count)
      from custhasproduct chp, customer c
     where chp.customer_ref = c.customer_ref
       and c.random_hash > 900000
     group by chp.customer_ref;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1
      INTO my_customerref, my_randomhash, my_productcount, my_eventsourcecount;
    IF my_productcount > 10 THEN
      INSERT into largecustomers values (my_customerref, my_randomhash, my_productcount, my_eventsourcecount);
    END IF;
    EXIT WHEN c1%NOTFOUND;
  END LOOP;
END;
/


-- Script to output customers with large number of products
DECLARE
  my_customerref      VARCHAR2(20);
  my_randomhash       NUMBER(6);
  my_productcount     NUMBER(9);
  my_eventsourcecount NUMBER(9);
  CURSOR c1 IS
    select chp.customer_ref,
           max(c.random_hash),
           count(*),
           sum(chp.event_source_count)
      from custhasproduct chp, customer c
     where chp.customer_ref = c.customer_ref
       and c.random_hash > 900000
     group by chp.customer_ref;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1
      INTO my_customerref, my_randomhash, my_productcount, my_eventsourcecount;
    IF my_productcount > 100000 THEN
    DBMS_OUTPUT.PUT_LINE('Cust:' || my_customerref || ' Random Hash: ' || my_randomhash || ' Products: ' || 
    my_productcount || ' Event Sources: ' || my_eventsourcecount);
    END IF;
    EXIT WHEN c1%NOTFOUND;
  END LOOP;
END;
/
