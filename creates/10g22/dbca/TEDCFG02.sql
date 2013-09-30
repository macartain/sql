set verify off
DEFINE sysPassword = sys
DEFINE systemPassword = sys
host /orahome/app/product/10.2.0.2/bin/orapwd file=/orahome/app/product/10.2.0.2/dbs/orapwTEDCFG02 password=&&sysPassword force=y
@/orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/CreateDB.sql
@/orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/CreateDBFiles.sql
@/orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/CreateDBCatalog.sql
@/orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/JServer.sql
@/orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/xdb_protocol.sql
@/orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/ordinst.sql
@/orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/interMedia.sql
@/orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/postDBCreation.sql
