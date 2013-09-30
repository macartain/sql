set echo on

REM * Create Catalogue
connect SYS/change_on_install as SYSDBA
@$ORACLE_HOME/rdbms/admin/catalog.sql;
@$ORACLE_HOME/rdbms/admin/catexp7.sql;
@$ORACLE_HOME/rdbms/admin/catblock.sql;
@$ORACLE_HOME/rdbms/admin/catproc.sql;
@$ORACLE_HOME/rdbms/admin/catoctk.sql;
@$ORACLE_HOME/rdbms/admin/owminst.plb;
@$ORACLE_HOME/javavm/install/initjvm.sql;
@$ORACLE_HOME/xdk/admin/initxml.sql;
@$ORACLE_HOME/xdk/admin/xmlja.sql;
@$ORACLE_HOME/rdbms/admin/catjava.sql;
@$ORACLE_HOME/rdbms/admin/catqueue.sql;

connect system/manager
@$ORACLE_HOME/sqlplus/admin/pupbld.sql;

connect system/manager
set echo on
@$ORACLE_HOME/sqlplus/admin/help/hlpbld.sql;
@$ORACLE_HOME/sqlplus/admin/help/helpus.sql;

spool off
exit;
