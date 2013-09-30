connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/postDBCreation.log
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
create spfile='/orahome/app/product/10.2.0.2/dbs/spfileTEDCFG02.ora' FROM pfile='/orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/init.ora';
shutdown immediate;
connect "SYS"/"&&sysPassword" as SYSDBA
startup ;
select 'utl_recomp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute utl_recomp.recomp_serial();
select 'utl_recomp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
spool /orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/postDBCreation.log
exit;
