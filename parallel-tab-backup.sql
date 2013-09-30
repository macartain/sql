-- --------------------------------------------------------------------
-- Backup - IRB tables
-- --------------------------------------------------------------------
-- NOte - be careful tab names are not too long
--

prompt Starting bundlesync tables backup
select systimestamp from dual;
set timing on

create table ipgsrcbsextract_bsrun1 parallel (degree 8)
tablespace users
as select * from ipgsrcbundlesyncextract;

create table ipgdestbsextract_bsrun1 parallel (degree 8)
tablespace users
as select * from ipgdestbundlesyncextract;

create table ipgbcomparison_bsrun1 parallel (degree 8)
tablespace users
as select * from ipgbundlecomparison;

create table ipgsynclog_bsrun1 parallel (degree 8)
tablespace users
as select * from ipgsynclog;

create table ipgwklysmscompdiscs_bsrun1 parallel (degree 8)
tablespace users
as select * from ipgwklysmscompdiscs;

create table ipgsyncexcludeddiscs_bsrun1 parallel (degree 8)
tablespace users
as select * from ipgsyncexcludeddiscs;

prompt Done.
select systimestamp from dual;
exit;

-- --------------------------------------------------------------------
-- Truncate - IRB tables
-- --------------------------------------------------------------------
prompt Starting bundlesync tables truncate
select systimestamp from dual;
set timing on

truncate table ipgsrcbundlesyncextract reuse storage;
truncate table ipgdestbundlesyncextract reuse storage;
truncate table ipgbundlecomparison reuse storage;
truncate table ipgsynclog reuse storage;
truncate table ipgwklysmscompdiscs reuse storage;
truncate table ipgsyncexcludeddiscs reuse storage;

prompt Done.
select systimestamp from dual;
exit;

-- --------------------------------------------------------------------
-- Backup - 5.3 tables
-- --------------------------------------------------------------------
prompt Starting bundlesync tables backup
select systimestamp from dual;
set timing on

create table ipgsrcbsextract_bsrun1 parallel (degree 4)
tablespace users
as select * from ipgsrcbundlesyncextract;

create table ipgsynclog_bsrun1 parallel (degree 4)
tablespace users
as select * from ipgsynclog;

create table ipgwklysmscompdiscs_bsrun1 parallel (degree 4)
tablespace users
as select * from ipgwklysmscompdiscs;

create table ipgsyncexcludeddiscs_bsrun1 parallel (degree 4)
tablespace users
as select * from ipgsyncexcludeddiscs;

prompt Done.
select systimestamp from dual;
exit;

-- --------------------------------------------------------------------
-- Truncate - 5.3 tables
-- --------------------------------------------------------------------
prompt Starting bundlesync tables truncate
select systimestamp from dual;
set timing on

truncate table ipgsrcbundlesyncextract reuse storage;
truncate table ipgsynclog reuse storage;
truncate table ipgwklysmscompdiscs reuse storage;
truncate table ipgsyncexcludeddiscs reuse storage;

prompt Done.
select systimestamp from dual;
exit;
