#!/bin/bash
# korolev-ia [at] yandex.ru
#  add permanent routing for admins lan
# 2016.02.06
# v1.1


NVPN_DIR=/opt/mysquid
. $NVPN_DIR/common-env-squid-vpn.sh >/dev/null 2>&1

DEFAULT_ROUTER=`netstat -rn |grep eth0 |grep "^0\.0\.0\.0" | awk '{print $2}'`

# !!!!!!!!!!!!!!! WARNING
# delete permanent routes  to hosts
# be carefull when manualy add routes to hosts 
# please add it permanently in file common-env-squid-vpn.sh 
netstat -rn | awk '/UGH/ { print "route delete "$1 }' | sh



# add permanentt routes to my networks
for i in $MY_NETWORK; do
	echo $i | grep '/' >/dev/null
	if [ $? -ne 0 ]; then
		echo "route add -host $i gw $DEFAULT_ROUTER" | sh
	else 
		echo "route add -net $i gw $DEFAULT_ROUTER"  | sh
	fi
done


cat /etc/resolv.conf | awk -v DEFAULT_ROUTER=$DEFAULT_ROUTER '/nameserver/ { print "route add -host "$2" gw " DEFAULT_ROUTER }'  |sh



