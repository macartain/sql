ncreate or replace function DiscountData ( pDiscountData in varchar2 )
  return varchar2
is

/*
  Version 2.0 - Works with discount data Versions '01' and '02'
*/

  type tNumberByChar is table of number index by varchar2(1);
  vNumLookup tNumberByChar;
  vLocalDD costedevent.discount_data%type;
  vResult varchar2(4000);
  vDiscCnt pls_integer := 1;
  vVersion varchar2(2);
  
  SUPPORTED_VERSION_1 constant varchar2(2) := '01';
  SUPPORTED_VERSION_2 constant varchar2(2) := '02';
  DISC_SEP constant varchar2(1) := ';';
  NUM_SEP constant varchar2(1) := ',';
  
  eInvalidDiscountData exception;
  eInvalidDiscountCharacter exception;
  eInvalidElementCount exception;

  procedure fillArray
  is
  begin
    for i in 0..25 -- A to Z 
    loop vNumLookup( chr( i + 65 ) ) := vNumLookup.count; -- A ascii 65
    end loop;

    for i in 0..25 -- a to z 
    loop vNumLookup( chr( i + 97 ) ) := vNumLookup.count; -- a ascii 97
    end loop;

    for i in 0..9 -- 0 to 9
    loop vNumLookup( chr( i + 48 ) ) := vNumLookup.count; -- 0 ascii 48
    end loop;

    vNumLookup( '+' ) := vNumLookup.count; -- Final two values
    vNumLookup( '/' ) := vNumLookup.count;
  end fillArray;

  
  function decodeOneNum ( pOneNum in varchar2 )
    return pls_integer
  is
    vPower pls_integer := 0;
    vNum pls_integer := 0;
    function decodeOneCharacter ( pOneChar in varchar2,
                                  pPower in pls_integer
                                 )
      return pls_integer
    is
    begin -- Encoded in Base 64
      return 64**pPower * vNumLookup(pOneChar);
    exception
      when no_data_found then
        raise eInvalidDiscountCharacter;
    end decodeOneCharacter;
  
  begin -- Loop round each digit and calcuate its value
    if pOneNum is null then
      --raise eInvalidDiscountData;
      return 0;
    end if;
    
    for i in reverse 1..length( pOneNum )
    loop
      -- Power initially zero for last 'digit'
      vNum := vNum + decodeOneCharacter ( substr( pOneNum, i, 1 ), vPower );
      vPower := vPower + 1;
    end loop;
    return vNum;
  end decodeOneNum;

  
  function oneDiscount ( pSingleDiscount in varchar2 )
    return varchar2
  is
    vSingleDiscount varchar2(100);
    vElementCount pls_integer := 1;
    vSingleDisc varchar2(400);
    vOneNum varchar2(20);
  begin
    vSingleDiscount := pSingleDiscount || NUM_SEP || ' '; -- Make sure each discount set enclosed in ,
    loop
      -- Decode one number up to first , {comma}
      vOneNum := to_char ( decodeOneNum ( substr( vSingleDiscount,
                                                  1,
                                                  instr( vSingleDiscount, NUM_SEP ) - 1
                                                 )
                                         ), 'FM999999999999999999'
                          );
      case vElementCount -- Dependant on order interpret the number as...
        when 1 then vSingleDisc := 'PS:' || vOneNum;
        when 2 then vSingleDisc := vSingleDisc || ' Eid:' || vOneNum;
        when 3 then vSingleDisc := vSingleDisc || ' Per:' || vOneNum;
        when 4 then vSingleDisc := vSingleDisc || ' DUsg:' || vOneNum;
        when 5 then vSingleDisc := vSingleDisc || ' DMny:' || vOneNum;
        when 6 then vSingleDisc := vSingleDisc || ' TUsg:' || vOneNum;
        when 7 then vSingleDisc := vSingleDisc || ' xBid:' || vOneNum;
        else raise eInvalidElementCount;
      end case;
      vSingleDiscount := substr( vSingleDiscount, 
                                 instr( vSingleDiscount, NUM_SEP ) + 1 
                                ); -- Chop off processed number
      exit when instr( vSingleDiscount, NUM_SEP ) = 0;
      vElementCount := vElementCount + 1;
    end loop;
    
    if ( vVersion = SUPPORTED_VERSION_1 and vElementCount <> 6 )
    or ( vVersion = SUPPORTED_VERSION_2 and vElementCount <> 7 ) then
      raise eInvalidElementCount;
    end if;
    
    return vSingleDisc;
  end oneDiscount;
  
begin
  if pDiscountData is null then
    return null;
  end if;

  fillArray;
  vLocalDD := pDiscountData;
  vVersion := substr( vLocalDD, 1, instr( vLocalDD, ':' ) - 1 );
  
  if vVersion = SUPPORTED_VERSION_1 or vVersion = SUPPORTED_VERSION_2 then
    vLocalDD := substr( vLocalDD, 4) || DISC_SEP || ' '; -- Make sure each discount set enclosed in ; 
                                                         -- ( add space to ensure string does not become null 
                                                         --   after removing a set of discount data )
    vResult := '{d' || to_char( vDiscCnt, 'FM9999') || ': ';
    loop
      -- Decode one set of discount data (up to first ;) and add it to the result
      vResult := vResult || oneDiscount( substr ( vLocalDD, 1, instr( vLocalDD, DISC_SEP ) - 1 ) );
      vLocalDD := substr( vLocalDD, instr( vLocalDD, DISC_SEP ) + 1 ); -- chop off the processed discount
      exit when instr( vLocalDD, DISC_SEP ) = 0; -- if no discount left then finish
      vDiscCnt := vDiscCnt + 1;
      vResult := vResult || '} {d' || to_char( vDiscCnt, 'FM9999') || ': ';
    end loop;
    vResult := vResult || '}';
    return vResult;
  else
    return ( 'Unknown version: ' || substr( vLocalDD, 1, instr( vLocalDD, ':') ) );
  end if;

exception 
  when eInvalidDiscountData then
    return 'Unable to decode discount data';
  when eInvalidDiscountCharacter then
    return 'Invalid discount character';
  when eInvalidElementCount then
    return 'Invalid count of discount elements';
  when others then 
    return 'Unknow error: ' || sqlerrm;
/* Schema Definition of Discount Data
discount_data  varchar2(523) null

Holds concatenated discount unloading information for at least 9 rating-time discounts. The discount unloading information that is stored consists of (per discount applied to the event): 
The product_seq of the CustProductDiscountUsage bucket to which this event usage contributed. 
The event_discount_id of the discount that was applied. 
The period_num of the CustProductDiscountUsage bucket to which this event usage contributed. 
The discount usage contribution for this event, which is the portion of 
CustProdInvoiceDiscUsage.total_discounted_usage due to this event-discount combination. 
The discount mny contribution for this event, which is the portion of 
CustProdInvoiceDiscUsage.total_discounted_mny due to this event-discount combination. 
The total usage contribution for this event, which is the portion of 
CustProdInvoiceDiscUsage.total_usage due to this event-discount combination. 
external_balance_liid of the discount or counter. This can be specified as 0 to indicate that the value is unknown. 
Attributes are encoded in base64 format, using the characters "A-Za-z0-9+/", and are then concatenated in their specified order using a comma separator character. The whole set of concatenated data is also prefixed by a version number for the discount_data storage format. The version number can be up to two characters long and is terminated by a colon. 
Here is an example field: 02:C,6,B,Es,1,Zo,A;C,6,B,zk,F0,Zo,A
*/ 

end DiscountData;
/
