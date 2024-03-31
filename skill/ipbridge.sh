#!/bin/bash
# date 2020-07-23 10:13:11
# author calllivecn <calllivecn@outlook.com>


HELP='Usage: ipbridge.sh <br_name> [slave1 [slave2...]]'


if [ -n "$1" ];then
	BR="$1"
else
	echo "需要bridge名"
	exit 1
fi

ip link add "$BR" type bridge

shift

for slave in "$@"
do
	#echo "$slave"
	ip link set "$slave" master "$BR" 
done

ip link set "$BR" up
