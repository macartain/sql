declare
    e_logic_error exception;
    c_logic_error constant pls_integer := -20999;
    pragma exception_init(e_logic_error, -20999);

    e_general_error exception;
    c_general_error constant pls_integer := -20998;
    pragma exception_init(e_general_error, -20998);

    procedure say(p_Message in varchar2) is
    begin
        dbms_output.put_line(p_Message);
    end say;

    procedure resetOne(p_TableName in varchar2,
                       p_SeqName   in varchar2,
                       p_IndexCol  in varchar2) is
        v_IndexName varchar2(30) := upper(p_TableName) || '_PK';
        v_SeqName   varchar2(30) := upper(p_TableName) || 'IDSEQ';
        v_IndexCol  varchar2(30);
        v_CacheSize number;
        v_MaxDB     number;
        v_SeqVal    number;
        v_Diff      number;
    begin
        -- If there is an override for the seq then use it...
        if p_SeqName is not null then
            v_SeqName := upper(p_SeqName);
        end if;
    
        -- Work out the column to do a select max on...
        if p_IndexCol is null then
            begin
                select uic.column_name
                into   v_IndexCol
                from   user_ind_columns uic
                where  uic.index_name = v_IndexName
                and    uic.column_name not like '%CATALOGUE%ID'
                and    uic.column_name != 'START_DAT';
            exception
                when no_data_found then
                    raise_application_error(c_logic_error, 'failed to derive id column for index ' ||
                                             v_IndexName);
                when others then
                    raise_application_error(c_general_error, 'general failure deriving index ' ||
                                             v_IndexName || ' ' ||
                                             sqlerrm);
            end;
        else
            v_IndexCol := upper(p_IndexCol);
        end if;
    
        -- Find the current maximum value...
        begin
            execute immediate 'select nvl( max( ' || v_IndexCol ||
                              ' ), 1) from ' || p_TableName
                into v_MaxDB;
        exception
            when others then
                raise_application_error(c_general_error, 'general failure deriving maximum value of ' ||
                                         v_IndexCol || ' ' ||
                                         sqlerrm);
        end;
    
        -- Store the sequence cache value...
        begin
            select us.cache_size
            into   v_CacheSize
            from   user_sequences us
            where  us.sequence_name = v_SeqName;
        exception
            when others then
                raise_application_error(c_general_error, 'general failure deriving cache of sequence ' ||
                                         v_SeqName || ' ' ||
                                         sqlerrm);
        end;
    
        -- Get the sequence value...
        begin
            execute immediate 'select ' || v_SeqName ||
                              '.nextval from dual'
                into v_SeqVal;
        exception
            when others then
                raise_application_error(c_general_error, 'general failure deriving sequence value for ' ||
                                         v_SeqName || ' ' ||
                                         sqlerrm);
        end;
    
        -- Now set the correct value
        begin
            if v_MaxDB <> v_SeqVal then
                if v_SeqVal <> v_MaxDB + 1 then
                    v_Diff := v_MaxDB + 1;
                    say('Updating ' || v_SeqName || ' from ' || v_SeqVal ||
                        ' to ' || v_Diff);
                end if;
                v_Diff := v_MaxDB - v_SeqVal;
                execute immediate 'alter sequence ' || v_SeqName ||
                                  ' increment by ' || v_Diff || ' nocache';
                execute immediate 'select ' || v_SeqName ||
                                  '.nextval from dual'
                    into v_SeqVal;
                if v_CacheSize > 1 then
                    execute immediate 'alter sequence ' || v_SeqName ||
                                      ' increment by 1 cache ' ||
                                      v_CacheSize;
                else
                    execute immediate 'alter sequence ' || v_SeqName ||
                                      ' increment by 1 nocache';
                end if;
                loop
                    execute immediate 'select ' || v_SeqName ||
                                      '.currval from dual'
                        into v_SeqVal;
                    exit when v_SeqVal >= v_maxDB;
                    execute immediate 'select ' || v_SeqName ||
                                      '.nextval from dual'
                        into v_SeqVal;
                end loop;
            end if;
        exception
            when others then
                raise_application_error(c_general_error, 'general failure resetting sequence ' ||
                                         v_SeqName || ' ' ||
                                         sqlerrm);
        end;
    end resetOne;

    procedure resetOneWrapper(p_TableName in varchar2,
                              p_SeqName   in varchar2 default null,
                              p_IndexCol  in varchar2 default null) is
    begin
        say('Processing ' || p_TableName);
        resetOne(p_TableName, p_SeqName, p_IndexCol);
    exception
        when e_logic_error then
            dbms_output.put_line('Failed on table ' || p_TableName ||
                                 ' with ' || substr(sqlerrm, 12));
        when e_general_error then
            dbms_output.put_line('Failed on table ' || p_TableName ||
                                 ' with ' || sqlerrm);
    end resetOneWrapper;

begin
    /************************************************************************************************
    We proccess each table passed to the resetOneWrapper function.  The following steps are performed
      1.  Derive the primary key: this is tableName_PK {every table conforms to this pattern}
      2.  Based on this primary key we need to work out which of the index columns the sequence
          number is used to populate - we exclude both billing and rating catalogue id and start_dat.
          For some indexes this is not enough so it is possible to specify the specific index column
          to use.
      3.  Based on the index column (either passed in or derived from 2) find the maximum value in
          the database.
      4.  Find the current values from the sequence.  The sequence name defaults to tableNameIDSEQ
          but again can be overridden if the naming doesn't follow the normal pattern.
      5.  If the sequence values and the database values are out of step then update the sequence
          number. We don't drop and recreate it as this invalidates lots of objects but rather just
          change the increment by to move the sequence up or down.
    ************************************************************************************************/
    resetOneWrapper('bandingmodel');
    resetOneWrapper('billdiscount', p_IndexCol => 'bill_discount_id');
    resetOneWrapper('billrun');
    resetOneWrapper('bonusscheme');
    resetOneWrapper('budgetpaymentplan', p_SeqName => 'budgetpayplanidseq');
    resetOneWrapper('chargesegment');
    resetOneWrapper('compositefilter', p_IndexCol => 'composite_filter_id');
    resetOneWrapper('costband');
    resetOneWrapper('costgroup', p_IndexCol => 'costgroup_id');
    resetOneWrapper('costingrules');
    resetOneWrapper('eventclass');
    resetOneWrapper('eventdiscount');
    resetOneWrapper('eventfilter');
    resetOneWrapper('job');
    resetOneWrapper('managedfile');
    resetOneWrapper('modifiergroup');
    resetOneWrapper('package');
    resetOneWrapper('productattribute', p_IndexCol => 'product_attribute_subid');
    resetOneWrapper('productfamily');
    resetOneWrapper('product');
    resetOneWrapper('provisioningsystem');
    resetOneWrapper('ratingtariff');
    resetOneWrapper('ratingtarifftype');
    resetOneWrapper('redemptionoption');
    resetOneWrapper('stepgroup');
    resetOneWrapper('tariff');
    resetOneWrapper('timeratediary');
    resetOneWrapper('timerate');
    resetOneWrapper('usagetype');
    resetOneWrapper('ustproductclass');
end;
