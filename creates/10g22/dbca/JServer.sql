connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/JServer.log
@/orahome/app/product/10.2.0.2/javavm/install/initjvm.sql;
@/orahome/app/product/10.2.0.2/xdk/admin/initxml.sql;
@/orahome/app/product/10.2.0.2/xdk/admin/xmlja.sql;
@/orahome/app/product/10.2.0.2/rdbms/admin/catjava.sql;
@/orahome/app/product/10.2.0.2/rdbms/admin/catexf.sql;
spool off
