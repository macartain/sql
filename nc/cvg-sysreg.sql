-- --------------------------------------------------------------------
-- Show whole registry
-- --------------------------------------------------------------------
set pages 0
set lines 180
col name for a65
col value for a65
select id,parent_id,level,lpad(' ',(level-1)*2)||substr(name,1,40) as "name",
 to_char(substr(value,1,50)) as "value"
from ipf_admin.systemregistryentry
start with parent_id is null
connect by prior id = parent_id;

-- george version:

select id, '|',
       parent_id, '|',
       level, '|',
       level || lpad(' ',(level-1)*2)||substr(name,1,40) as "lookupkey",   '|',
       lpad(' ',(level-1)*2)||substr(name,1,40) as "name",  '|',
       to_char(substr(value,1,50)) as "value"
from ipf_admin.systemregistryentry
start with parent_id is null
connect by prior id = parent_id;  

-- --------------------------------------------------------------------
-- Parameters
-- --------------------------------------------------------------------
set pages 0
set lines 180
col name for a65
col value for a65
select id,parent_id,level,lpad(' ',(level-1)*2)||substr(name,1,40) as "name",
 to_char(substr(value,1,50)) as "value"
 from systemregistryentry where parent_id in (select id from systemregistryentry where name like '%arameter%')
 start with parent_id is null
connect by prior id = parent_id;

-- --------------------------------------------------------------------
-- Show tree for an item
-- --------------------------------------------------------------------
col context for a90
select * from ipf_admin.pvsysregcontextvalue
where upper(context) like '%PF_SEC_SCHEMA%'

-- --------------------------------------------------------------------
-- Show logging entries
-- --------------------------------------------------------------------
select id,lpad(' ',(level-1)*3)||substr(name,1,40) as "name",
 to_char(substr(value,1,50)) as "value"
from ipf_admin.systemregistryentry
start with parent_id = -2 and name = 'platform'
connect by prior id = parent_id;

-- --------------------------------------------------------------------
-- Show encryption entries
-- --------------------------------------------------------------------
select id,parent_id,level,lpad(' ',(level-1)*2)||substr(name,1,40) as "name",
 to_char(substr(value,1,50)) as "value"
from ipf_admin.systemregistryentry
start with name = 'Security' and parent_id=-2
connect by prior id = parent_id;

SELECT * FROM IPF_ADMIN.SYSTEMREGISTRYENTRY 
       WHERE NAME IN ('RB_HOLDINGACCOUNT_BANK_ACCOUNT_NUMBER',
                                         'RB_PRMANDATE_BANK_ACCOUNT_NUMBER',
                                         'RB_PRMANDATE_CARD_NUMBER',
                                         'EncryptionEnabled');

select * from ipf_admin.pvsysregcontextvalue sr
where sr.context like '%EncryptionEnabled%';

select * from ipf_admin.pvsysregcontextvalue sr

where lower(sr.context) like '%encrypt%';
select * from ipf_admin.systemregistryentry where lower(name) like '%encrypt%';

-- --------------------------------------------------------------------
-- disable encryption 
-- --------------------------------------------------------------------
--AS IPF_ADMIN!!
call data_security_mask.deleteMaskedField_1('RB_HOLDINGACCOUNT_BANK_ACCOUNT_NUMBER','Installer');
call data_security_mask.deleteMaskedField_1('RB_PRMANDATE_BANK_ACCOUNT_NUMBER','Installer');
call data_security_mask.deleteMaskedField_1('RB_PRMANDATE_CARD_NUMBER','Installer');

call data_security_mask.addMaskedField_1('RB_HOLDINGACCOUNT_BANK_ACCOUNT_NUMBER','false','FROM_RIGHT', 4,'*','Installer');
call data_security_mask.addMaskedField_1('RB_PRMANDATE_BANK_ACCOUNT_NUMBER','false','FROM_RIGHT', 4,'*','Installer');
call data_security_mask.addMaskedField_1('RB_PRMANDATE_CARD_NUMBER','false','FROM_RIGHT', 4,'*','Installer');

-- --------------------------------------------------------------------
-- Show version entries
-- --------------------------------------------------------------------
select id,parent_id,level,lpad(' ',(level-1)*2)||substr(name,1,40) as "name",
 to_char(substr(value,1,50)) as "value"
from ipf_admin.systemregistryentry
start with name = 'currentDatabaseVersion'
connect by prior id = parent_id;

col context for a90
select * from ipf_admin.pvsysregcontextvalue
where context like '%current%Version%';

-- sumit's
select substr(b.name,1,40)||':'||substr(c.name,1,40) PRODUCT, to_char(c.value) Value 
from ipf_admin.systemregistryentry a, ipf_admin.systemregistryentry b, ipf_admin.systemregistryentry c  
where a.name = 'Installed' 
and a.id = b.parent_id 
and b.id = c.parent_id 
and c.name in ('currentDatabaseVersion','currentSoftwareVersion') 
order by 1; 

select * from inf_admin.infinys_components;

select * from systemregistryentry where name like '%urrent%';

sysreg_db_version.ksh -c ipf_admin/ipf_admin -C PF -r

-- --------------------------------------------------------------------
-- Create entry
-- --------------------------------------------------------------------
set serveroutput on
declare
   new_version number ;
   oldvalue    clob ;
begin
   sysreg.writeValue_1('IPF_ADMIN', '/Infinys/Platform/Security/ExternalRealmType','authnOnly', null, oldvalue, new_version);
   dbms_output.put_line('New version : ' || new_version);
end;
/

-- --------------------------------------------------------------------
-- Install state stuff
-- --------------------------------------------------------------------
col BUILD_FILE_NAME for a15
col TASK_TYPE_NAME for a35
col TASK_STRING for a30
col TASK_IDENTIFIER for a10
col INSTALLABLE_NAME for a8
col BUILD_FILE_SEQ_NUM for 9999
col TASK_SEQ_NUM for 9999
col TASK_EXECUTION_SEQ_NUM for 9999
col COMMAND_SEQ_NUM for 9999
col tstate for 999
select t.*, ts.TASK_STATE_IND tstate
from ipf_admin.pf_task t, ipf_admin.pf_task_state ts
where t.task_seq_num=ts.task_seq_num
and t.installable_name='RB'
;

col start_time for a18 trunc
col fin_time for a18 trunc
col RET for 999
col TASK_EXECUTION_STRING for a40 wrap
col STDOUT_STRING for a50 wrap
col STDERR_STRING for a20 wrap
select TO_CHAR(START_TMSTMP,'DDMONYYYY-HH24:MI:SS') start_time, TO_CHAR(END_TMSTMP,'DDMONYYYY-HH24:MI:SS') fin_time, TASK_RETURN_CD RET,
TASK_EXECUTION_STRING, STDOUT_STRING, STDERR_STRING
from ipf_admin.PF_TASK_EXECUTION
order by END_TMSTMP asc;

col SCRIPTNAME for a25
col LASTMESSAGE for a65
select SCRIPTNAME, STEPNAME, BEFOREAFTER, LASTMESSAGE, RUNNUMBER from migrationprocess;

col start_time for a18 trunc
col fin_time for a18 trunc
col RET for 999
col TASK_EXECUTION_STRING for a40 wrap
col STDOUT_STRING for a100 wrap
select 
    TO_CHAR(START_TMSTMP,'DDMONYYYY-HH24:MI:SS') start_time, 
    TO_CHAR(END_TMSTMP,'DDMONYYYY-HH24:MI:SS') fin_time, 
    TASK_RETURN_CD RET,
    TASK_EXECUTION_STRING,
    STDOUT_STRING
from PF_TASK_STATE  ts
    join PF_TASK_EXECUTION te on ts.TASK_SEQ_NUM=ts.TASK_SEQ_NUM
        and ts.TASK_EXECUTION_SEQ_NUM = te.TASK_EXECUTION_SEQ_NUM
        and ts.COMMAND_SEQ_NUM= te.COMMAND_SEQ_NUM
where TASK_STATE_IND != 0 
order by START_TMSTMP;

-- fix an interrupted db_migrate_menu
select * from ipf_admin.systemregistryentry where value like '%started%';
update ipf_admin.systemregistryentry set value='failed' where ID in (11465, 11467);

-- --------------------------------------------------------------------
-- Performance log stuff
-- --------------------------------------------------------------------
col buckets for a45
col category for a45
select * from ipf_admin.PF_PERFORMANCE_LOG_CONFIG;

-- remove any current entries
truncate table ipf_admin.PF_PERFORMANCE_LOG_CONFIG;

-- suppress detail logging
insert into ipf_admin.PF_PERFORMANCE_LOG_CONFIG
(CATEGORY, TIME_INTERVAL, BUCKETS, ENABLE_DETAIL_LOG,ENABLE_AGGREGATE_LOG)
values ('vpa',0,'1/2/3/4/5','N','N');

-- --------------------------------------------------------------------
-- Cloning stuff
-- --------------------------------------------------------------------
select * from ipf_admin.systemregistryentry where name like '%ORA%';
select * from ipf_admin.systemregistryentry where name like '%ROOT%';
select * from ipf_admin.systemregistryentry where name like '%HOST%';

select substr(b.name,1,40)||':'||substr(c.name,1,40) PRODUCT, to_char(c.value) Value
from ipf_admin.systemregistryentry a, ipf_admin.systemregistryentry b, ipf_admin.systemregistryentry c
where a.name = 'Installed'
and a.id = b.parent_id
and b.id = c.parent_id
and c.name in ('currentDatabaseVersion','currentSoftwareVersion')
order by 1;
