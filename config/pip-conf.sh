#!/bin/bash
# date 2020-04-26 11:02:05
# author calllivecn <calllivecn@outlook.com>

# 清华
# https://pypi.tuna.tsinghua.edu.cn/simple

# 阿里
# https://mirrors.aliyun.com/pypi/simple/

# 配置系统源
sudo pip3 config --global set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 添加额外的地址
#sudo pip3 config --global set global.extra-index-url https://mirrors.aliyun.com/pypi/simple/

# 这是配置当前用户的源
#pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# 这是配置当前用户的源
#pip3 config set global.extra-index-url https://mirrors.aliyun.com/pypi/simple/


# 设置当前用户的 pip 缴存目录， 默认是 ~/.cache/pip
#pip config set global.cache-dir /home/pip-cache

# 查看当前系统配置文件的位置
#pip config list -v

# conda 配置源

