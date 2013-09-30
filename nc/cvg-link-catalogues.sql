-------------------------------------------------------------------------------------------------------------
-- Ben Richards, Convergys. 
-- 7th August 2007
-- 
-- This script may be used to create an sql file containing sql inserts to populate 
-- the TARIFFHASRATINGTARIFF table in the Slovak Telecom live environment. This will  
-- avoid the manual billing-to-rating tariff linking required in BCM when a billing & 
-- rating catalogue pair are imported from a test environment.
--  
-- The steps below need to be performed once for each currency for which you want to  
-- import a billing/rating catalogue pair into live from test. 
--   											     	
-- 1) Using BCM in the test environment, export the live billing catalogue for the chosen
--    currency and note it's cataloguechange.catalogue_change_id. This value needs to be 
--    substituted in the select statement below where the value <test_env_bill_cat_id> appears
--
-- 2) Using RCM in the test environment, export the live rating catalogue linked to the  
--    above billing catalogue (ie: cataloguechange.rating_catalogue_id)
--
-- 3) Using BCM and RCM in the live environment, import both the rating and billing catalogues.    
--    Make a note of the new catalogue_change_id assigned to the billing catalogue by the import process.
--    This value needs to be substituted in the select statement where <live_env_bill_cat_id> appears 
--    and also as part of the file name in the spool statement. 
--
-- 4) Using BCM in the live environment, link the the newly imported billing and rating catalogues  
--    (both will be in design mode)
--
-- 5) Once the edits detailed in 1 & 3 are complete, run this script against the test environment 
-- 
-- 6) It will create a new sql file as output THRF_cat_id_<live_env_bill_cat_id>.sql which may be 
--    run against the LIVE environment to populate TARIFFHASRATINGTARIFF for the newly imported catalogue
--    pair.
-- 
-- 7) The catalogues may then be promoted for use in live.
-------------------------------------------------------------------------------------------------------------


set head off
set linesize 300
set feedback off
set pagesize 0

spool THRF_cat_id_<live_env_bill_cat_id>.sql

select 'insert into TARIFFHASRATINGTARIFF values (' || 
tariff_id || ',' || rating_tariff_id || ', <live_env_bill_cat_id>);' 
from tariffhasratingtariff where catalogue_change_id=<test_env_bill_cat_id>;

prompt commit;;

spool off
