#!/usr/bin/bash 

# 查看在 wayland 环境下. 指定的应用是否使用了 Xwayland .



echo "现在切换到 需要查看的应用窗口 ..."
echo "如果鼠标可以选择到: 说明是使用的Xwayland"

xprop 


