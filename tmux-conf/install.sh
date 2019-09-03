#!/bin/sh

set -ex

cp -v tmux.conf_v2.x /etc/tmux.conf

cp -v hometmux.conf ~/.tmux.conf

[ -d ~/.tmux ] || mkdir ~/.tmux

cp -v tmux/*.conf ~/.tmux/


