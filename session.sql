set pages 200
set lines 180
col user for a13
col osuser for a14
COL "SID,serial" FOR A10
col status FOR a10
COL "OS PID" FOR A12
COL PROGRAM FOR A35

SELECT nvl(vs.username, '-') "user", osuser, vs.sid||','||vs.serial# "SID,serial", process "OS PID", vs.PROGRAM, type, status, vp.spid "bg OS PID", 
TO_CHAR(LOGON_TIME,'dd/mm hh24:mm:ss') logon
from v$session vs full outer join v$process vp
on vs.paddr = vp.addr
where type != 'BACKGROUND'
and vs.program not like '%(J0%)'
order by LOGON_TIME desc
/

TM -u geneva_admin -p geneva_admin -s RBM115

TMsystemMonitorPort

update geneva_admin.gparams set integer_value=3031 where name='TMsystemMonitorPort';

update GPARAMS set name='##SYSdateOverride' where name='SYSdateOverride';
update GPARAMS set name='##SYSdateValue' where name='SYSdateValue';


NAME         TYPE   START_DTM STRING_VALUE  INTEGER_VALUE
---------------------------------------------------------------- -------- --------- -------------------- -------------
REMclientPort        INTEGER  01-JAN-98      3304
SYSalternateReportPath       STRING   01-JAN-98
CEMreportProgressPerEvents      INTEGER  06-DEC-12         0
COLLportNum        INTEGER  06-DEC-12
TMchildProcessPort       INTEGER  01-JAN-98      3307
TMsystemMonitorPort       INTEGER  01-JAN-98      7016
TRDclientPort        INTEGER  01-JAN-98      3303
BGmaxReportDuplicates       INTEGER  01-JAN-98        50
FIDimportRetryCount       INTEGER  01-JAN-98
BGuseOwningProdCpsApportionedBoo     STRING   01-JAN-98 T
BGratingOnlyBillsProgressReportNum     INTEGER  01-JAN-98      1000
TariffOverrideReportCc       STRING   01-JAN-98 sanjit.joseph@virgin
              media.co.uk,stuart.s
              mith3@virginmedia.co
              .uk

TariffOverrideReportTo       STRING   01-JAN-98 twbusdataint@telewes
              t.co.uk

SYSreportDataOutputLocation      STRING   06-DEC-12
RRTMCommPort        INTEGER  06-DEC-12
SYSeventDispatchExporter      INTEGER  06-DEC-12         0

