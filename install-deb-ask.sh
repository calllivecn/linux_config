#!/usr/bin/env bash
# 


INSTALL_LISTS=""

install_for_file(){
for deb in $(grep -Ev '^#|^$' "$1")
do
	echo "安装$deb?[y/N]"
	read -n 1 yesno
	echo ''
	if [ "$yesno"x = "y"x ];then
		INSTALL_LISTS="$INSTALL_LISTS $deb"
		#sudo apt install "$deb"
	else
		echo "不安装$deb"
	fi
done

apt install $INSTALL_LISTS
}


install_for_file "ubuntu软件包列表.txt"


INSTALL_LISTS=""

pip_install_for_file(){
for pip in $(grep -Ev '^#|^$' "$1")
do
	echo "安装$deb?[y/N]"
	read -n 1 yesno
	echo ''
	if [ "$yesno"x = "y"x ];then
		INSTALL_LISTS="$INSTALL_LISTS $pip"
		#sudo pip3 install "$deb"
	else
		echo "不安装$deb"
	fi
done
pip3 install $INSTALL_LISTS
}

pip_install_for_file "python第3方包.txt"
