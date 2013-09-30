#!/bin/sh

mkdir -p /oradata/TEDCFG02
mkdir -p /orahome/app/product/10.2.0.2/admin/TEDCFG02/adump
mkdir -p /orahome/app/product/10.2.0.2/admin/TEDCFG02/bdump
mkdir -p /orahome/app/product/10.2.0.2/admin/TEDCFG02/cdump
mkdir -p /orahome/app/product/10.2.0.2/admin/TEDCFG02/dpdump
mkdir -p /orahome/app/product/10.2.0.2/admin/TEDCFG02/pfile
mkdir -p /orahome/app/product/10.2.0.2/admin/TEDCFG02/udump
mkdir -p /orahome/app/product/10.2.0.2/cfgtoollogs/dbca/TEDCFG02
mkdir -p /orahome/app/product/10.2.0.2/dbs
ORACLE_SID=TEDCFG02; export ORACLE_SID
echo You should Add this entry in the /var/opt/oracle/oratab: TEDCFG02:/orahome/app/product/10.2.0.2:Y
/orahome/app/product/10.2.0.2/bin/sqlplus /nolog @/orahome/app/product/10.2.0.2/admin/TEDCFG02/scripts/TEDCFG02.sql
