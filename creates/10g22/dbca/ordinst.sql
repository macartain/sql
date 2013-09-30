connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/ordinst.log
@/orahome/app/product/10.2.0.2/ord/admin/ordinst.sql SYSAUX SYSAUX;
spool off
