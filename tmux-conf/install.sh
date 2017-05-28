#!/bin/sh

set -e

cp tmux.conf /etc/

cp hometmux.conf ~/.tmux.conf

[ -d ~/.tmux ] && mkdir ~/.tmux

cp tmux/*.conf ~/.tmux/


