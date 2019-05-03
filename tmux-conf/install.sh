#!/bin/sh

set -ex

cp -v tmux.conf /etc/

cp -v hometmux.conf ~/.tmux.conf

[ -d ~/.tmux ] || mkdir ~/.tmux

cp -v tmux/*.conf ~/.tmux/


