spool buffer_pool_allocation.lst
set echo on verify on
set heading off
set pages 0 line 132
--
-- Keep Pool Configuration
--
-- Tables
--
alter table account storage (buffer_pool keep);
alter table accountrating storage (buffer_pool keep);
alter table custeventsource storage (buffer_pool keep);
alter table custhasproduct storage (buffer_pool keep);
alter table custproductdetails storage (buffer_pool keep);
alter table custproductdiscountusage storage (buffer_pool keep);
alter table custproductstatus storage (buffer_pool keep);
alter table eventreservation storage (buffer_pool keep);
alter table custeventsource storage (buffer_pool keep);
alter table accountdetails storage (buffer_pool keep);
alter table accountratingsummary storage (buffer_pool keep);
alter table ratingrevenuesummary storage (buffer_pool keep);
alter table custprodratingdiscount storage (buffer_pool keep);
-- 
-- Indices
--
alter index account_pk storage (buffer_pool keep);
alter index accountrating_pk storage (buffer_pool keep);
alter index accountratingsummary_pk storage (buffer_pool keep);
alter index custeventsource_ak1 storage (buffer_pool keep);
alter index custhasproduct_pk storage (buffer_pool keep);
alter index Custproductdetails_pk storage (buffer_pool keep);
alter index Custproductdiscountusage_ak1 storage (buffer_pool keep);
alter index Custproductstatus_pk storage (buffer_pool keep);
alter index eventreservation_pk storage (buffer_pool keep);
alter index accountdetails_pk storage (buffer_pool keep);
alter index ratingrevenuesummary_ukp storage (buffer_pool keep);
alter index Custprodratingdiscount_ukp storage (buffer_pool keep);
--
-- Recycle Pool
--
--
-- Tables
--
alter table costedevent storage (buffer_pool recycle);
alter table billdata storage (buffer_pool recycle);
--
-- Indices
--
alter index billdata_pk storage (buffer_pool recycle);
alter index costedevent_uk1 storage (buffer_pool recycle);
--
spool off
