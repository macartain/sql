set serveroutput on size 500000

/*
Script to change the RANDOM_HASH values to improve load balancing.

It is driven by a bespoke table which contains the new random hash values
to be used. Table: jez_random_hashes
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 CUSTOMER_REF                              NOT NULL VARCHAR2(20)
 RANDOM_HASH                               NOT NULL NUMBER
 RANKNUM                                   NOT NULL NUMBER
 ACCOUNT_NUM                                        VARCHAR2(20)

The account_num is nullable so that random hashes for customer references can
be changed without accessing the account tables. However, this is currently
not supported, and will be a future enhancement, if required.

This script assumes that the customer_ref is to have the same random hash
values as the account if it used to have the same value.

If there are errors for one account for a customer, then no changes are
made to any accounts for the customer.

Note: this script does not update SPDDISPATCHACCOUNT because it does not
seem to use the same random hash values as the account.

Written by Jerry Alderson, 26th August 2003.
*/

DECLARE
    CURSOR c_random_hash_changes IS
        SELECT  account_num,
                customer_ref,
                random_hash
        FROM    jez_random_hashes
        ORDER BY customer_ref, account_num;

    accReadCount         NUMBER;
    accUpdateCount       NUMBER;
    custReadCount        NUMBER;
    custUpdateCount      NUMBER;

    bothHashesSame       BOOLEAN;
    accErrorForTheCust   BOOLEAN;
    prevCustRef          VARCHAR2(20);
    prevNewRandomHash    NUMBER;

    v_customer_ref       account.customer_ref%TYPE;
    v_acct_random_hash   account.random_hash%TYPE;
    v_cust_random_hash   customer.random_hash%TYPE;

    PROCEDURE traceRowsUpdated (
        p_rowType IN VARCHAR2,
        p_tableName IN VARCHAR2
        ) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('TRACE: table ' || p_tableName ||
                             ' updated ' ||
                             TO_CHAR(SQL%ROWCOUNT) || ' ' || p_rowType ||
                             ' rows');
    END traceRowsUpdated;

    PROCEDURE changeAccRandomHashValues (
        p_accountNum IN VARCHAR2,
        p_randomHash IN VARCHAR2
        ) IS
    BEGIN
        -- update account table
        UPDATE account
        SET    random_hash = p_randomHash
        WHERE  account_num = p_accountNum
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('acc', 'ACCOUNT');

        -- update billrequest table
        UPDATE billrequest
        SET    random_hash = p_randomHash
        WHERE  account_num = p_accountNum
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('acc', 'BILLREQUEST');

        -- update cancelbillrequest table
        UPDATE cancelbillrequest
        SET    random_hash = p_randomHash
        WHERE  cancellation_driver = p_accountNum
        AND    driver_type = 'A'
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('acc', 'CANCELBILLREQUEST');

        -- update debtescalationrequest table
        UPDATE debtescalationrequest
        SET    random_hash = p_randomHash
        WHERE  account_num = p_accountNum
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('acc', 'DEBTESCALATIONREQUEST');

        -- update formattingrequest table
        UPDATE formattingrequest
        SET    random_hash = p_randomHash
        WHERE  account_num = p_accountNum
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('acc', 'FORMATTINGREQUEST');

        -- update paymentrequest table
        UPDATE paymentrequest
        SET    random_hash = p_randomHash
        WHERE  account_num = p_accountNum
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('acc', 'PAYMENTREQUEST');

        -- update reissuerequest table
        UPDATE reissuerequest
        SET    random_hash = p_randomHash
        WHERE  account_num = p_accountNum
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('acc', 'REISSUEREQUEST');

        -- update unloadevent table
        UPDATE unloadevent
        SET    random_hash = p_randomHash
        WHERE  account_num = p_accountNum
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('acc', 'UNLOADEVENT');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: encountered error when trying to ' ||
                                 ' update rows for account num ' ||
                                 p_accountNum);
            RAISE;
    END changeAccRandomHashValues;

    PROCEDURE changeCustRandomHashValues (
        p_customerRef IN VARCHAR2,
        p_randomHash IN VARCHAR2
        ) IS
    BEGIN
        -- update customer table
        UPDATE customer
        SET    random_hash = p_randomHash
        WHERE  customer_ref = p_customerRef
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('cust', 'CUSTOMER');

        -- update cancelbillrequest table
        UPDATE cancelbillrequest
        SET    random_hash = p_randomHash
        WHERE  cancellation_driver = p_customerRef
        AND    driver_type = 'C'
        AND    random_hash <> p_randomHash;

        -- update customerformattingrequest table
        UPDATE customerformattingrequest
        SET    random_hash = p_randomHash
        WHERE  customer_ref = p_customerRef
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('cust', 'CUSTOMERFORMATTINGREQUEST');

        -- update customerreissuerequest table
        UPDATE customerreissuerequest
        SET    random_hash = p_randomHash
        WHERE  customer_ref = p_customerRef
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('cust', 'CUSTOMERREISSUEREQUEST');

        -- update custproductdiscountusage table
        UPDATE custproductdiscountusage
        SET    random_hash = p_randomHash
        WHERE  customer_ref = p_customerRef
        AND    random_hash <> p_randomHash;
        traceRowsUpdated('cust', 'CUSTPRODUCTDISCOUNTUSAGE');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: encountered error when trying to ' ||
                                 ' update rows for customer ref ' ||
                                 p_customerRef);
            RAISE;
    END changeCustRandomHashValues;

    PROCEDURE commitRandomHashChanges(
        pCustomerRef IN varchar2
        ) IS
    BEGIN
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('INFORM: Committing changes - customer ' ||
                             pCustomerRef);
    END commitRandomHashChanges;

    PROCEDURE rollbackRandomHashChanges(
        pCustomerRef IN varchar2
        ) IS
    BEGIN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('INFORM: Rolling back changes - customer ' ||
                             pCustomerRef || ' - because of error');
    END rollbackRandomHashChanges;

BEGIN
    DBMS_OUTPUT.PUT_LINE('INFORM: Started');

    accReadCount := 0;
    accUpdateCount := 0;
    custReadCount := 0;
    custUpdateCount := 0;

    prevCustRef := CHR(0);

    FOR random_hash_rec IN c_random_hash_changes
    LOOP
        EXIT WHEN c_random_hash_changes%NOTFOUND;

        -- Check if this is a new customer (based on bespoke table not account)
        IF random_hash_rec.customer_ref <> prevCustRef
        THEN
            custReadCount := custReadCount + 1;

            IF prevCustRef <> CHR(0)
            THEN
                IF accErrorForTheCust
                THEN
                    rollbackRandomHashChanges(pCustomerRef => prevCustRef);
                ELSE
                    -- Update previous customer ref if same hash as account
                    IF bothHashesSame
                    THEN
                        changeCustRandomHashValues(
                            p_customerRef => prevCustRef,
                            p_randomHash => prevNewRandomHash);

                        custUpdateCount := custUpdateCount + 1;
                    END IF;

                    -- Commit previous transaction
                    commitRandomHashChanges(pCustomerRef => prevCustRef);
                END IF;
            END IF;

            -- Store current customer reference and reset booleans
            prevCustRef := random_hash_rec.customer_ref;
            prevNewRandomHash := random_hash_rec.random_hash;
            bothHashesSame := NULL;
            accErrorForTheCust := FALSE;

            -- Display message about new customer
            DBMS_OUTPUT.PUT_LINE('INFORM: ----- New Customer: ' ||
                                 random_hash_rec.customer_ref);

            -- Get customer record to check if random hash same as account
            v_cust_random_hash := NULL;
            BEGIN
                SELECT  random_hash
                INTO    v_cust_random_hash
                FROM    customer
                WHERE   customer_ref = random_hash_rec.customer_ref;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('ERROR: no row for customer ' ||
                                         random_hash_rec.customer_ref);
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('ERROR: reading customer ' ||
                                         random_hash_rec.customer_ref);
                    RAISE;
            END;
        END IF;

        -- Increment count of number of accounts read
        accReadCount := accReadCount + 1;

        -- Get account record to check if random hash needs changing
        v_acct_random_hash := NULL;
        BEGIN
            SELECT  random_hash,
                    customer_ref
            INTO    v_acct_random_hash,
                    v_customer_ref
            FROM    account
            WHERE   account_num = random_hash_rec.account_num;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: no row for account ' ||
                                     random_hash_rec.account_num);
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: reading account ' ||
                                     random_hash_rec.account_num);
                RAISE;
        END;

        IF v_acct_random_hash IS NULL
        THEN
            accErrorForTheCust := TRUE;
            DBMS_OUTPUT.PUT_LINE('INFORM: skipping account ' ||
                                 random_hash_rec.account_num);
        ELSIF v_customer_ref <> random_hash_rec.customer_ref
        THEN
            accErrorForTheCust := TRUE;
            DBMS_OUTPUT.PUT_LINE('ERROR: customer ref mismatch on account ' ||
                                 random_hash_rec.account_num ||
                                 ' - expected ' ||
                                 random_hash_rec.customer_ref ||
                                 ' got ' || v_customer_ref);
        ELSIF v_acct_random_hash = random_hash_rec.random_hash
        THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: random_hash OK for account ' ||
                                 random_hash_rec.account_num ||
                                 ' - already set to ' ||
                                 random_hash_rec.random_hash);
        ELSE
            -- Account is OK - now depends on whether customer is OK
            IF v_cust_random_hash IS NULL
            THEN
                accErrorForTheCust := TRUE;
                DBMS_OUTPUT.PUT_LINE('INFORM: skipping account ' ||
                                     random_hash_rec.account_num);
            ELSE
                IF v_cust_random_hash <> v_acct_random_hash
                THEN
                    IF bothHashesSame
                    THEN
                        accErrorForTheCust := TRUE;
                        DBMS_OUTPUT.PUT_LINE('ERROR: for customer ref ' ||
                                             random_hash_rec.customer_ref ||
                                             ' some accounts have same ' ||
                                             ' random hases but others ' ||
                                             ' do not. Cannot cope with this!');
                    ELSE
                        bothHashesSame := FALSE;
                    END IF;
                ELSIF bothHashesSame IS NULL
                THEN
                    bothHashesSame := TRUE;
                END IF;

                DBMS_OUTPUT.PUT_LINE('INFORM: Processing account ' ||
                                     random_hash_rec.account_num);

                changeAccRandomHashValues(
                    p_accountNum => random_hash_rec.account_num,
                    p_randomHash => random_hash_rec.random_hash);

                accUpdateCount := accUpdateCount + 1;

            END IF;
        END IF;

    END LOOP;

    -- Process final customer
    IF prevCustRef <> CHR(0)
    THEN
        IF accErrorForTheCust
        THEN
            rollbackRandomHashChanges(pCustomerRef => prevCustRef);
        ELSE
            -- Update previous customer ref if same hash as account
            IF bothHashesSame
            THEN
                changeCustRandomHashValues(
                    p_customerRef => prevCustRef,
                    p_randomHash => prevNewRandomHash);

                custUpdateCount := custUpdateCount + 1;
            END IF;

            -- Commit previous transaction
            commitRandomHashChanges(pCustomerRef => prevCustRef);
        END IF;
    END IF;

    -- Output totals of work done
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
    DBMS_OUTPUT.PUT_LINE('INFORM: read ' || TO_CHAR(custReadCount) || ' custs');
    DBMS_OUTPUT.PUT_LINE('INFORM: read ' || TO_CHAR(accReadCount) || ' accs');
    DBMS_OUTPUT.PUT_LINE('INFORM: updated ' || TO_CHAR(accUpdateCount) ||
                         ' accs');
    DBMS_OUTPUT.PUT_LINE('INFORM: updated ' || TO_CHAR(custUpdateCount) ||
                         ' custs');
    DBMS_OUTPUT.PUT_LINE('INFORM: finished.');
END;
.
/
prompt End of script

