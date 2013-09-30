
-- --------------------------------------------------------------------
-- Catalog history
-- --------------------------------------------------------------------
select ca.change_dtm, ca.catalogue_change_id ccid, ca.rating_catalogue_id rcid, ca.geneva_user_ora,
    decode(ca.action, 
    1,     'Created.',
    2,     'This catalog copied from.',
    3,     'This catalog copied to.',
    4,     'Imported.',
    5,     'Exported.',
    6,     'Promoted.',
    7,     'Demoted.',
    8,    'Published.',
    9,    'Superseded.',
    10,     'Rejected.',
    11,     'Deleted.',
    12,     'Validated') action,
    decode(ca.from_status,
    1,     'Design',
    2,     'Test',
    3,     'Live',
    4,     'Rejected',
    5,     'Superseded',
    6,     'Deleted',
    7,     'Undefined') from_status,
    decode(ca.to_status,
    1,     'Design',
    2,     'Test',
    3,     'Live',
    4,     'Rejected',
    5,     'Superseded',
    6,     'Deleted',
    7,     'Undefined') to_status    
from catalogueaudit ca
order by ca.change_dtm desc, ca.catalogue_change_id desc;

-- validation errors
select * from catpublishinglog;

-- track tariff_id/product_id combination for each live billing catalog 
-- used to efficiently analyse charges
select * from cataloguetariffaudit cta
order by cta.catalogue_change_id desc, cta.tariff_version desc;

-- live catalogues - one per ICO per currency
select * from cataloguechange cc where cc.catalogue_status=3;

-- --------------------------------------------------------------------
-- custs/products
-- --------------------------------------------------------------------
select ces.customer_ref, ces.event_source, ces.start_dtm, ces.end_dtm, et.event_type_name, ces.product_seq, p.product_name 
from custeventsource ces
    join eventtype et on et.event_type_id=ces.event_type_id 
    join custhasproduct chp on chp.customer_ref=ces.customer_ref
        and chp.product_seq=ces.product_seq
    join product p on p.product_id=chp.product_id
where ces.customer_ref='ST66852524';