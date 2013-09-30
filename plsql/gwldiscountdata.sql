create or replace package gwldiscountdata is

  -- Author  : GLITTLE
  -- Created : 13/01/2011 09:52:16
  -- Purpose : Decode COSTEDEVENT.DISCOUNT_DATA
  e_invalidVersion exception;
  eInvalidDiscountData exception;
  eInvalidDiscountCharacter exception;
  eInvalidElementCount exception;
  
  type t_discountList is varray(7) of varchar2(20);
  type t_discountData is table of t_discountList;

  function decodeDiscountDataAsString(p_discountData COSTEDEVENT.DISCOUNT_DATA%type)
    return varchar2;
  function decodeDiscountData(p_discountData COSTEDEVENT.DISCOUNT_DATA%type)
    return t_discountData;
  function decodeDiscountPeriod(p_discountData COSTEDEVENT.DISCOUNT_DATA%type)
    return varchar2;
  function decodeDiscountLIID(p_discountData COSTEDEVENT.DISCOUNT_DATA%type)
    return varchar2;

  
end gwldiscountdata;
/
create or replace package body gwldiscountdata is

  NUMLOOKUP             constant varchar2(64) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  SUPPORTED_VERSION_1   constant varchar2(2) := '01';
  SUPPORTED_VERSION_2   constant varchar2(2) := '02';
  DISC_SEP              constant varchar2(1) := ';';
  NUM_SEP               constant varchar2(1) := ',';

  DISCOUNT_TYPES constant t_discountList := t_discountList(
    'PS',
    'Eid',
    'Per',
    'DUsg',
    'DMny',
    'TUsg',
    'xBid');
  
  function decodeOneCharacter(p_char in varchar2, p_power in pls_integer)
    return pls_integer is
  begin -- Encoded in Base 64
    return 64**p_power * (instr(NUMLOOKUP, p_char) - 1);
  end decodeOneCharacter;

  function decodeOneNum ( p_num in varchar2 ) return pls_integer is
    vPower pls_integer := 0;
    vNum pls_integer := 0;
  begin -- Loop round each digit and calcuate its value
    if p_num is null then
      return 0;
    end if;
    
    for i in reverse 1..length( p_num )
    loop
      -- Power initially zero for last 'digit'
      vNum := vNum + decodeOneCharacter ( substr( p_num, i, 1 ), vPower );
      vPower := vPower + 1;
    end loop;
    return vNum;
  end decodeOneNum;
  
  function decodeDiscountSet ( p_version in varchar2, p_discountSet in varchar2 ) return t_discountList
  is
    v_discountSet varchar2(100);
    v_discountCount pls_integer := 1;
--    v_discount varchar2(400);
--    v_decodedNumber varchar2(20);
    v_result t_discountList := t_discountList('','','','','','','');
  begin
    
    -- like we did for the discount set, add a closing delimeter and space so
    -- the final discount isn't a special case.
    -- Also, track our progress through the string in a local variable
    v_discountSet := p_discountSet || NUM_SEP || ' ';

    while instr(v_discountSet, NUM_SEP) > 0
    loop
      -- Decode one number up to first , {comma}
      v_result(v_discountCount) := to_char(
        decodeOneNum(
          substr(v_discountSet,
            1,
            instr( v_discountSet, NUM_SEP ) - 1)),
        'FM999999999999999999');
        
      -- move to next discount and increment count
      v_discountSet := substr( v_discountSet,
                         instr( v_discountSet, NUM_SEP ) + 1); 
      v_discountCount := v_discountCount + 1;
    end loop;
    v_discountCount := v_discountCount - 1;
    
    if ( p_version = SUPPORTED_VERSION_1 and v_discountCount <> 6 )
    or ( p_version = SUPPORTED_VERSION_2 and v_discountCount <> 7 ) then
      raise eInvalidElementCount;
    end if;
    
    return v_result;
  exception
    when SUBSCRIPT_BEYOND_COUNT then
      raise eInvalidElementCount;
    when others then
      raise;
  end decodeDiscountSet;

  function discountList2String(p_discountList t_discountList) return varchar2 is
    v_string varchar2(400);
  begin
    v_string := '{ ps ' || p_discountList(1) ||
      ' eid ' || p_discountList(2) ||
      ' prd ' || p_discountList(3) ||
      ' dusg ' || p_discountList(4) ||
      ' dmny ' || p_discountList(5) ||
      ' tusg ' || p_discountList(6) ||
      ' liid ' || p_discountList(7) || ' }';
    return v_string;
  end discountList2String;
  
  function decodeDiscountPeriod(p_discountData COSTEDEVENT.DISCOUNT_DATA%type)
    return varchar2 is
    v_version varchar2(2);
    v_discountData COSTEDEVENT.DISCOUNT_DATA%type;
    v_discountList t_discountList;
  begin
    if p_discountData is null then
      return null;
    end if;

    -- use a local variable to track our progress through the data
    v_discountData := p_discountData;
    
    -- parse out the first two characters proceeded by a colon to get the
    -- version.
    v_version := substr( v_discountData, 1, instr( v_discountData, ':' ) - 1 );
  
    if v_version <> SUPPORTED_VERSION_1 and v_version <> SUPPORTED_VERSION_2 then
      raise e_invalidVersion;
    end if;   
      
    -- start processing from position 4. 
    -- Also add a closing delimiter so that the final discount set isn't a special case.
    -- Also add a terminating space so that we still have an empty string upon completion.
    v_discountData := substr( v_discountData, 4) || DISC_SEP || ' ';
    
    -- only do the first discount set
    -- Decode one set of discount data (up to first ;) and add it to the result
    v_discountList := decodeDiscountSet(v_version, substr ( v_discountData, 1, instr( v_discountData, DISC_SEP ) - 1 ) );

    return v_discountList(3);

--  exception 
--    when eInvalidDiscountData then
--      return 'Unable to decode discount data';
--    when eInvalidDiscountCharacter then
--      return 'Invalid discount character';
--    when eInvalidElementCount then
--      return 'Invalid count of discount elements';
--    when others then 
--      return 'Unknow error: ' || sqlerrm;
  end;    
    
  function decodeDiscountLIID(p_discountData COSTEDEVENT.DISCOUNT_DATA%type)
    return varchar2 is
    v_version varchar2(2);
    v_discountData COSTEDEVENT.DISCOUNT_DATA%type;
    v_discountList t_discountList;
  begin
    if p_discountData is null then
      return null;
    end if;

    -- use a local variable to track our progress through the data
    v_discountData := p_discountData;
    
    -- parse out the first two characters proceeded by a colon to get the
    -- version.
    v_version := substr( v_discountData, 1, instr( v_discountData, ':' ) - 1 );
  
    if v_version <> SUPPORTED_VERSION_1 and v_version <> SUPPORTED_VERSION_2 then
      raise e_invalidVersion;
    end if;   
      
    -- start processing from position 4. 
    -- Also add a closing delimiter so that the final discount set isn't a special case.
    -- Also add a terminating space so that we still have an empty string upon completion.
    v_discountData := substr( v_discountData, 4) || DISC_SEP || ' ';
    
    -- only do the first discount set
    -- Decode one set of discount data (up to first ;) and add it to the result
    v_discountList := decodeDiscountSet(v_version, substr ( v_discountData, 1, instr( v_discountData, DISC_SEP ) - 1 ) );

    return v_discountList(7);

--  exception 
--    when eInvalidDiscountData then
--      return 'Unable to decode discount data';
--    when eInvalidDiscountCharacter then
--      return 'Invalid discount character';
--    when eInvalidElementCount then
--      return 'Invalid count of discount elements';
--    when others then 
--      return 'Unknow error: ' || sqlerrm;
  end;    
    
  function decodeDiscountData(p_discountData COSTEDEVENT.DISCOUNT_DATA%type)
    return t_discountData is
    v_version varchar2(2);
    v_discountData COSTEDEVENT.DISCOUNT_DATA%type;
    v_result t_discountData := t_discountData();
    v_count pls_integer := 1;
    v_discountList t_discountList;
  begin
    if p_discountData is null then
      return null;
    end if;

    -- use a local variable to track our progress through the data
    v_discountData := p_discountData;
    
    -- parse out the first two characters proceeded by a colon to get the
    -- version.
    v_version := substr( v_discountData, 1, instr( v_discountData, ':' ) - 1 );
  
    if v_version <> SUPPORTED_VERSION_1 and v_version <> SUPPORTED_VERSION_2 then
      raise e_invalidVersion;
    end if;   
      
    -- start processing from position 4. 
    -- Also add a closing delimiter so that the final discount set isn't a special case.
    -- Also add a terminating space so that we still have an empty string upon completion.
    v_discountData := substr( v_discountData, 4) || DISC_SEP || ' ';
    
    while instr(v_discountData, DISC_SEP) > 0
    loop
      -- Decode one set of discount data (up to first ;) and add it to the result
      v_discountList := decodeDiscountSet(v_version, substr ( v_discountData, 1, instr( v_discountData, DISC_SEP ) - 1 ) );
      v_result.extend(v_count);
      v_result(v_count) := v_discountList;

      -- now move to the next discount set (if any)
      v_discountData := substr( v_discountData, instr( v_discountData, DISC_SEP ) + 1 ); -- chop off the processed discount
      v_count := v_count + 1;
    end loop;

    dbms_output.put_line('About to return list of length ' || v_result.count);
    return v_result;

--  exception 
--    when eInvalidDiscountData then
--      return 'Unable to decode discount data';
--    when eInvalidDiscountCharacter then
--      return 'Invalid discount character';
--    when eInvalidElementCount then
--      return 'Invalid count of discount elements';
--    when others then 
--      return 'Unknow error: ' || sqlerrm;
  end;    

  function decodeDiscountDataAsString(p_discountData COSTEDEVENT.DISCOUNT_DATA%type)
    return varchar2 is
    v_version varchar2(2);
    v_discountData COSTEDEVENT.DISCOUNT_DATA%type;
    v_count pls_integer := 1;
    v_result varchar2(4096);
  begin
    if p_discountData is null then
      return null;
    end if;

    -- use a local variable to track our progress through the data
    v_discountData := p_discountData;
    
    -- parse out the first two characters proceeded by a colon to get the
    -- version.
    v_version := substr( v_discountData, 1, instr( v_discountData, ':' ) - 1 );
  
    if v_version <> SUPPORTED_VERSION_1 and v_version <> SUPPORTED_VERSION_2 then
      raise e_invalidVersion;
    end if;   
      
    -- start processing from position 4. 
    -- Also add a closing delimiter so that the final discount set isn't a special case.
    -- Also add a terminating space so that we still have an empty string upon completion.
    v_discountData := substr( v_discountData, 4) || DISC_SEP || ' ';
    
    while instr(v_discountData, DISC_SEP) > 0
    loop
      -- Decode one set of discount data (up to first ;) and add it to the result
      v_result := v_result || discountList2String(decodeDiscountSet(v_version, substr ( v_discountData, 1, instr( v_discountData, DISC_SEP ) - 1 ) ) );

      -- now move to the next discount set (if any)
      v_discountData := substr( v_discountData, instr( v_discountData, DISC_SEP ) + 1 ); -- chop off the processed discount
      v_count := v_count + 1;
    end loop;

    return v_result;

--  exception 
--    when eInvalidDiscountData then
--      return 'Unable to decode discount data';
--    when eInvalidDiscountCharacter then
--      return 'Invalid discount character';
--    when eInvalidElementCount then
--      return 'Invalid count of discount elements';
--    when others then 
--      return 'Unknow error: ' || sqlerrm;
  end;    

end gwldiscountdata;
/
