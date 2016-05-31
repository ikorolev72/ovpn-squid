#!/bin/bash
# korolev-ia [at] yandex.ru
# common enviroment vars and functions
# 2016.02.03
# v1.0


##########################################
# Please set your network or ip bellow, 
# do not use mask for one ip
# sample MY_NETWORK='194.176.96.0/24 208.53.164.21'
MY_NETWORK='178.76.0.0/16 194.176.96.0/24 208.53.164.21'
##########################################


VAR_DIR=${NVPN_DIR}/var
LOG=$VAR_DIR/log/check-vpn.log
[ -d $VAR_DIR/log ] || mkdir -p $VAR_DIR/log

WATCHDOG=${NVPN_DIR}/watchdog.sh
START_VPN=${NVPN_DIR}/start-vpn.sh


SQUID_CONF_TEMP=/$VAR_DIR/squid.conf.template
SQUID_CONF=/etc/squid3/squid.conf
SQUID_START='service squid3 start'
SQUID_STOP='service squid3 stop'
SQUID_RESTART='service squid3 restart'

OPENVPN=/usr/sbin/openvpn

# dir with openvpn configs
VPN_CFG_DIR=$NVPN_DIR/ovpn
# dir with ssl certificates
VPN_CA_DIR=$NVPN_DIR/ovpn
# authorisation file
NVPN_PASSFILE=$NVPN_DIR/auth.txt


