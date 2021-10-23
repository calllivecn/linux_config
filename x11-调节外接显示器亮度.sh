#!/bin/bash
# date 2021-10-23 17:20:38
# author calllivecn <c-all@qq.com>

display_number=

display_number=$(randr --listmonitors |grep "Monitors:" |awk '{print $2}')

list_monitors(){
	
}

xrandr --output HDMI-0 --brightness 0.6
