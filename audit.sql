-- --------------------------------------------------------------------
-- setup Oracle Standard Auditing
-- --------------------------------------------------------------------
alter system set AUDIT_SYS_OPERATIONS=TRUE scope=spfile;
alter system set AUDIT_TRAIL=DB scope=both;

AUDIT SELECT, INSERT, DELETE ON geneva_admin.CUSTPRODRATINGDISCOUNT BY ACCESS;
AUDIT SELECT, INSERT, DELETE ON geneva_admin.CUSTPRODINVOICEDISCUSAGE BY ACCESS;
AUDIT SELECT, INSERT, DELETE ON geneva_admin.CUSTPRODUCTDISCOUNTUSAGE BY ACCESS;
AUDIT SELECT, INSERT, DELETE ON geneva_admin.ACCOUNT BY ACCESS;
AUDIT SELECT, INSERT, DELETE ON geneva_admin.ACCOUNTRATING BY ACCESS;
AUDIT SELECT, INSERT, DELETE ON geneva_admin.ACCOUNTRATINGSUMMARY BY ACCESS;

-- --------------------------------------------------------------------
-- extract from audit-trail
-- --------------------------------------------------------------------
col name for a10
col action for a14
col USERHOST for a20
col terminal for a12
col CLIENTID for a12
select * from 
    (select substr(userid,1,10) name, substr(name,1,14) action, substr(obj$name,1,40) objName,
    to_char(TIMESTAMP#, 'DDMONYY HH24:MI:SS'), to_char(NTIMESTAMP#, 'DDMONYY HH24:MI:SS'),
    USERHOST, terminal, CLIENTID
    from aud$, audit_actions
    where action = action#
    order by NTIMESTAMP# desc)
where rownum<100;

select * from aud$ where rownum<2;
SELECT * FROM DBA_STMT_AUDIT_OPTS;

-- --------------------------------------------------------------------
-- what is audited?
-- --------------------------------------------------------------------
select * from dba_stmt_audit_opts
union
select * from dba_priv_audit_opts;

-- --------------------------------------------------------------------
-- who can audit?
-- --------------------------------------------------------------------
select *
from dba_sys_privs
where privilege like '%AUDIT%';


-- --------------------------------------------------------------------
-- from Keith G - login attempts
-- --------------------------------------------------------------------

select * from dba_common_audit_trail order by extended_timestamp desc;

select * from dba_audit_session order by extended_timestamp desc;

-- Shows how many failed attempts since successful login of Oracle users:
select * from sys.user$ where lcount > 0;
