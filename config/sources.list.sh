#!/bin/bash

SOURCES_LIST="/etc/apt/sources.list"

BAK="${SOURCES_LIST}-$(date +%F+%R:%S)"

if [ -f $SOURCES_LIST ];then
	cp -v $SOURCES_LIST "$BAK"
fi

sed  \
-e "s/^deb /deb [arch=amd64] /" \
-e "s|http://cn.archive.ubuntu.com|https://mirrors.aliyun.com|" \
-e "s|http://security.ubuntu.com|https://mirrors.aliyun.com|" "$BAK" |grep -Ev "^#|^$" |tee $SOURCES_LIST
