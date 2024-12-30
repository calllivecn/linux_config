# 实测在 amd-cpu 5800X  nvidia 3080TI GPU 成功

## libvirt + qemu 的hooks 说明：[hooks](https://libvirt.org/hooks.html#etc-libvirt-hooks-qemu)

这四个文件是需要放到 /etc/libvirt/hooks/ 下的

- vm.conf
- qemu
- log.sh
- vfio-startup.sh
- vfio-down.sh


## 在vm.conf 中配置信息

## 需要修改 vfio-\*.sh 脚本中的 nvidia GPU 的pci_id 。


## 注意事项

- 在开机直通显卡的虚拟机之前，需要保证没有进程占用nvidia驱动。 这样最终会虚拟开不了机, 但是外接显示器已经黑屏。

    - 这里就遇到了，在终端使用nvidia-smi 查看GPU信息时,导致报错卸载不掉。
        ```shell
        modprobe -r nvidia
        modprobe: FATAL: Module nvidia is in use.
        ```
    
    - 这时 vrish  nodedev-detach pci_000_AB_CD_E 卡住。
