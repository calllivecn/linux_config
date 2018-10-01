#!/bin/bash


Xephyr -ac -br -reset :1 &

sleep 2

DISPLAY=":1.0" awesome -c ~/.config/awesome/rc.test.lua
