#!/bin/bash
# date 2023-11-15 20:39:54
# author calllivecn <calllivecn@outlook.com>


sudo snap set system proxy.http="http://10.1.3.254:9999"
sudo snap set system proxy.https="http://10.1.3.254:9999"

# 查看
# sudo snap get system proxy
# 删除
# sudo snap unset system proxy proxy.http
