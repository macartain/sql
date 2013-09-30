connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/interMedia.log
@/orahome/app/product/10.2.0.2/ord/im/admin/iminst.sql;
spool off
