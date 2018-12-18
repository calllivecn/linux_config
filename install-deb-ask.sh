#!/usr/bin/env bash
# 


for deb in $(grep -Ev '^#|^$' ubuntu软件包列表.txt)
do
	echo "安装$deb?[y/N]"
	read -n 1 yesno
	echo
	if [ "$yesno"x = "y"x ];then
		sudo apt install "$deb"
	else
		echo "不安装$deb"
	fi
done
