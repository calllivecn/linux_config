#!/usr/bin/env bash
# 


install_for_file(){
for deb in $(grep -Ev '^#|^$' "$1")
do
	echo "安装$deb?[y/N]"
	read -n 1 yesno
	echo ''
	if [ "$yesno"x = "y"x ];then
		sudo apt install "$deb"
	else
		echo "不安装$deb"
	fi
done
}


install_for_file "python第3方包.txt"
install_for_file "ubuntu软件包列表.txt"
