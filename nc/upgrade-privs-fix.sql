
-- from mike/justin

select OWNER,object_type,OBJECT_NAME,STATUS from all_objects where OBJECT_NAME='DATA_SECURITY';
select OWNER,OBJECT_NAME,OBJECT_TYPE,status from all_objects where OBJECT_NAME='EKMKEYMIGRATION';
select OWNER,object_type,OBJECT_NAME,STATUS from all_objects where OBJECT_NAME='AUDITLOG';
infinys_privs.GRANT_OBJECT_PRIV('PF','DATA_SECURITY', 'geneva_admin', 'execute', FALSE, TRUE);
BEGIN infinys_privs.GRANT_OBJECT_PRIV('PF','PFMESSAGE', 'geneva_admin', 'all', TRUE, FALSE);END;
BEGIN infinys_privs.GRANT_OBJECT_PRIV('PF','AUDITLOG', 'geneva_admin', 'execute', FALSE, TRUE); END;
BEGIN infinys_privs.GRANT_OBJECT_PRIV('PF','DATA_SECURITY', 'geneva_admin', 'execute', FALSE, TRUE);END;
infinys_privs.GRANT_OBJECT_PRIV('PF','PFMESSAGE', 'geneva_admin', 'all', TRUE, FALSE);
CREATE or replace SYNONYM GENEVA_ADMIN.DATA_SECURITY FOR IPF_ADMIN.DATA_SECURITY

alter package EKMKEYMIGRATION compile;

grant execute on ipf_admin.sysreg to GENEVA_ADMIN; 
grant execute on ipf_admin.sysreg to IPF_AUDIT_ADMIN; 
grant execute on ipf_admin.sysreg to GENEVAADMIN; 
grant execute on ipf_admin.sysreg to INFINYS_PF; 
grant execute on ipf_admin.sysreg to PF_UPDATE_ROLE_UNIF_ADMIN; 
create or replace synonym GENEVA_ADMIN.SYSREG for IPF_ADMIN.SYSREG; 
create or replace synonym INF_ADMIN.SYSREG for IPF_ADMIN.SYSREG; 
create or replace synonym IPF_AUDIT_ADMIN.SYSREG for IPF_ADMIN.SYSREG; 
create or replace synonym UNIF_ADMIN.SYSREG for IPF_ADMIN.SYSREG; 
create or replace public synonym SYSREG for IPF_ADMIN.SYSREG;
alter package ipf_admin.data_security compile

declare BEGIN infinys_privs.grant_object_priv('PF', 'DATA_SECURITY', 'GENEVAADMIN', 'EXECUTE', FALSE, FALSE); END /

select * from all_objects where OBJECT_NAME='EKMKEYMIGRATION';

select OWNER,OBJECT_NAME,OBJECT_TYPE,status from all_objects where OBJECT_NAME='EKMKEYMIGRATION';

grant SELECT, UPDATE, DELETE, INSERT on GENEVA_ADMIN.PFMESSAGE to GENEVAADMIN;
