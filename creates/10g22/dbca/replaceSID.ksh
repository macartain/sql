#!/usr/bin/ksh
##########################################################
# 21 Mar 2007 - colm - v1.0
##########################################################

echo "`date +%Y-%m-%d_%H:%M`: Starting replace... "

for i in `ls *.sh *.ora *.sql`
        do sed -e 's/TEDCFG01/TEDCFG02/g' < $i > ${i}-edited.tmp
        mv -f ${i}-edited.tmp $i
        echo "`date +%Y%m%d%H%M`: $i has been modified."
done

echo "`date +%Y-%m-%d_%H:%M`: Completed."
