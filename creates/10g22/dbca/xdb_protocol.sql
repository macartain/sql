connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/xdb_protocol.log
@/orahome/app/product/10.2.0.2/rdbms/admin/catqm.sql change_on_install SYSAUX TEMP;
connect "SYS"/"&&sysPassword" as SYSDBA
@/orahome/app/product/10.2.0.2/rdbms/admin/catxdbj.sql;
@/orahome/app/product/10.2.0.2/rdbms/admin/catrul.sql;
spool off
