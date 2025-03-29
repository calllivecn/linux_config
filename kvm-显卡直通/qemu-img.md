# 使用 qemu-img 工具， 创建，克隆，打包为\*.tar 文件->备份到网盘, 等等使用流程记录。


## 使用qemu-img 创建磁盘时的命令选项:


- 创建一个新镜像文件
```shell
qemu-img create -O qcow2 -o compression_type=zstd <disk-name.qcow2> <size>
```

- 基于一个已经存在的镜像，克隆出一个新镜像。
- 同时可以在磁盘写入空之后，convert 一次减小磁盘文件大小。

```shell
qemu-img convert -O qcow2 -o compression_type=zstd old_disk_name.qcow2 
```
