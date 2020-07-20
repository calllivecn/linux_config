#!/bin/bash
# date 2020-07-21 01:07:55
# author calllivecn <c-all@qq.com>

set -ex

PHYICAL_WIFI="wlp7s0"
VIRTUAL_WIFI="VirtualAP0"
GATEWAY_IP="192.168.7.1/24"

if [ -n "$(ip -br link |awk '{print $1}' |grep "$VIRTUAL_WIFI")" ];then
	# delete
	iw dev "$VIRTUAL_WIFI" del
fi

sleep 1

iw dev "$PHYICAL_WIFI" interface add "$VIRTUAL_WIFI" type managed

ip addr add dev "$VIRTUAL_WIFI" "$GATEWAY_IP"

hostapd  /etc/hostapd/AP0.conf
