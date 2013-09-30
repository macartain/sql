#!/usr/bin/ksh
#############################################################################
#
#  Copyright (C) 2001 International Computers Ltd.  All Rights Reserved.
#
#  AUTHOR       : Nick Childs
#  DATE WRITTEN : 30 November 2001
#  REFERENCE    : fixdtm
#  DESCRIPTION  :
#
#-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#--   Module Amendment History
#-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#-- Date        By    Description
#-- 30/11/2001  NC    Genesis
#-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#-- Notes:
#--
#--
#
#############################################################################

YN=""

#################
msg()
#################
{
    echo "$*" 
}

#################
# Insert/Update records in GPARAMS
#################
set_db_date()
{
    export CHECKSQL=`sqlplus -s ${DATABASE}  <<SQLSCRIPT
    set heading off;
    set feedback off;
    INSERT into GPARAMS (NAME,TYPE,START_DTM,STRING_VALUE) 
	                    (select 'SYSdateValue','STRING',to_date('2001/01/01','YYYY/DD/MM') ,'$1 120000'
						   from dual where not exists ( select 'x' from GPARAMS 
						                                 where name = 'SYSdateValue')    );
    UPDATE GPARAMS set STRING_VALUE = '$1 120000' where name = 'SYSdateValue';
    INSERT into GPARAMS (NAME,TYPE,START_DTM,STRING_VALUE)
                        ( select 'SYSdateOverride','STRING',to_date('2001/01/01','YYYY/DD/MM') ,'FIXEDDATE'
						    from dual where not exists ( select 'x' from GPARAMS 
							                              where name = 'SYSdateOverride')    );
    UPDATE GPARAMS set STRING_VALUE = 'FIXEDDATE' where name = 'SYSdateOverride';
    commit;
SQLSCRIPT`
    echo $CHECKSQL | egrep 'ERROR|unable' > /dev/null
    RES=$?
    if [ $RES = 0 ] ; then
            msg "\nERROR. Unable to update GPARAMS.\n"
                return 1
    fi
}

################
check_db_date()
################
{
        export CHECKSQL=`sqlplus -s ${DATABASE}  <<SQLSCRIPT
        set heading off;
        set feedback off;
        select 'export db_date="'||trim(string_value)||'"' from GPARAMS where name = 'SYSdateValue';
SQLSCRIPT`

    echo $CHECKSQL | egrep 'ERROR|unable' > /dev/null
    RES=$?
    if [ $RES = 0 ] ; then
            msg "\nERROR. Unable to check GPARAMS.\n"
                return 1
    fi
    eval $CHECKSQL
}

################
check_db_type()
################
{
        export CHECKSQL=`sqlplus -s ${DATABASE}  <<SQLSCRIPT
        set heading off;
        set feedback off;
        select 'export db_type="'||trim(string_value)||'"' from GPARAMS where name = 'SYSdateOverride';
SQLSCRIPT`

    echo $CHECKSQL | egrep 'ERROR|unable' > /dev/null
    RES=$?
    if [ $RES = 0 ] ; then
            msg "\nERROR. Unable to check GPARAMS.\n"
                return 1
    fi
    eval $CHECKSQL
}

################
check_gnv_date()
################
{
        export CHECKSQL=`sqlplus -s ${DATABASE}  <<SQLSCRIPT
        set heading off;
        set feedback off;
        select 'export gnv_date="'||gnvgen.systemdate||'"' from dual;
SQLSCRIPT`

    echo $CHECKSQL | egrep 'ERROR|unable' > /dev/null
    RES=$?
    if [ $RES = 0 ] ; then
            msg "\nERROR. Unable to check gnvgen.systemdate.\n"
                return 1
    fi
    eval $CHECKSQL
}

################
validate_date()
################
{
        export CHECKSQL=`sqlplus -s ${DATABASE}  <<SQLSCRIPT
        set heading off;
        set feedback off;
        select TO_DATE('$1','YYYYMMDD') from dual;
SQLSCRIPT`

    echo $CHECKSQL | egrep 'ERROR|unable|ORA' > /dev/null
    RES=$?
    if [ $RES = 0 ] ; then
            msg "\nERROR. Invalid Date format $1.\n"
                return 1
    fi
}

################
get_date()
################
{
check_gnv_date 
check_db_type
check_db_date

if [[ -z "${GENEVA_FIXEDDATE}" ]] 
then
   msg "             GENEVA_FIXEDDATE is not set!"
else
   msg "             GENEVA_FIXEDDATE is: $GENEVA_FIXEDDATE"
fi

if [[ -z "${gnv_date}" ]] 
then
   msg "             gnvgen.systemdate cannot be determined!"
else
   msg "             gnvgen.systemdate is: $gnv_date"
fi

if [[ -z "${db_type}" ]] 
then
   msg "             GPARAM SYSdateOverride does not exist!"
else
   msg "             GPARAM SYSdateOverride is: $db_type"
fi

if [[ -z "${db_date}" ]] 
then
   msg "             GPARAM SYSdateValue does not exist!"
else
   msg "             GPARAM SYSdateValue is: $db_date"
fi

msg "\n"
}

################
## main
################
ARGC=$#
#ARGV0=`basename $0`
#ARGV0=`$0`
#ARGV1=`$1`

#msg $ARGV0
#msg $ARGV1
#[[ $ARGC != 1 ]] && echo "\nUsage: . fixdtm\n"&&return 1
[[ "$DATABASE" = "" ]] && echo "\nmissing DATABASE Env Variable - Exiting..\n"&&return 1

export GENEVA_FIXEDDATE=${GENEVA_FIXEDDATE:-""}
export gnv_date=""
export db_type=""
export db_date=""

msg "\nCurrent Settings are:"
get_date
until [ "$YN" = "Y" ] || [ "$YN" = "y" ] || [ "$YN" = "N" ] || [ "$YN" = "n" ];
do
   msg "Do you wish to change the fixed date? [Y|N] \c";read YN
done
if [ "$YN" = "N" ] || [ "$YN" = "n" ]
then
  echo "Exiting...\n"
else
  msg "So whats the new fixed date then? [YYYYMMDD] \c";read new_date
  validate_date $new_date
  set_db_date $new_date
  export GENEVA_FIXEDDATE="$new_date 12000000"
  msg "New Settings are:"
  get_date
fi

