# 使用 nmcli 添加网桥

1. 添加一个bridge
2. 添加一个或者多个slave设备


```shell
$ nmcli con add con-name br0 ifname br0 type bridge

$ nmcli con add con-name br0-eth0 ifname eth0 master br0

$ nmcli con br0 up
```