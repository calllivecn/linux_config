#!/bin/bash
# date 2022-01-09 10:22:08
# author calllivecn <calllivecn@outlook.com>


# define varible
PUSHGATEWAY=

getcfg(){
	local cfg
	cfg="$(dirname ${0})/pushgateway.conf"
	if [ -r $cfg ];then
		. $cfg
	else
		echo "需要配置文件: $cfg"
		exit 1
	fi

	if [ "$PUSHGATEWAY"x = x ];then
		echo "需要配置pushgateway 网关"
		exit 1
	fi
}

getcfg

NODENAME=$(hostname)

getip(){
	local t="223.5.5.5"
	#ip route get "$t" | grep "$t via" |awk '{print $3}'
	ip route get "$t" | grep -oP "(?<=$t via )(\d{1,3}\.){1,3}\d{1,3} (?=dev )"
}


