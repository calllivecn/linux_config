# zfs 的基本使用。

vim /etc/modprobe.d/zfs.conf

options zfs zfs_arc_mem=1073741824 # 使用1G的AR缓存,不设置的话，把内存先占完。


# 把一个已经安装好，在使用的系统迁移到以 zfs 为根目录的新的 zfs 文件系统。

## 1. 