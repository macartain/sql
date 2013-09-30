-- Create table
create table RBM_AUDIT.MIGRATIONREVENUE
(
AUDIT_ID NUMBER(9) not null,
OWNER VARCHAR(255) not null,
TABLE_NAME VARCHAR2(255) not null,
COLUMN_NAME VARCHAR2(255) not null,
REVENUE_SUM NUMBER(38),
AUDIT_DTM DATE not null
)
tablespace USERS
pctfree 10
initrans 1
maxtrans 255
storage
(
	initial 64K
	next 64K
	minextents 1
	maxextents unlimited
	pctincrease 0
);

-- Create/Recreate primary, unique and foreign key constraints 
alter table RBM_AUDIT.MIGRATIONREVENUE
add constraint MIGRATIONREVENUE_PK primary key (AUDIT_ID, OWNER, TABLE_NAME, COLUMN_NAME)
using index 
tablespace USERS
pctfree 10
initrans 2
maxtrans 255
storage
(
initial 64K
next 64K
minextents 1
maxextents unlimited
pctincrease 0
);

set serverout on
declare
--

-- ---------------------------------------------------------------------
--
-- 20110904   Andy Gill   Skeleton for capturing table counts
--
v_sm       number        := 0 ;
v_sqlcode  number        := 0 ;
v_stmt     varchar2(255)      ;
--
#NAME?
--
cursor c_tbl is

	select owner, table_name, column_name
	from   all_tab_columns
	where  owner in ('GENEVA_ADMIN')
	and table_name <> 'COSTEDEVENT' 
	and table_name not like '%QUEUE%'
	and table_name not like 'AQ$%'
	and table_name not like 'SYS_IOT%'
	and table_name not like 'PV%'
	and column_name like '%MNY';
--   
r_tbl      c_tbl%rowtype;
--
begin

	dbms_output.disable;
	dbms_output.enable(1000000);
	open c_tbl;
	loop
		fetch c_tbl into r_tbl;
		exit when c_tbl%notfound;
		
		v_stmt := 'select /*+ PARALLEL('||r_tbl.table_name||',DEFAULT) */ nvl(sum ('||r_tbl.column_name||'),0) from '||r_tbl.owner||'.'||r_tbl.table_name;
		dbms_output.put_line (v_stmt);
		execute immediate v_stmt into v_sm;
		
		v_sqlcode := SQLCODE;  
		if v_sqlcode = 0 then

			insert into RBM_AUDIT.MIGRATIONREVENUE(AUDIT_ID,OWNER,TABLE_NAME,COLUMN_NAME,REVENUE_SUM,AUDIT_DTM) values (1,r_tbl.owner,r_tbl.table_name,r_tbl.column_name,v_sm,sysdate);
	
		end if;
	end loop;
	close c_tbl;
end;
/