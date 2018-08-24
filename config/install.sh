#!/bin/bash
# date 2018-04-28 18:34:17
# author calllivecn <c-all@qq.com>

etc="ip6tables.rules iptables.rules"

home="bashrc git.global_config home-pythonrc pip.conf profile vimrc"

set -e

cp -v bashrc ~/.bashrc

cp -v profile ~/.profile

if [ -d ~/.pip ];then
	cp -v pip.conf ~/.pip/
else
	mkdir -v ~/.pip
	cp -v pip.conf ~/.pip/
fi

cp -v home-pythonrc ~/.pythonrc

cp -v git.global_config ~/.gitconfig


# /etc/
cp -v iptables.rules /etc/ && chmod 600 /etc/iptables.rules

cp -v ip6tables.rules /etc/ && chmod 600 /etc/ip6tables.rules