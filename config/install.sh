#!/bin/bash
# date 2018-04-28 18:34:17
# author calllivecn <c-all@qq.com>

etc="ip6tables.rules iptables.rules"

ETC="nftables.conf"

home="bashrc git.global_config home-pythonrc pip.conf profile vimrc"

set -ex

cp -v bashrc ~/.bashrc

cp -v profile ~/.profile

cp -v home-pythonrc ~/.pythonrc

cp -v git.global_config ~/.gitconfig

#cp -v vimrc ~/.vimrc
echo '"zx add' |sudo tee -a /etc/vim/vimrc
cat vimrc |sudo tee -a /etc/vim/vimrc

# /etc/

for e in $ETC
do
	sudo cp -vf "$e" /etc/
done

