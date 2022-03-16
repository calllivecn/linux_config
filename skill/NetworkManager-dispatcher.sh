#!/bin/bash
# date 2022-03-16 16:21:00
# author calllivecn <c-all@qq.com>


[ -z "$CONNECTION_UUID" ] && exit 0
INTERFACE="$1"
ACTION="$2"


case $ACTION in
up | dhcp4-change | dhcp6-change)
	[ -n "$DHCP4_NTP_SERVERS" ] || exit
	mkdir /etc/systemd/timesyncd.conf.d
	cat <<-THE_END >"/etc/systemd/timesyncd.conf.d/${CONNECTION_UUID}.conf"
		[Time]
		NTP=$DHCP4_NTP_SERVERS
	THE_END
	systemctl restart systemd-timesyncd.service
	;;
down)
	rm -f "/etc/systemd/timesyncd.conf.d/${CONNECTION_UUID}.conf"
	systemctl stop systemd-timesyncd.service
	;;
esac
