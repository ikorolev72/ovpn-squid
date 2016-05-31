#!/bin/bash
# korolev-ia [at] yandex.ru
# start/stop ovpn connections with squid
# 2016.02.06
# v1.1



NVPN_DIR=/opt/mysquid

. $NVPN_DIR/common-env-squid-vpn.sh >/dev/null 2>&1
. $NVPN_DIR/route-permanent.sh >/dev/null 2>&1


#DEFAULT_ROUTER=`netstat -rn |grep eth0 |grep "^0\.0\.0\.0" | awk '{print $2}'`
#OUTPUT_IP=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')

echoerr() {
        echo `date` "$@" >> $LOG
        echo "$@" 1>&2
}


do_stop_ovpn() {
    echo  "Stopping openvpn"
        pkill -9 -x openvpn > /dev/null 2>&1
        RETVAL=$?
    return $RETVAL
}

do_stop_squid() {
    echo  "Stopping squid"
        $SQUID_STOP
        RETVAL=$?
    return $RETVAL
}


do_start_ovpn() {
	# external ip before openvpn start
	EXTERNAL_IP=$(ip route get 1 | awk '{print $NF;exit}')

    # start openvpn with preffered config file and demonise it
    if [ -f $NVPN_PASSFILE ] ;then
        $OPENVPN --daemon --pull --config $OVPN_CFG --auth-user-pass $NVPN_PASSFILE --crl-verify $VPN_CA_DIR/crl.pem $VPN_CA_DIR --ca $VPN_CA_DIR/ca.crt
    else
        $OPENVPN --daemon --pull --config $OVPN_CFG --crl-verify $VPN_CA_DIR/crl.pem $VPN_CA_DIR --ca $VPN_CA_DIR/ca.crt
    fi

        # waiting for start network adapter tun0
    sleep 10
	
	# external ip after openvpn started
	OUTPUT_IP=$(ip route get 1 | awk '{print $NF;exit}')
	
	if [ "$OUTPUT_IP" == "$EXTERNAL_IP" ] ; then
		echoerr "Openvpn tunnel do not start"
		return 1
	fi
    return 0
}

do_start_squid() {
	# create new squid config file from template
	# change variable OUTPUT_IP, LISTEN_ADDRESS and MY_NETWORK
	#
	LISTEN_ADDRESS=$EXTERNAL_IP
	sed -e "s|XXX-MY_NETWORK-XXX|${MY_NETWORK}|g" -e "s|XXX-OUTPUT_IP-XXX|${OUTPUT_IP}|g" -e "s|XXX-LISTEN_ADDRESS-XXX|${LISTEN_ADDRESS}|g" -e "s|XXX-SQUID_CONF_TEMP-XXX|${SQUID_CONF_TEMP}|g" $SQUID_CONF_TEMP > $SQUID_CONF	
	
#	sed -e "s|XXX-MY_NETWORK-XXX|${MY_NETWORK}|" -e "s|XXX-OUTPUT_IP-XXX|${OUTPUT_IP}|" -e "s|XXX-LISTEN_ADDRESS-XXX|${LISTEN_ADDRESS}|" $SQUID_CONF_TEMP > $SQUID_CONF	
	$SQUID_RESTART
    return $?
}




help (){
    echo "Usage: $0 { [ start  config.ovpn ] | stop | help } " >&2
}


#################### start main program ####################
#
case "$1" in
    start)	
                        if [ ! -n "$2" ] ; then
				echoerr "Please add config.ovpn"
				help
				exit 4
                        fi
			if [ ! -f $SQUID_CONF_TEMP ] ; then
				echoerr "Template of squid config $SQUID_CONF_TEMP do not exist"
				exit 5
			fi
			OVPN_CFG="$VPN_CFG_DIR/$2"
			if [ -f $2 ] ; then
				OVPN_CFG=$2
			fi
			if [ ! -f $OVPN_CFG ] ; then
				echoerr "Cannot start openvpn. Config file $OVPN_CFG do not exist"
				help
				exit 4
			fi
			do_stop_ovpn >/dev/null 2>&1
			do_start_ovpn
			RETVAL=$?
			if [ $RETVAL != 0 ]; then
				echoerr "Cannot stop squid"
				exit $RETVAL
			fi					
			do_start_squid 
			if [ $? != 0 ]; then
				do_stop_ovpn
				exit 1
			fi
			echoerr "Start openvpn with $OVPN_CFG"
			;;
    stop)
			do_stop_squid
			RETVAL=$?
			if [ $RETVAL != 0 ]; then
				echoerr "Cannot stop squid"
			fi					
			do_stop_ovpn
			if [ $? != 0 ]; then
				echoerr "Cannot stop OpenVPN"
				exit 1
			fi					
			exit $RETVAL
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
