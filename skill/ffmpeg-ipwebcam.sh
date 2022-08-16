#!/bin/bash
# date 2022-08-16 06:17:03
# author calllivecn <c-all@qq.com>

USER="zx:zxcvbnm"
URL="https://${USER}@localhost:8080"
URL="https://${USER}@192.168.8.170:8080"

#ffmpeg -r 20 -i "$URL/video" -vcodec h264 -i "$URL/audio.aac" -acodec copy -f segment -segment_time 60  ffmpeg_%d.mp4

# 计数输出文件名
#ffmpeg -hide_banner -i "$URL/video" -i "$URL/audio.aac" -vcodec h264 -b:v 1000K -r 20 -acodec copy -f segment -segment_time 60  vdieo_%d.mp4

# 按指定文件名格式，自动切换输出文件 
ffmpeg -hide_banner -i "$URL/video" -i "$URL/audio.aac" -vcodec h264 -b:v 1000K -r 20 -acodec copy -f segment -strftime 1 -segment_time 60  video_%F-%X.mp4
