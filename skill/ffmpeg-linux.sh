#!/bin/bash
# date 2022-08-16 08:26:03
# author calllivecn <c-all@qq.com>

# 使用 ffmpeg -hide_banner -devices 查看支持的设备。
# 1. ffmpeg -hide_banner -h demuxer=<device name> 查看参数

#ffmpeg -r 20 -i "$URL/video" -vcodec h264 -i "$URL/audio.aac" -acodec copy -f segment -segment_time 60  ffmpeg_%d.mp4

# 计数输出文件名
#ffmpeg -hide_banner -i "$URL/video" -i "$URL/audio.aac" -vcodec h264 -b:v 1000K -r 20 -acodec copy -f segment -segment_time 60  vdieo_%d.mp4

# 按指定文件名格式，自动切换输出文件 
ffmpeg -hide_banner -i /dev/dri/card0 -format yuv420p -framerate 30 -vcodec libx265 -acodec aac  video1.mp4

