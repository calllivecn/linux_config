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
		apt show $deb > /dev/null 2>&1
		if [ $? -eq 0 ];then
			INSTALL_LISTS="$INSTALL_LISTS $deb"
		else
			echo "当前仓库没有: $deb"
		fi
		#sudo apt install "$deb"
	else
		echo "不安装$deb"
	fi
done

apt install $INSTALL_LISTS
}


install_for_file "ubuntu软件包列表.txt"

echo "添加python包了～"

pip_install_for_file(){
for deb in $(grep -Ev '^#|^$' "$1")
do
	echo "安装$deb?[y/N]"
	read -n 1 yesno
	echo ''
	if [ "$yesno"x = "y"x ];then
		sudo pip3 install "$deb"
	else
		echo "不安装$deb"
	fi
done
}

pip_install_for_file "python第3方包.txt"
