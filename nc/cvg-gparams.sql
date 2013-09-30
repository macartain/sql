-- --------------------------------------------------------------------
-- show gparams
-- --------------------------------------------------------------------
set pages 800
set lines 180
col STRING_VALUE for a65
col name for a65
select name, STRING_VALUE, INTEGER_VALUE
from gparams
order by name;

-- --------------------------------------------------------------------
-- to export to csv
-- --------------------------------------------------------------------
select name || ',' || STRING_VALUE || ',STRING,' || TO_CHAR(START_DTM, 'DD/MM/YYYY') || ',' || TO_CHAR(START_DTM, 'HH24:MI:SS')
from gparams
where TYPE='STRING'
union
select name || ',' || INTEGER_VALUE || ',INTEGER,' || TO_CHAR(START_DTM, 'DD/MM/YYYY') || ',' || TO_CHAR(START_DTM, 'HH24:MI:SS')
from gparams
where TYPE='INTEGER';

-- --------------------------------------------------------------------
-- common tasks
-- --------------------------------------------------------------------
update gparams set STRING_VALUE='1,2,3,4,5,6,11' where name='IPGbonusReasonIds';

INSERT INTO GPARAMS ( NAME,TYPE,START_DTM,STRING_VALUE,INTEGER_VALUE )
VALUES ( 'SYSdateOverride','STRING', TO_DATE( '01/01/2001 12:00:00 AM','MM/DD/YYYY HH:MI:SS AM'),'ANY',NULL);
INSERT INTO GPARAMS ( NAME,TYPE,START_DTM,STRING_VALUE,INTEGER_VALUE )
VALUES ( 'SYSdateValue','STRING', TO_DATE( '01/01/2001 12:00:00 AM','MM/DD/YYYY HH:MI:SS AM'),'20080801 120000',NULL);
export PF_FIXEDDATE='20080801 12000000'

INSERT INTO GPARAMS ( NAME,TYPE,START_DTM,STRING_VALUE,INTEGER_VALUE )
VALUES ( 'TMimageDir','STRING', TO_DATE( '01/01/2009 12:00:00 AM','MM/DD/YYYY HH:MI:SS AM'),'/emea/ipg/working/VDSI4102/infroot/RB/bin',NULL);

update gparams set NAME='xxSYSdateOverride' where name='SYSdateOverride';
update gparams set NAME='xxSYSdateValue' where name='SYSdateValue';

INSERT INTO GPARAMS ( NAME,TYPE,START_DTM,STRING_VALUE,INTEGER_VALUE )
VALUES ( 'TMnumStatusMessages','INTEGER', TO_DATE( '01/01/2013 12:00:00 AM','MM/DD/YYYY HH:MI:SS AM'),NULL,20);

select * from  gparams where name like '%hostMachine%';

update geneva_admin.gparams set string_value='hocpi03n'
where name in ('TMhostMachineName', 'TRDhostMachineName', 'REMhostMachineName');

update geneva_admin.gparams set integer_value=20 where name='TMnumStatusMessages';

update geneva_admin.gparams set integer_value=3060 where name='TMchildProcessPort';
update geneva_admin.gparams set integer_value=3061 where name='TMsystemMonitorPort';
update geneva_admin.gparams set integer_value=3062 where name='TRDclientPort';
update geneva_admin.gparams set integer_value=3063 where name='REMclientPort';

update gparams set string_value='/Disk1/home/vod2201/work/bin' where name ='TMimageDir';

update GPARAMS set STRING_VALUE=replace(STRING_VALUE,'/Disk1/home/vod2207','//Disk1/home/vod2201');
update filegroup set TARGET_DIRECTORY=replace(TARGET_DIRECTORY,'/Disk1/home/vod2207','//Disk1/home/vod2201');
update processplan set parameters=replace(parameters,'/data/antillia','/psg/working/BTRETSI2/INF_ROOT/RB');

update GPARAMS set STRING_VALUE=replace(STRING_VALUE,'/data/antillia','/psg/working/BTRETSI2/INF_ROOT/RB');

