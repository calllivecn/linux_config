#!/bin/bash
# date 2018-04-28 18:34:17
# author calllivecn <c-all@qq.com>

etc="ip6tables.rules iptables.rules"

ETC="nftables.conf"

home="bashrc git.global_config home-pythonrc pip.conf profile vimrc"

set -ex

cp -v bashrc ~/.bashrc

cp -v profile ~/.profile

if [ -f /etc/pip.conf ];then
	echo "/etc/pip.conf already exists"
else
	cp -v pip.conf /etc/pip.conf
fi

cp -v home-pythonrc ~/.pythonrc

cp -v git.global_config ~/.gitconfig

#cp -v vimrc ~/.vimrc
echo '"zx add' >> /etc/vim/vimrc
cat vimrc >> /etc/vim/vimrc


# /etc/

for e in $ETC
do
	cp -vf "$e" /etc/
done

