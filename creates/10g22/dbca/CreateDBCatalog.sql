connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/CreateDBCatalog.log
@/orahome/app/product/10.2.0.2/rdbms/admin/catalog.sql;
@/orahome/app/product/10.2.0.2/rdbms/admin/catblock.sql;
@/orahome/app/product/10.2.0.2/rdbms/admin/catproc.sql;
@/orahome/app/product/10.2.0.2/rdbms/admin/catoctk.sql;
@/orahome/app/product/10.2.0.2/rdbms/admin/owminst.plb;
connect "SYSTEM"/"&&systemPassword"
@/orahome/app/product/10.2.0.2/sqlplus/admin/pupbld.sql;
connect "SYSTEM"/"&&systemPassword"
set echo on
spool /orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/sqlPlusHelp.log
@/orahome/app/product/10.2.0.2/sqlplus/admin/help/hlpbld.sql helpus.sql;
spool off
spool off
