#!/bin/bash
# date 2022-03-16 16:21:00
# author calllivecn <calllivecn@outlook.com>

#exec 1<>/tmp/nmcli1.logs
#exec 2<>/tmp/nmcli2.logs

set -x

[ -z "$CONNECTION_UUID" ] && exit 0
INTERFACE="$1"
ACTION="$2"

ROUTE="10.1.2.0/24"
VIA="192.168.8.10"

case $ACTION in
up|dhcp6-change)

	echo "wg static route add $ROUTE"
	if [[ -n $(ip route list match "$ROUTE" |grep "$ROUTE") ]];then
		echo "wg static route $ROUTE exists"
	else
		echo "ip route add $ROUTE via $VIA"
		ip route add "$ROUTE" via "$VIA"
	fi

	;;
down)
	echo "wg static route add $ROUTE"
	;;
esac
