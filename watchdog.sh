#!/bin/bash 
# korolev-ia [at] yandex.ru
# watchdog for start/stop ovpn connections with squid
# 2016.02.06
# v1.1

NVPN_DIR=/opt/mysquid
. $NVPN_DIR/common-env-squid-vpn.sh >/dev/null 2>&1

# there are ip you will ping for test vpn connections 
PING_IP='shopping.de candy.com vodka.com whisky.com mi.com hotels.com google.com yahoo.com ya.ru bbc.co.uk'

APID=$VAR_DIR/`basename $0`.pid


OVPN_CFG=( `ls -1 $VPN_CFG_DIR/*.ovpn` )
OVPN_CFG_COUNT=${#OVPN_CFG[*]} 
#OVPN_CFG_COUNT=`ls -1 $VPN_CFG_DIR/*.ovpn | wc -l`

get_next_ovpn_cfg() {
	let OVPN_CFG_COUNT=$OVPN_CFG_COUNT-1
	if [ $OVPN_CFG_COUNT -eq 0 ]; then 
		OVPN_CFG_COUNT=${#OVPN_CFG[*]} 
	fi	
}

do_loop() {
	while [ 1 ]; do
		PING_SUCCSESS=0 # 0 mean all ok, 1 error 
		for ip in $PING_IP; do
			ping -n -w 3 -I tun0 $ip 
			if [ $? -ne 0 ]; then
				PING_SUCCSESS=1
				continue
			fi
			PING_SUCCSESS=0
			sleep 30
		done
			if [ $PING_SUCCSESS -ne 0 ]; then
				START_VPN_RESULT=1
				while [ $START_VPN_RESULT -ne 0 ]; do
					get_next_ovpn_cfg
					timeout 60 $START_VPN stop
					timeout 60 $START_VPN start ${OVPN_CFG[$OVPN_CFG_COUNT]}
					VPN_START_RESULT=$?
					# if all ok watchdog will continue, else try to restart next config
					if [ $? -eq 0 ]; then
						break
					fi
					sleep 10
				done
			fi
	done
}




help (){
    echo "Watchdog for checking vpn connection" >&2
    echo "Usage: $0 { start | stop | help } " >&2
}
#################### start main program ####################
#
case "$1" in
        start)
				if [ -f $APID ]; then
					ps --pid `cat $APID` -o cmd h | grep `basename $0` >/dev/null 2>&1 
					if [ $? -ne 0 ]; then
						echo $$ > $APID
						do_loop
					fi
				else 
						echo $$ > $APID
						do_loop
				fi					

                ;;
        stop)
				if [ -f $APID ]; then
					ps --pid `cat $APID` -o cmd h | grep `basename $0` >/dev/null 2>&1 
					if [ $? -eq 0 ]; then
							kill -9 `cat $APID` >/dev/null 2>&1
							rm $APID
					fi				
				fi
                exit 0
                ;;
        help)
                help
                ;;
        *)
                help
                exit 3
        ;;
esac

exit 0
