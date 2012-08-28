#!/bin/sh
#
# Author : ManuxFR
# Name : YUM Alert
# Features : Yum-Alert is a simple bash script to monitor your yum updates....
# Version : 0.1
# 
# Based on Michael Heiming's script.
# 
# Tips : Put this script in /etc/cron.weekly/ or /etc/cron.daily/ !

## CONFIGURATION

# Mail dest :
maila=foo@bar.tld

# Mode debug - e-mail even no news paquets.
# "yes" or "no"
debug="no"

## DON'T MODIFY ! (EXCEPT IF YOU KNOW WHAT YOU DO)
################################################################################

yumdat="/tmp/yum-check-update.$$"
yumb="/usr/bin/yum"

#  wait a random interval if there is not a controlling terminal, 
#  for load management
if ! [ -t ]
then
         num=$RANDOM
         let "num %= ${RANGE:=1}"
         sleep $num
fi

rm -f ${yumdat%%[0-9]*}*

$yumb check-update >& $yumdat

yumstatus="$?"

case $yumstatus in
         100)
                  cat $yumdat |\
                  mail -r "yum-alert" -s "Server : ${HOSTNAME} --> News packages available ! " $maila
                  exit 0
;;
	0)
		if [ $debug = "yes" ];then
		cat $yumdat |\
                  mail -r "yum-alert" -s "Server : ${HOSTNAME} --> Now new package... " $maila
		fi
		exit 0

;;
         *)
                 # Status of yum error
                 (echo "Alert 'yum check-update': ${yumstatus}" && \
                 [ -e "${yumdat}" ] && cat "${yumdat}" )|\
                 mail -r "yum-alert" -s "Alert : ${HOSTNAME} --> Problem with yum." $maila
esac

[ -e "${yumdat}" ] && rm ${yumdat}

