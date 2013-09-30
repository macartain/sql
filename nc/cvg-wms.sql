 select i.item_type as "Item Type",
       to_number(i.item_id) as "Item Number",
       decode(i.status_id,59,'Closed',58,'Complete',40,'Pending',41,'Open',201,'Det_Design',289,'Func_Spec',
                          61,'Cancelled',202,'In-Impl',53,'Intg-Test',207,'Resolve',300,'ST-Assign',
                          182,'T3-Assign',205,'T4-Assign',206,'T4-Analyze',302,'ST-Passed',301,'ST-Testing',
                          183,'T3-Analyze',63,'Hold',161,'T2-Assign',307,'JT-Testing',310,'AT-Testing',
                          55,'Accp-Test',135,'T1-Assign',162,'T2-Analyze') AS "Current Status",
       i.title as "Title",
       i.client_id as "Client",
       i.description as "Description",
       i.root_cause,
       i.resolution,
       i.last_updated_dttm
from oracle.item i
where i.created_dttm > to_date('01/07/04','dd/mm/yy')
--and i.client_id = 'BTWH'
--and product_area_id = 'LKEY'
--and sub_project_code = 'ES36'
and (UPPER(i.description) like UPPER('%&SearchFor%')
  or UPPER(i.root_cause) like UPPER('%&Searchroot%')
  or UPPER(i.resolution) like UPPER('%&Searchres%'))
-- and (UPPER(i.description) like UPPER('%&SearchFor%')
-- and UPPER(i.description) like UPPER('%&SearchFor2%')
-- and UPPER(i.description) like UPPER('%&SearchFor3%'))
order by i.created_dttm;
